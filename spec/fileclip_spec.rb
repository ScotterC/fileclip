require 'spec_helper'

describe FileClip do
  let(:attachment_filepicker_url) { "https://www.filepicker.io/api/file/ibOold9OQfqbmzgP6D3O" }
  let(:other_attachment_filepicker_url) { "https://www.filepicker.io/api/file/ibOold9OQfqbmzgP6D31" }
  let(:image) { Image.new }
  let(:uri) { URI.parse(attachment_filepicker_url) }

  describe ".delayed?" do
    it "returns false without delayed paperclip" do
      FileClip.delayed?.should be_false
    end

    it "returns true if delayed paperclip exists" do
      stub_const("DelayedPaperclip", true)
      FileClip.delayed?.should be_true
    end
  end

  describe "class_methods" do
    describe "fileclip" do
      it "should register callback when called" do
        Image.fileclip :attachment
        Image._commit_callbacks.map(&:filter).should =~ [:update_attachment_from_filepicker!, :update_other_attachment_from_filepicker!]
      end

      it "registers after save callback if commit is not available" do
        pending # Skipping either callback
        Image._save_callbacks.first.filter.should_not == :update_attachment_from_filepicker!
        Image.stub(:respond_to?).with(:after_commit).and_return false
        FileClip::Glue.included(Image)
        Image._save_callbacks.first.filter.should == :update_attachment_from_filepicker!
      end
    end

    describe "resque_enabled?" do
      it "returns false by default" do
        FileClip.resque_enabled?.should be_false
      end

      it "returns true if resque exists" do
        stub_const "Resque", Class.new
        FileClip.resque_enabled?.should be_true
      end
    end

    describe "sidekiq_enabled?" do
      it "returns false by default" do
        FileClip.sidekiq_enabled?.should be_false
      end

      it "returns true if resque exists" do
        stub_const "Sidekiq", Class.new
        FileClip.sidekiq_enabled?.should be_true
      end
    end
  end

  describe "instance methods" do
    context "#update_attachment_from_filepicker!" do
      context "without a background queue" do
        it "processes one attachment when only one changes" do
          image.attachment_filepicker_url = attachment_filepicker_url
          image.stub_chain(:previous_changes, :keys).and_return ["attachment_filepicker_url"]
          image.should_receive(:process_attachment_from_filepicker)
          image.should_not_receive(:process_other_attachment_from_filepicker)
          
          image.update_attachment_from_filepicker!
          image.update_other_attachment_from_filepicker!
        end

        it "processes multiple attachments when multiple change" do
          image.attachment_filepicker_url = attachment_filepicker_url
          image.other_attachment_filepicker_url = other_attachment_filepicker_url
          image.stub_chain(:previous_changes, :keys).and_return ["attachment_filepicker_url", "other_attachment_filepicker_url"]
          image.should_receive(:process_attachment_from_filepicker)
          image.should_receive(:process_other_attachment_from_filepicker)
          
          image.update_attachment_from_filepicker!
          image.update_other_attachment_from_filepicker!
        end
      end

      context "with a background queue" do
        it "enqueues job with Resque" do
          image.attachment_filepicker_url = attachment_filepicker_url
          image.stub_chain(:previous_changes, :keys).and_return ["attachment_filepicker_url"]
          stub_const "Resque", Class.new
          Resque.should_receive(:enqueue).with(FileClip::Jobs::Resque, "Image", nil, :attachment)
          image.update_attachment_from_filepicker!
        end

        it "enqueues multiple job with Resque" do
          image.attachment_filepicker_url = attachment_filepicker_url
          image.other_attachment_filepicker_url = other_attachment_filepicker_url
          image.stub_chain(:previous_changes, :keys).and_return ["attachment_filepicker_url", "other_attachment_filepicker_url"]
          stub_const "Resque", Class.new
          Resque.should_receive(:enqueue).with(FileClip::Jobs::Resque, "Image", nil, :attachment)
          Resque.should_receive(:enqueue).with(FileClip::Jobs::Resque, "Image", nil, :other_attachment)
          image.update_attachment_from_filepicker!
          image.update_other_attachment_from_filepicker!
        end

        it "enqueues job with Sidekiq" do
          image.attachment_filepicker_url = attachment_filepicker_url
          image.stub_chain(:previous_changes, :keys).and_return ["attachment_filepicker_url"]
          stub_const "Sidekiq", Class.new
          stub_const "Sidekiq::Worker", Class.new
          FileClip::Jobs::Sidekiq.should_receive(:perform_async).with("Image", nil, :attachment)
          image.update_attachment_from_filepicker!
        end

        it "enqueues multiple job with Sidekiq" do
          image.attachment_filepicker_url = attachment_filepicker_url
          image.other_attachment_filepicker_url = other_attachment_filepicker_url
          image.stub_chain(:previous_changes, :keys).and_return ["attachment_filepicker_url", "other_attachment_filepicker_url"]
          stub_const "Sidekiq", Class.new
          stub_const "Sidekiq::Worker", Class.new
          FileClip::Jobs::Sidekiq.should_receive(:perform_async).with("Image", nil, :attachment)
          FileClip::Jobs::Sidekiq.should_receive(:perform_async).with("Image", nil, :other_attachment)
          image.update_attachment_from_filepicker!
          image.update_other_attachment_from_filepicker!
        end
      end

      context "with delayed paperclip" do
        let(:delayed_image) { DelayedImage.create }

        before :each do
          FileClip.stub(:delayed?).and_return true
          FileClip.stub(:resque_enabled?).and_return true
          stub_const "Resque", Class.new

          delayed_image.attachment_filepicker_url = attachment_filepicker_url
          delayed_image.stub_chain(:previous_changes, :keys).and_return ["attachment_filepicker_url"]
        end

        it "should update processing column" do
          delayed_image.attachment_processing.should be_false
          Resque.should_receive(:enqueue).with(FileClip::Jobs::Resque, "DelayedImage", delayed_image.id, :attachment)
          delayed_image.update_attachment_from_filepicker!
          delayed_image.attachment_processing.should be_true
        end
      end
    end

    context "#update_attachment_from_filepicker?" do
      it "should be false with only a attachment_filepicker url" do
        image.attachment_filepicker_url = attachment_filepicker_url
        image.update_attachment_from_filepicker?.should be_false
      end

      it "should be false without a filepicker" do
        image.stub_chain(:previous_changes, :keys).and_return ["attachment_filepicker_url"]
        image.update_attachment_from_filepicker?.should be_false
      end

      it "should be true if filepicker url exists and is changed" do
        image.attachment_filepicker_url = attachment_filepicker_url
        image.stub_chain(:previous_changes, :keys).and_return ["attachment_filepicker_url"]
        image.update_attachment_from_filepicker?.should be_true
      end
    end

    context "#process_attachment_from_filepicker" do
      context "not delayed" do
        context "image" do
          before :each do
            image.attachment_filepicker_url = attachment_filepicker_url
          end

          it "should set attachment and save" do
            image.should_receive(:attachment=).with(uri)
            image.should_receive(:save)
            image.process_attachment_from_filepicker
          end
        end
      end
    end

    context "#attachment_filepicker_url_not_present?" do
      it "should return true" do
        image.attachment_filepicker_url_not_present?.should == true
      end

      context "with filepicker url" do
        before :each do
          image.attachment_filepicker_url = attachment_filepicker_url
        end

        it "should return false" do
          image.attachment_filepicker_url_not_present?.should == false
        end
      end
    end

    context "#fileclip_previously_changed?" do
      it "should return true with previous changed filepicker_url" do
        image.stub_chain(:previous_changes, :keys).and_return ["attachment_filepicker_url"]
        image.attachment_fileclip_previously_changed?.should be_true
      end

      it "should return false without previously changed attachment_filepicker_url" do
        image.stub_chain(:previous_changes, :keys).and_return []
        image.attachment_fileclip_previously_changed?.should be_false
      end
    end

    def raw_data
      "{\"mimetype\": \"image/gif\", \"uploaded\": 1374701729162.0, \"writeable\": true, \"filename\": \"140x100.gif\", \"location\": \"S3\", \"path\": \"tmp/tMrYkwI0RWOv0R13hALu_140x100.gif\", \"size\": 449}"
    end

    def metadata
      {"mimetype"   => "image/gif",
       "uploaded"   => 1374701729162.0,
       "writeable"  => true,
       "filename"   => "140x100.gif",
       "location"   => "S3",
       "path"       => "tmp/tMrYkwI0RWOv0R13hALu_140x100.gif",
       "size"       => 449 }
    end


    context "assign metadata" do
      before :each do
        image.attachment_filepicker_url = attachment_filepicker_url
        RestClient.stub(:get).with(image.attachment_filepicker_url + "/metadata").and_return raw_data
      end

      it "sets metadata from filepicker" do
        image.set_attachment_metadata
        image.attachment_content_type.should == "image/gif"
        image.attachment_file_name.should == "140x100.gif"
        image.attachment_file_size.should == 449
      end

      context "process_from_filepicker" do
        it "sets data and uploads attachment" do
          image.process_attachment_from_filepicker
          image.attachment_content_type.should == "image/gif"
          image.attachment_file_name.should == "140x100.gif"
          image.attachment_file_size.should == 449
        end
      end
    end

  end
end