module FileClip
  class Configuration
    attr_writer :filepicker_key

    def filepicker_key
      @filepicker_key or raise "Set Filepicker api_key"
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
