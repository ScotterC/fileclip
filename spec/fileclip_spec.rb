require 'spec_helper'
require 'resque'

describe FileClip do
  describe ".options" do
    it ".options returns basic options" do
      FileClip.options.should == { :filepicker_key => nil }
    end
  end

  describe ".processor" do
    it ".processor returns processor" do
      FileClip.processor.should == FileClip::Jobs::Resque
    end
  end

  describe ".enqueue" do
    it "delegates to processor" do
      FileClip::Jobs::Resque.expects(:enqueue_update).with("Dummy", 1, :image)
      FileClip.enqueue("Dummy", 1, :image)
    end
  end

  # describe ".process_job" do
  #   let(:dummy) { Dummy.create! }

  #   it "finds dummy and calls #process_from_filepicker!" do
  #     Dummy.expects(:find).with(dummy.id).returns(dummy)
  #     dummy.image.expects(:process_from_filepicker!)
  #     FileClip.update("Dummy", dummy.id, :image)
  #   end
  # end


end