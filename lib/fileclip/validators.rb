module FileClip
  module Validators

    module ClassMethods

      # Only run validations if filepicker_url not present
      def validates_attachment(*attributes)
        attributes.last.merge!({ :if => :filepicker_url_not_present? })
        super(*attributes)
      end

    end

  end
end