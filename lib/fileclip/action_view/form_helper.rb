module FileClip
  module ActionView
    module FormHelper

      # TODO:
      # shouldn't limit the options
      # should validate the options
      def fileclip(attachment, text = "Pick", options = {}, &block)
        type = "fileclip"

        method_name = [attachment, "_filepicker_url"].join

        input_options = {}
        input_options["type"]              = type

        input_options["data-button-text"]  = text.gsub("\"", "\'") # For handling html
        input_options["data-button-class"] = options[:class]
        input_options["data-button-id"]    = options[:id]
        input_options["data-activate"]     = options[:activate]
        input_options["data-callback"]     = options[:callback]
        input_options.merge! options.fetch(:html, {}) # for input html options

        input = if ::Rails.version.to_i >= 4
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

        # need to wrap it with something
        # for js to hang on to. maybe link makes sense after all?
        if block_given?
          @template.content_tag :a do
            input + yield
          end
        else
          input
        end
      end
    end

  end

end
