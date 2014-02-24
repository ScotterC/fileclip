module FileClip
  module ActionView
    module FormHelper

      # TODO: shouldn't limit the options
      def fileclip(attachment, button_text = "Pick", options = {})
        type = "fileclip"

        method_name = [attachment, "_filepicker_url"].join

        input_options                      = {}
        input_options["type"]              = type
        input_options["data-button-text"]  = button_text
        input_options["data-button-class"] = options[:class]
        input_options["data-button-id"]    = options[:id]
        input_options["data-activate"]     = options[:activate]
        input_options["data-callback"]     = options[:callback]

        if ::Rails.version.to_i >= 4
          ::ActionView::Helpers::Tags::TextField.new(@object_name,
                                                     method_name,
                                                     @template,
                                                     objectify_options(input_options)).
                                                     render
        else
          ::ActionView::Helpers::InstanceTag.new(@object_name,
                                                 method_name,
                                                 @template).
            to_input_field_tag(type, input_options)
        end

      end
    end

  end

end
