module FileClip
  module Validators
    module HelperMethods
      def skip_paperclip?(record, attribute)
        record.class.respond_to?(:fileclips) &&
        record.class.fileclips.include?(attribute) &&
        record.fileclip_url_present?(attribute)
      end
    end

    class AttachmentPresenceValidator < Paperclip::Validators::AttachmentPresenceValidator
      include FileClip::Validators::HelperMethods

      def validate_each(record, attribute, value)
        unless skip_paperclip?(record, attribute)
          super
        end
      end
    end

    class AttachmentContentTypeValidator < Paperclip::Validators::AttachmentContentTypeValidator
      include FileClip::Validators::HelperMethods

      def validate_each(record, attribute, value)
        unless skip_paperclip?(record, attribute)
          super
        end
      end
    end

    class AttachmentSizeValidator < Paperclip::Validators::AttachmentSizeValidator
      include FileClip::Validators::HelperMethods

      def validate_each(record, attribute, value)
        unless skip_paperclip?(record, attribute)
          super
        end
      end
    end

  end
end