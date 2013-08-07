require 'spec_helper'
require 'rails/initializable'

describe FileClip::Railtie do
  describe "include on initialzation" do
    it "should insert fileclip on rails initialzation" do
      FileClip::Railtie.should_receive(:insert)
      FileClip::Railtie.run_initializers
    end

    it "should insert fileclip on rails initialzation" do
      ActionView::Base.should_receive(:send).with(:include, FileClip::ActionView::Helpers)
      FileClip::Railtie.run_initializers
    end
  end

  describe "insert" do
    it "should include the glue" do
      ActiveRecord::Base.should_receive(:send).with(:include, FileClip::Glue)
      FileClip::Railtie.insert
    end
  end
end