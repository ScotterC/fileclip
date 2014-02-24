module FileClip
  module Jobs
    class Sidekiq
      include ::Sidekiq::Worker if defined?(::Sidekiq::Worker)

      def self.enqueue_fileclip(instance, attachment_name)
        FileClip::Jobs::Sidekiq.perform_async(instance.class.name,
                                              instance.id,
                                              attachment_name)
      end

      def perform(instance_klass, instance_id, attachment_name)
        FileClip.process(instance_klass, instance_id, attachment_name)
      end
    end
  end
end