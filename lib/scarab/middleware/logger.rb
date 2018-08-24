# frozen_string_literal: true

module Scarab
    module Middleware
        # Rack middleware for logging which implements a subset of the Apache
        # mod_log formatting options.
        class Logger
            include Scarab::Logging

            # @private
            def initialize(app, format: '', logger: nil)
                @app = app
                @format = format
                @logger = logger
            end

            def call(env)
                req = Request.new(@app, env)
                req.call { log! req }
            end

            def log!(req)
                output = Formatter.format(req, @format)
                logger = @logger || req.logger

                if logger.respond_to? :info
                    logger.info output
                elsif logger.respond_to? :write
                    logger.write output
                else
                    logger << output
                end
            end
        end
    end
end
