require 'fileclip/configuration'
require 'fileclip/action_view/helpers'
require 'fileclip/validators'
require 'fileclip/engine'
require 'fileclip/railtie'
require 'fileclip/jobs/resque'
require 'fileclip/jobs/sidekiq'
require 'rest-client'

# TODO: make fileclip methods only load on fileclipped models

module FileClip
  mattr_accessor :change_keys

  class << self

    def process(klass, instance_id, name)
      klass.constantize.find(instance_id).send("process_#{name}_from_filepicker")
    end

    # TODO: replace with checking for delayed options?
    def delayed?
      defined?(DelayedPaperclip)
    end

    def resque_enabled?
      !!(defined? Resque)
    end

    def sidekiq_enabled?
      !!(defined? Sidekiq)
    end
  end

  module Glue
    def self.included(base)
      base.extend ClassMethods
      base.extend FileClip::Validators::HelperMethods
    end
  end

  module ClassMethods
    def fileclip(name)
      attr_accessible "#{name}_filepicker_url".to_sym
      after_commit  "update_#{name}_from_filepicker!".to_sym

      set_fileclipped(name)
    end

    def set_fileclipped(name)

      class_eval <<-RUBY
      
        def update_#{name}_from_filepicker!
          if update_#{name}_from_filepicker?
            if FileClip.resque_enabled?
              # TODO: self.class.name is webrick ???
              process_#{name}_with_resque!
            elsif FileClip.sidekiq_enabled?
              process_#{name}_with_sidekiq!
            else
              process_#{name}_from_filepicker
            end
          end
        end
  
        def process_#{name}_with_resque!
          update_column(:#{name}_processing, true) if FileClip.delayed?
          ::Resque.enqueue(FileClip::Jobs::Resque, self.class.name, self.id, :#{name})
        end
  
        def process_#{name}_with_sidekiq!
          update_column(:#{name}_processing, true) if FileClip.delayed?
          FileClip::Jobs::Sidekiq.perform_async(self.class.name, self.id, :#{name})
        end
  
        def process_#{name}_from_filepicker
          self.class.skip_callback :commit, :after, :update_#{name}_from_filepicker!
          self.send(:#{name}=, URI.parse(#{name}_filepicker_url))
          self.set_#{name}_metadata
          self.send(:#{name}).save_with_prepare_enqueueing if FileClip.delayed?
          self.save
          self.enqueue_delayed_processing if FileClip.delayed?
          self.class.set_callback :commit, :after, :update_#{name}_from_filepicker!
        end
  
        def set_#{name}_metadata
          result = ::RestClient.get(#{name}_filepicker_url + "/metadata")
          metadata = JSON.parse(result)
  
          self.send("#{name}_content_type=",  metadata["mimetype"])
  
          # Delegate to paperclips filename cleaner
          filename = self.send(:#{name}).send(:cleanup_filename, metadata["filename"])
          self.send(:#{name}_file_name=,     filename)
  
          self.send(:#{name}_file_size=,     metadata["size"])
        end
  
        def update_#{name}_from_filepicker?
          #{name}_fileclip_previously_changed? &&
              #{name}_filepicker_url.present? &&
              !#{name}_filepicker_only?
        end
  
        def #{name}_filepicker_url_not_present?
          return true unless self.class.column_names.include? "#{name}_filepicker_url"
          !#{name}_filepicker_url.present?
        end
  
        def #{name}_fileclip_previously_changed?
          !(previous_changes.keys.map(&:to_sym) & [:#{name}_filepicker_url]).empty?
        end
  
        # To be overridden in model if specific logic for not
        # processing the image
        def #{name}_filepicker_only?
          false
        end

      RUBY
      
    end
  end

end