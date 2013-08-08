module FileClip
  class Railtie
    # Glue includes FileClip into ActiveRecord
    # TODO: only include it in models that have paperclip attachments
    # Will require restart of server for it to pick up the class on edit
    def self.insert
      ::ActiveRecord::Base.send(:include, FileClip::Glue)
      ::Paperclip::Validators::ClassMethods.send(:include, FileClip::Validators)
    end
  end
end