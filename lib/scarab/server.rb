# frozen_string_literal: true

require 'rack'

module Scarab
    # Utility extension of Rack::Server
    class Server < Rack::Server
        def start(&block)
            super do |server|
                @handler = server
                yield server if block_given?
            end
        end

        attr_reader :handler
    end
end
