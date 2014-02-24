require 'fileclip/validators'

module FileClip
  module Glue
    def self.included(base)
      base.extend ClassMethods
      base.send :include, InstanceMethods
      base.send :include, Validators
    end
  end
end