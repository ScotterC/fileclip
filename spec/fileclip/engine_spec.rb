require 'spec_helper'
require 'rails/initializable'


describe FileClip::Rails::Engine do

  describe "include on initialzation" do
    it "should insert fileclip and include view helpers on rails initialzation" do
      pending
      FileClip::Railtie.should_receive(:insert)
      ::ActionView::Base.should_receive(:send).with(:include, FileClip::ActionView::Helpers)
      FileClip::Rails::Engine.run_initializers
    end
  end

end