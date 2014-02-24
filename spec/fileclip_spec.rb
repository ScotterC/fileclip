require 'spec_helper'

describe FileClip do
  let(:filepicker_url) { "https://www.filepicker.io/api/file/ibOold9OQfqbmzgP6D3O" }
  let(:instance)       { Image.new(attachment_filepicker_url: filepicker_url) }
  let(:empty_instance) { Image.new }
  let(:metadata_resp)  { "{\"mimetype\": \"image/gif\", \"filename\": \"140x100.gif\", \"size\": 449}" }

  before :each do
    Image.any_instance.stub(:attachment=).and_return true
    RestClient.stub(:get).
                with([filepicker_url, '/metadata'].join).
                and_return metadata_resp
  end

  describe ".process" do
    before :each do
      instance.save
    end

    it "puts together an instance and processes it directly" do
      Image.any_instance.should_receive(:process_fileclip!).with(:attachment)
      FileClip.process("Image", instance.id, :attachment)
    end
  end

  describe ".delay_enabled?" do
    it "returns false without resque" do
      FileClip.delay_enabled?.should be_false
    end

    it "returns true if resque exists" do
      stub_const("Resque", true)
      FileClip.delay_enabled?.should be_true
    end
  end

  describe "change keys" do
    it "defaults to just fileclip_url" do
      FileClip.change_keys.should == ["attachment_filepicker_url", "other_attachment_filepicker_url"]
    end

    it "can be added to" do
      FileClip.change_keys << "file_name"
      FileClip.change_keys.should == ["attachment_filepicker_url", "other_attachment_filepicker_url", "file_name"]
    end
  end

  describe "class_methods" do
    describe "fileclip" do
      it "registers callback" do
        Image.fileclip(:image)
        Image._commit_callbacks.last.filter.should == :process_fileclips!
        Image.fileclips.pop # clear image
      end

      it "adds name to fileclipped" do
        Image.fileclips.should == [:attachment, :other_attachment]
        Image.fileclip(:image)
        Image.fileclips.should == [:attachment, :other_attachment, :image]
        Image.fileclips.pop # clear image
      end
    end
  end

  describe "instance methods" do
    describe "#process_fileclips!" do
      it "processes each name" do
        instance.stub(:update_fileclip?).with(:attachment).and_return true
        instance.stub(:update_fileclip?).with(:other_attachment).and_return false
        instance.should_receive(:process_fileclip).with(:attachment)

        instance.process_fileclips!
      end
    end

    describe "#update_fileclip?" do
      it "should be false with only a filepicker url" do
        instance.send(:update_fileclip?, :attachment).should be_false
      end

      it "should be false on an empty instance" do
        empty_instance.stub_chain(:previous_changes, :keys).and_return ["attachment_filepicker_url"]
        empty_instance.send(:update_fileclip?, :attachment).should be_false
      end

      it "should be true if filepicker url exists and is changed" do
        instance.stub_chain(:previous_changes, :keys).and_return ["attachment_filepicker_url"]
        instance.send(:update_fileclip?, :attachment).should be_true
      end
    end

    context "#fileclip_previously_changed?" do
      it "should return true with previous changed filepicker_url" do
        instance.stub_chain(:previous_changes, :keys).and_return ["attachment_filepicker_url"]
        instance.send(:fileclip_previously_changed?, :attachment).should be_true
      end

      it "should return false without previously changed fileclip_url" do
        instance.stub_chain(:previous_changes, :keys).and_return []
        instance.send(:fileclip_previously_changed?, :attachment).should be_false
      end
    end
  end
end