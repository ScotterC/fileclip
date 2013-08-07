require 'spec_helper'

describe FileClip do
  let(:filepicker_url) { "https://www.filepicker.io/api/file/ibOold9OQfqbmzgP6D3O" }
  let(:image) { Image.new }
  let(:uri) { URI.parse(filepicker_url) }

  describe ".options" do
    it ".options returns basic options" do
      FileClip.options.should == { :filepicker_key => nil }
    end
  end

  describe "glue" do
    describe "add_callbacks" do
      it "should register callback when called" do
        Image._commit_callbacks.first.filter.should == :update_from_filepicker!
      end

      it "registers after save callback if commit is not available" do
        pending # Skipping either callback
        Image._save_callbacks.first.filter.should_not == :update_from_filepicker!
        Image.stub(:respond_to?).with(:after_commit).and_return false
        FileClip::Glue.included(Image)
        Image._save_callbacks.first.filter.should == :update_from_filepicker!
      end
    end
  end

  describe "instance methods" do

    context "#attachment_name" do
      context "image" do
        it "should return :attachment" do
          image.attachment_name.should == :attachment
        end
      end
    end

    context "#attachment_object" do
      context "image" do
        it "should receive attachment" do
          image.should_receive(:attachment)
          image.attachment_object
        end
      end
    end

    context "#update_from_filepicker!" do

      context "delayed" do
        before :each do
          image.filepicker_url = filepicker_url
          image.stub_chain(:previous_changes, :keys).and_return ["filepicker_url"]
        end

        context "image" do
          it "should enqueue image with proper id and klass" do
            image.should_receive(:update_from_filepicker?).and_return true
            image.update_from_filepicker!
          end
        end

      end
    end

    context "#update_from_filepicker?" do
      it "should be false with only a filepicker url" do
        image.filepicker_url = filepicker_url
        image.update_from_filepicker?.should be_false
      end

      it "should be false without a filepicker" do
        image.stub_chain(:previous_changes, :keys).and_return ["filepicker_url"]
        image.update_from_filepicker?.should be_false
      end

      it "should be true if filepicker url exists and is changed" do
        image.filepicker_url = filepicker_url
        image.stub_chain(:previous_changes, :keys).and_return ["filepicker_url"]
        image.update_from_filepicker?.should be_true
      end
    end

    context "#process_from_filepicker" do
      context "not delayed" do
        context "image" do
          before :each do
            image.filepicker_url = filepicker_url
          end

          it "should set attachment and save" do
            image.should_receive(:attachment=).with(uri)
            image.should_receive(:save)
            image.process_from_filepicker
          end
        end
      end
    end

    context "#filepicker_url_not_present?" do
      it "should return true" do
        image.filepicker_url_not_present?.should == true
      end

      context "with filepicker url" do
        before :each do
          image.filepicker_url = filepicker_url
        end

        it "should return false" do
          image.filepicker_url_not_present?.should == false
        end
      end
    end


    context "#filepicker_url_previously_changed?" do
      it "should return true with previous changed filepicker_url" do
        image.stub_chain(:previous_changes, :keys).and_return ["filepicker_url"]
        image.filepicker_url_previously_changed?.should be_true
      end

      it "should return false without previously changed filepicker_url" do
        image.stub_chain(:previous_changes, :keys).and_return []
        image.filepicker_url_previously_changed?.should be_false
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
        image.filepicker_url = filepicker_url
        RestClient.stub(:get).with(image.filepicker_url + "/metadata").and_return raw_data
      end

      it "sets metadata from filepicker" do
        image.set_metadata
        image.attachment_content_type.should == "image/gif"
        image.attachment_file_name.should == "140x100.gif"
        image.attachment_file_size.should == 449
      end

      context "process_from_filepicker" do
        it "sets data and uploads attachment" do
          image.process_from_filepicker
          image.reload
          image.attachment_content_type.should == "image/gif"
          image.attachment_file_name.should == "140x100.gif"
          image.attachment_file_size.should == 449
        end
      end
    end

  end
end