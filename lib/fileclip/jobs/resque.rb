module FileClip
  module Jobs
    class Resque
      @queue = :fileclip

      def self.enqueue_fileclip(instance, attachment_name)
        ::Resque.enqueue(FileClip::Jobs::Resque,
                         instance.class.name,
                         instance.id,
                         attachment_name)
      end

      def self.perform(instance_klass, instance_id, attachment_name)
        FileClip.process(instance_klass, instance_id, attachment_name)
      end
    end
  end
end