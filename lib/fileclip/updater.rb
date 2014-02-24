require 'fileclip/jobs/resque'
require 'fileclip/jobs/sidekiq'
require 'rest-client'

module FileClip

  class Updater

    attr_reader :instance, :attachment_name

    def initialize(instance, attachment_name)
      @instance        = instance
      @attachment_name = attachment_name
    end

    def enqueue
      if FileClip.delay_enabled?
        delay_process!
      else
        process!
      end
    end

    def process!
      instance.update_column(:"#{attachment_name}_processing", true)

      instance.class.without_fileclip_callback do
        instance.send(:"#{attachment_name}=", URI.parse(fileclip_url))
        assign_metadata
        instance.save
        instance.send(attachment_name).post_processing = true
        instance.send(attachment_name).reprocess!
      end

      instance.update_column(:"#{attachment_name}_processing", false)
    end

    private

    def assign_metadata
      instance.send(:"#{attachment_name}_content_type=", metadata[:mimetype])
      instance.send(:"#{attachment_name}_file_name=",    filename)
      instance.send(:"#{attachment_name}_file_size=",    metadata[:size])
    end

    def metadata
      @metadata ||= JSON.parse(::RestClient.get [fileclip_url, "/metadata"].join).symbolize_keys!
    end

    # Uses Paperclip's filename cleaner
    def filename
      @filename ||= instance.send(attachment_name).
                      send(:cleanup_filename, metadata[:filename])
    end

    def fileclip_url
      instance.send([attachment_name, "_filepicker_url"].join.to_sym)
    end

    def delay_process!
      background_processor.enqueue_fileclip(instance, attachment_name)
    end

    def background_processor
      return FileClip::Jobs::Resque     if defined? ::Resque
      return FileClip::Jobs::Sidekiq    if defined? ::Sidekiq
    end

  end

end