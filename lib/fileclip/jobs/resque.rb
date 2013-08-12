module FileClip
  module Jobs
    class Resque
      @queue = :fileclip

      def self.perform(instance_klass, instance_id)
        FileClip.process(instance_klass, instance_id)
      end
    end
  end
end