module FileClip
  module Jobs
    class Sidekiq
      include ::Sidekiq::Worker if defined?(::Sidekiq::Worker)

      def perform(instance_klass, instance_id)
        FileClip.process(instance_klass, instance_id)
      end
    end
  end
end