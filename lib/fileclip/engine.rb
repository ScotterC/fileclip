module FileClip
  module Rails
    class Engine < ::Rails::Engine
      initializer 'fileclip.insert_into_active_record' do
        ::ActiveSupport.on_load :active_record do
          FileClip::Railtie.insert
        end
      end

      initializer "fileclip_rails.view_helpers" do
        ::ActionView::Base.send(:include, FileClip::ActionView::Helpers)
      end
    end
  end
end