# frozen_string_literal: true

module Scarab
    module Middleware
        # Middleware which injects the server into the request environment
        class ServerAware
            def initialize(app, server)
                @app = app
                @server = server
            end

            def call(env)
                env = env.merge('scarab.server' => @server)
                @app.call(env)
            end
        end
    end
end
