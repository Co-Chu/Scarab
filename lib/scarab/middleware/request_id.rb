# frozen_string_literal: true

require 'securerandom'

module Scarab
    module Middleware
        # Middleware which injects the server into the request environment
        class RequestId
            def initialize(app, &block)
                @app = app
                @generator = block || proc { SecureRandom.uuid }
            end

            def call(env)
                id = env['HTTP_X_REQUEST_ID'] ||= @generator.call
                status, headers, body = @app.call(env)
                headers['X-Request-ID'] = id
                [status, headers, body]
            end
        end
    end
end
