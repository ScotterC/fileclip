module FileClip
  module Validators

    module HelperMethods

      def validates_attachment_content_type(*attr_names)
        attr_names.last.merge!({ :if => :filepicker_url_not_present? })
        super(*attr_names)
      end

      def validates_attachment_presence(*attr_names)
        attr_names.last.merge!({ :if => :filepicker_url_not_present? })
        super(*attr_names)
      end

      def validates_attachment_size(*attr_names)
        attr_names.last.merge!({ :if => :filepicker_url_not_present? })
        super(*attr_names)
      end

    end

  end
end