module FileClip
  module Rails

    module ViewHelpers
      def fileclip_js_include_tag
        javascript_include_tag "//api.filepicker.io/v1/filepicker.js"
        javascript_include_tag "my cofee"
      end

      # Options
      # js to activate it on the spot, defaults to true
      # class to add css classes
      def link_to_fileclip(text, form_object, options)
        id = fileclip_id(form_object)
        classes = fileclip_css_classes(options[:class])
        link = link_to text, "javascript:void(0)", class: classes, id: id

        fileclip_link_builder(link, form_object, options, id)
      end

      def fileclip_css_classes(given_classes)
        return "js-fileclip" if given_classes.nil?
        css_classes = [].push(given_classes.split)
        css_classes << "js-fileclip"
        css_classes
      end

      def fileclip_id(form_object)
        new_object = form_object.object
        attachment_name = new_object.attachment_name
        "#{attachment_name}_#{new_object.object_id}"
      end

      # Return empty tag if it's nil or true
      def activation(js, id)
        return javascript_tag unless js.nil? || js

        javascript_tag("(function() {
                          (new FileClip).button('##{id}');
                        })();")
      end

      # Options
      # Required to require first field
      # Activate (defaults to true) to set own javascript
      def fileclip_link_builder(link, form_object, options, id)
        required = options[:required]

        # Get attachment name
        attachment_name = form_object.object.attachment_name

        js = activation(options[:js], id)

        js + link +
        form_object.hidden_field(:filepicker_url, class: "js-fileclip_url #{'required' if required}", data: { type: attachment_name})
      end

    end

  end

end
