# TODO
#
# Allowance for normal attached images through file_field:
#  only do attachment validation if it's there if remote url is not present
#  only do process_in_background if remote_url is not present
#
# Expose FilePicked to all classes that have Paperclip images
#
# Handle multiple attachments in single model
#  Crux of this is finding the name of the attachment we're dealing with
#
# Fallback if none are defined
#
# What can we separate out into it's own class
# What should be a part of attachment
#
# Migration generator
#
# Configuration to take Filepicker API key
#
# Javascript inclusion
#
# Add delayed aspect
#
# Queue job for image assignment
require "fileclip/configuration"
require 'fileclip/action_view/helpers'
require 'fileclip/railtie'
require 'rest-client'

module FileClip

  module Glue
    def self.included(base)
      base.extend(ClassMethods)
      base.send :include, InstanceMethods
      base.add_callbacks
    end
  end

  module ClassMethods
    def add_callbacks
      attr_accessible :filepicker_url

      # if respond_to?(:after_commit)
        after_commit  :update_from_filepicker!
      # else
      #   after_save    :update_from_filepicker!
      # end

      # TODO:
      # skip validates_attachment_presence if filepicker url present
      # Save without this particular vaildation
    end

    def paperclip_definitions
      @paperclip_definitions ||= if respond_to? :attachment_definitions
        attachment_definitions
      else
        Paperclip::Tasks::Attachments.definitions_for(self)
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