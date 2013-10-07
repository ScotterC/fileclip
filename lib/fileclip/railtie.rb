require 'rails'

# TODO: only include it in models that have paperclip attachments
# But will require restart of server for it to pick up the class on edit
module FileClip
  class Railtie < ::Rails::Railtie

    initializer "fileclip.model_methods" do
      ::ActiveRecord::Base.send(:include, FileClip::Glue)
    end

    initializer "fileclip.view_helpers" do
      ::ActionView::Base.send(:include, FileClip::ActionView::Helpers)
    end
  end
end