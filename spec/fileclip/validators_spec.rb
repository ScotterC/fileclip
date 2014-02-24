require 'spec_helper'

describe FileClip::Validators do
  let(:instance) { Image.new }

  describe "validations" do
    before :each do
      Image.reset_callbacks(:validate)
      Image._validators.clear
    end

    describe "if no attachment_filepicker_url" do
      it "observes attachment presence" do
        Image.validates :attachment, attachment_presence: true
        instance.save.should be_false
        instance.errors.first.last.should == "can't be blank"
      end

      it "observes attachment size" do
        Image.validates_attachment :attachment, size: { in: 0..1000 },
                                                presence: true
        instance.save.should be_false
        instance.errors.should_not be_empty
      end

      it "observes attachment content" do
        Image.validates_attachment :attachment, content_type: { content_type: "image/jpg" },
                                                presence: true
        instance.save.should be_false
        instance.errors.should_not be_empty
      end
    end

    describe "with filepicker url" do
      before :each do
        instance.attachment_filepicker_url = "image.com"
        instance.fileclip_url_present?(:attachment).should be_true
      end

      it "observes attachment presence" do
        Image.validates :attachment, attachment_presence: true
        instance.save.should be_true
        instance.errors.should be_empty
      end

      it "observes attachment presence" do
        pending
        Image.validates_attachment_presence :attachment
        instance.save.should be_true
        instance.errors.should be_empty
      end

      it "observes attachment presence" do
        pending
        Image.validates_attachment :attachment, presence: true
        instance.save.should be_true
        instance.errors.should be_empty
      end

      it "observes attachment size" do
        Image.validates_attachment :attachment, size: { in: 0..1000 }, attachment_presence: true
        instance.save.should be_true
        instance.errors.should be_empty
      end

      it "observes attachment content" do
        Image.validates_attachment :attachment, content_type: { content_type: "image/jpg" },
                                                attachment_presence: true
        instance.save.should be_true
        instance.errors.should be_empty
      end
    end

    describe "for non fileclipped asset" do
      let(:asset) { PlainAsset.new }

      before :each do
        PlainAsset.reset_callbacks(:validate)
        PlainAsset._validators.clear
      end

      describe "if no filepicker_url" do
        it "observes attachment presence" do
          PlainAsset.validates :attachment, attachment_presence: true
          asset.save.should be_false
          asset.errors.first.last.should == "can't be blank"
        end

        it "observes attachment size" do
          PlainAsset.validates_attachment :attachment, size: { in: 0..1000 },
                                                       presence: true
          asset.save.should be_false
          asset.errors.should_not be_empty
        end

        it "observes attachment content" do
          PlainAsset.validates_attachment :attachment, content_type: { content_type: "image/jpg" },
                                                       presence: true
          asset.save.should be_false
          asset.errors.should_not be_empty
        end
      end
    end
  end
end