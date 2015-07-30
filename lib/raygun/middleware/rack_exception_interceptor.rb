module Raygun
  module Middleware
    class RackExceptionInterceptor

      def initialize(app)
        @app = app
      end

      def call(env)
        response = @app.call(env)
      rescue Exception => exception
        if (controller = env["action_controller.instance"]) && controller.respond_to?(:raygun_before_send, true)
          env[:custom_handler] = controller
        end
        Raygun.track_exception(exception, env)
        raise exception
      end

    end
  end
end