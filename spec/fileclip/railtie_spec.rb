require 'spec_helper'
describe FileClip::Railtie do
  describe "insert" do
    it "should include the glue" do
      ActiveRecord::Base.should_receive(:send).with(:include, FileClip::Glue)
      FileClip::Railtie.insert
    end
  end
end