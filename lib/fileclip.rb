require 'fileclip/configuration'
require 'fileclip/action_view/helpers'
require 'fileclip/validators'
require 'fileclip/engine'
require 'fileclip/railtie'
require 'rest-client'

module FileClip

  module Glue
    def self.included(base)
      base.extend(ClassMethods)
      base.send :include, InstanceMethods
    end
  end

  module ClassMethods
    def fileclip(name)
      extend FileClip::Validators::ClassMethods

      attr_accessible :filepicker_url

      after_commit  :update_from_filepicker!
    end

    def paperclip_definitions
      @paperclip_definitions ||= if Paperclip::VERSION.to_f < 3.5
        attachment_definitions
      elsif Paperclip::VERSION == "3.5.0"
        Paperclip::Tasks::Attachments.definitions_for(self)
      else
        Paperclip::AttachmentRegistry.definitions_for(self)
      end
    end
  end

  module InstanceMethods

    # TODO: can't handle multiples, just first
    def attachment_name
      @attachment_name ||= self.class.paperclip_definitions.keys.first
    end

    def attachment_object
      self.send(attachment_name)
    end

    def update_from_filepicker!
      process_from_filepicker if update_from_filepicker?
    end

    def process_from_filepicker
      self.class.skip_callback :commit, :after, :update_from_filepicker!
      self.send(:"#{attachment_name}=", URI.parse(filepicker_url))
      self.set_metadata
      self.save
      self.class.set_callback :commit, :after, :update_from_filepicker!
    end

    def set_metadata
      metadata = JSON.parse(::RestClient.get filepicker_url + "/metadata")

      self.send(:"#{attachment_name}_content_type=",  metadata["mimetype"])
      self.send(:"#{attachment_name}_file_name=",     metadata["filename"])
      self.send(:"#{attachment_name}_file_size=",     metadata["size"])
    end

    def update_from_filepicker?
      filepicker_url_previously_changed? &&
      filepicker_url.present? &&
      !filepicker_only?
    end

    def filepicker_url_not_present?
      !filepicker_url.present?
    end

    def filepicker_url_previously_changed?
      previous_changes.keys.include?('filepicker_url')
    end

    # To be overridden in model if specific logic for not
    # processing the image
    def filepicker_only?
      false
    end
  end

end