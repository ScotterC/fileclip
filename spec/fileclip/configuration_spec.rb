require 'spec_helper'

describe FileClip::Configuration do

  describe "filepicker_key" do
    it "should be nil to start" do
      expect { FileClip.configuration.filepicker_key }.to raise_error
    end

    it "should be set by block" do
      FileClip.configure do |config|
        config.filepicker_key = "XXX-XXX"
      end
      FileClip.configuration.filepicker_key.should == "XXX-XXX"
    end
  end
end