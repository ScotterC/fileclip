require 'spec_helper'

describe FileClip::Railtie do
  describe "include on initialzation" do
    it "should insert fileclip on rails initialzation" do
      pending "Not sure how to call the load"
      FileClip::Railtie.should_receive(:insert)
      ActiveSupport.load(:active_record)
    end
  end

  describe "insert" do
    it "should include the glue" do
      ActiveRecord::Base.should_receive(:send).with(:include, FileClip::Glue)
      FileClip::Railtie.insert
    end
  end
end