require 'spec_helper'

describe FileClip::Updater do
  let(:filepicker_url)  { "https://www.filepicker.io/api/file/ibOold9OQfqbmzgP6D3O" }
  let(:instance)        { Image.new(attachment_filepicker_url: filepicker_url) }
  let(:metadata_resp)   { "{\"mimetype\": \"image/gif\", \"filename\": \"140x100.gif\", \"size\": 449}" }
  subject { FileClip::Updater.new(instance, :attachment) }

  before :each do
    instance.stub(:attachment=).with(URI.parse(filepicker_url)).and_return true
    RestClient.stub(:get).
                with([filepicker_url, '/metadata'].join).
                and_return metadata_resp
  end


  describe "unit tests" do
    describe "readers" do
      it "has an instance and attachment name" do
        subject.instance.should == instance
        subject.attachment_name.should == :attachment
      end
    end

    describe "#enqueue" do
      describe "delayed" do
        before :each do
          FileClip.stub(:delay_enabled?).and_return true
        end

        it "delegates to delay_process!" do
          subject.should_receive(:delay_process!)
          subject.enqueue
        end
      end

      describe "not delayed" do
        before :each do
          FileClip.stub(:delay_enabled?).and_return false
        end

        it "delegates to delay_process!" do
          subject.should_receive(:process!)
          subject.enqueue
        end
      end
    end

    describe "#process!" do
      before :each do
        instance.attachment_filepicker_url = filepicker_url
        instance.save
      end

      it "sets attachment and save" do
        # instance.should_receive(:update_column).with(:attachment_processing, true)
        instance.should_receive(:attachment=).with(URI.parse(filepicker_url))
        subject.should_receive(:assign_metadata)
        instance.should_receive(:save)
        instance.attachment.should_receive(:reprocess!)

        subject.process!
      end
    end

    describe "#assign_metadata" do
      it "assigns data to instance from metadata hash" do
        instance.should_receive(:attachment_content_type=)
        instance.should_receive(:attachment_file_name=)
        instance.should_receive(:attachment_file_size=)
        subject.send(:assign_metadata)
      end
    end

    describe "#metadata" do
      it "parses fileclip url and returns json data" do
        subject.send(:metadata).should == {
                                    :mimetype => "image/gif",
                                    :filename => "140x100.gif",
                                    :size => 449
                                  }
      end
    end

    describe "#filename" do
      it "cleans filename with paperclip's file cleaner" do
        instance.attachment.should_receive(:cleanup_filename)
        subject.send(:filename)
      end
    end

    describe "#fileclip_url" do
      it "prefixes the attachment name" do
        subject.send(:fileclip_url).should == filepicker_url
      end
    end

    describe "#delay_process!" do
      it "delegates to background processor" do
        stub_const("Resque", true)
        FileClip::Jobs::Resque.should_receive(:enqueue_fileclip).
                                with(instance, :attachment)
        subject.send(:delay_process!)
      end
    end

    describe "#background_processor" do
      it "returns fileclip resque job" do
        stub_const("Resque", true)
        subject.send(:background_processor).should == FileClip::Jobs::Resque
      end
    end

  end

end