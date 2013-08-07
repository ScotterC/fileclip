module FileClip
  if defined? Rails::Railtie
    require 'rails'

    # On initialzation, include FileClip
    class Railtie < Rails::Railtie
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

  class Railtie
    # Glue includes FileClip into ActiveRecord
    # TODO: only include it in models that have paperclip attachments
    # Will require restart of server for it to pick up the class on edit
    def self.insert
      ::ActiveRecord::Base.send(:include, FileClip::Glue)
    end
  end
end