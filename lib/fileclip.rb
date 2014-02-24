require 'fileclip/configuration'
require 'fileclip/action_view/helpers'
require 'fileclip/action_view/form_helper'
require 'fileclip/updater'
require 'fileclip/glue'
require 'fileclip/engine'
require 'fileclip/railtie'

module FileClip

  class << self
    def process(klass, instance_id, attachment_name)
      klass.constantize.find(instance_id).process_fileclip!(attachment_name)
    end

    def delay_enabled?
      !!(defined? Resque) ||
      !!(defined? Sidekiq)
    end
  end

  module ClassMethods
    def fileclip(name)
      cattr_accessor :fileclips
      self.fileclips ||= []
      self.fileclips.push name

      after_commit :process_fileclips!
    end

    # Utility method for processing
    def without_fileclip_callback(&block)
      skip_callback :commit, :after, :process_fileclips!
      yield
      set_callback  :commit, :after, :process_fileclips!
    end
  end

  module InstanceMethods
    def process_fileclips!
      self.class.fileclips.each do |attachment_name|
        process_fileclip(attachment_name) if update_fileclip?(attachment_name)
      end
    end

    def process_fileclip(attachment_name)
      FileClip::Updater.new(self, attachment_name).enqueue
    end

    def process_fileclip!(attachment_name)
      FileClip::Updater.new(self, attachment_name).process!
    end

    def fileclip_url_present?(attachment_name)
      return true unless self.class.column_names.include? fileclip_url(attachment_name)
      send(fileclip_url(attachment_name)).present?
    end

    private

    def update_fileclip?(attachment_name)
      fileclip_previously_changed?(attachment_name) &&
      fileclip_url_present?(attachment_name) &&
      !filepicker_only?
    end

    def fileclip_previously_changed?(attachment_name)
      !(previous_changes.keys & [fileclip_url(attachment_name)]).empty?
    end

    def fileclip_url(attachment_name)
      "#{attachment_name}_filepicker_url"
    end

    # To be overridden in model if
    # attachment shouldn't be processed
    def filepicker_only?
      false
    end
  end

end