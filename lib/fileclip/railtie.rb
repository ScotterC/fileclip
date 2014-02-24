require 'rails'

module FileClip
  class Railtie < ::Rails::Railtie

    initializer "fileclip.model_methods" do
      ::ActiveRecord::Base.send(:include, FileClip::Glue)
    end

    initializer "fileclip.view_helpers" do
      ::ActionView::Base.send(:include, FileClip::ActionView::Helpers)
      ::ActionView::Helpers::FormBuilder.send(:include, FileClip::ActionView::FormHelper)
    end
  end
end