module FileClip
  class Configuration
    attr_writer :filepicker_key, :services,
                :max_size, :storage_path,
                :mime_types, :file_access

    def filepicker_key
      @filepicker_key or raise "Set Filepicker api_key"
    end

    def services
      @services or ["COMPUTER"]
    end

    def max_size
      @max_size or 20
    end

    def storage_path
      @storage_path or "/fileclip/"
    end

    def mime_types
      @mime_types or "image/*"
    end

    def file_access
      @file_access or "public"
    end

  end

  class << self
    def configure
      yield configuration
    end

    def configuration
      @configuration ||= FileClip::Configuration.new
    end
  end
end
