require 'fileclip/configuration'
require 'fileclip/action_view/helpers'
require 'fileclip/validators'
require 'fileclip/engine'
require 'fileclip/railtie'
require 'fileclip/jobs/resque'
require 'rest-client'

module FileClip
  mattr_accessor :change_keys

  class << self

    def process(klass, instance_id)
      klass.constantize.find(instance_id).process_from_filepicker
    end

    # TODO: replace with checking for delayed options?
    def delayed?
      defined?(DelayedPaperclip)
    end

    def resque_enabled?
      !!(defined? Resque)
    end

    def change_keys
      @@change_keys ||= [:filepicker_url]
    end

  end

  module Glue
    def self.included(base)
      base.extend ClassMethods
      base.extend FileClip::Validators::HelperMethods
      base.send :include, InstanceMethods
    end
  end

  module ClassMethods
    def fileclip(name)
      attr_accessible :filepicker_url
      after_commit  :update_from_filepicker!

      set_fileclipped(name)
    end

    def fileclipped
      @attachment_name
    end

    def set_fileclipped(name)
      @attachment_name = name
    end
  end

  module InstanceMethods

    # TODO: can't handle multiples, just given
    def attachment_name
      @attachment_name ||= self.class.fileclipped
    end

    def attachment_object
      self.send(attachment_name)
    end

    def update_from_filepicker!
      if update_from_filepicker?
        if FileClip.resque_enabled?
          # TODO: self.class.name is webrick ???
          delay_process!
        else
          process_from_filepicker
        end
      end
    end

    def delay_process!
      update_column(:"#{attachment_name}_processing", true) if FileClip.delayed?
      Resque.enqueue(FileClip::Jobs::Resque, self.class.name, self.id)
    end

    def process_from_filepicker
      self.class.skip_callback :commit, :after, :update_from_filepicker!
      self.send(:"#{attachment_name}=", URI.parse(filepicker_url))
      self.set_metadata
      self.attachment_object.save_with_prepare_enqueueing if FileClip.delayed?
      self.save
      self.enqueue_delayed_processing if FileClip.delayed?
      self.class.set_callback :commit, :after, :update_from_filepicker!
    end

    def set_metadata
      metadata = JSON.parse(::RestClient.get filepicker_url + "/metadata")

      self.send(:"#{attachment_name}_content_type=",  metadata["mimetype"])
      self.send(:"#{attachment_name}_file_name=",     metadata["filename"])
      self.send(:"#{attachment_name}_file_size=",     metadata["size"])
    end

    def update_from_filepicker?
      fileclip_previously_changed? &&
      filepicker_url.present? &&
      !filepicker_only?
    end

    def filepicker_url_not_present?
      !filepicker_url.present?
    end

    def fileclip_previously_changed?
      !(previous_changes.keys.map(&:to_sym) & FileClip.change_keys).empty?
    end

    # To be overridden in model if specific logic for not
    # processing the image
    def filepicker_only?
      false
    end
  end

end