module FileClip
  module Validators

    module HelperMethods
      %w{validates_attachment_content_type validates_attachment_presence validates_attachment_size}.each do |method|        
        define_method(method) do |*attr_names|
          if self.column_names.include? "#{attr_names.first}_filepicker_url"
            attr_names.last.merge!({ :if => "#{attr_names.first}_filepicker_url_not_present?".to_sym })
          end
          super(*attr_names)
        end
      end

    end

  end
end