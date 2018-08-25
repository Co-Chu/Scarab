# frozen_string_literal: true

require 'rack'

module Scarab
    # Utility extension of Rack::Server
    class Server < Rack::Server
        def build_app(app)
            Middleware::ServerAware.new(super, self)
        end

        def self.default_middleware_by_environment
            Hash[super.map do |k, v|
                [k, [Middleware::RequestId] + v]
            end]
        end

        def self.logging_middleware
            nil
        end

        def start(&block)
            super do |server|
                @handler = server
                yield server if block_given?
            end
        end

        attr_reader :handler
    end
end
