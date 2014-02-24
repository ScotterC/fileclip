module FileClip
  module Jobs
    class Resque
      @queue = :fileclip

      def self.perform(instance_klass, instance_id, attachment_name)
        FileClip.process(instance_klass, instance_id, attachment_name)
      end
    end
  end
end