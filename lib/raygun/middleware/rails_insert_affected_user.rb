module Raygun
  module Middleware
    # Adapted from the Rollbar approach https://github.com/rollbar/rollbar-gem/blob/master/lib/rollbar/middleware/rails/rollbar_request_store.rb
    class RailsInsertAffectedUser

      def initialize(app)
        @app = app
      end

      def call(env)
        response = @app.call(env)
      rescue Exception => exception
        if (controller = env["action_controller.instance"]) && controller.respond_to?(Raygun.configuration.affected_user_method, true)
          user = controller.send(Raygun.configuration.affected_user_method)

          if user
            methods = Raygun.configuration.affected_user_identifier_methods
            if methods.is_a?( Hash )
              data = {}
              methods.each_pair do |raygun_key, user_method|
                data[raygun_key] = user.send(user_method) if user.respond_to?( user_method )
              end
            else
              identifier = if (m = methods.detect { |m| user.respond_to?(m) })
                user.send(m)
              else
                user
              end
              data = { identifier: identifier }
            end

            env["raygun.affected_user"] = data
          end
          
        end
        raise exception
      end

    end
  end
end