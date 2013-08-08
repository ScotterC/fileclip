module FileClip
  module Validators

    def self.included(base)
      base.send :include, ClassMethods
      base.alias_method_chain :validates_attachment, :fileclip
    end

    module ClassMethods

      # Only run validations if filepicker_url not present
      def validates_attachment_with_fileclip(*attributes)
        attributes.last.merge!({ :if => :filepicker_url_not_present? })
        validates_attachment_without_fileclip(*attributes)
      end

    end
  end
end