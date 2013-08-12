require 'spec_helper'

describe FileClip::Validators do
  let(:image) { Image.new }

  describe "validations" do
    before :each do
      Image.reset_callbacks(:validate)
      Image._validators.clear
    end

    describe "if no filepicker_url" do
      it "observes attachment presence" do
        Image.validates :attachment, :attachment_presence => true
        image.save.should be_false
        image.errors.first.last.should == "can't be blank"
      end

      it "observes attachment size" do
        Image.validates_attachment :attachment, :size => { :in => 0..1000 }, :presence => true
        image.save.should be_false
        image.errors.should_not be_empty
      end

      it "observes attachment content" do
        Image.validates_attachment :attachment, :content_type => { :content_type => "image/jpg" }, :presence => true
        image.save.should be_false
        image.errors.should_not be_empty
      end
    end

    describe "with filepicker url" do
      before :each do
        image.filepicker_url = "image.com"
      end

      it "observes attachment presence" do
        Image.validates :attachment, :attachment_presence => true
        image.save.should be_true
        image.errors.should be_empty
      end

      it "observes attachment size" do
        Image.validates_attachment :attachment, :size => { :in => 0..1000 }, :presence => true
        image.save.should be_true
        image.errors.should be_empty
      end

      it "observes attachment content" do
        Image.validates_attachment :attachment, :content_type => { :content_type => "image/jpg" }, :presence => true
        image.save.should be_true
        image.errors.should be_empty
      end
    end
  end
end