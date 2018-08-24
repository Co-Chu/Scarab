# frozen_string_literal: true

require 'rack/request'
require 'rack/response'
require 'rack/utils'

module Scarab
    module Logging
        # Per-request encapsulation to track information necessary for logging
        class Request < Rack::Request
            def initialize(app, env)
                @app = app
                super(env)
                @env_initial = env.dup
                hash = Hash[*env.select { |k, _| k.start_with? 'HTTP_' }
                                .map { |k, v| [k.sub(/^HTTP_/, ''), v] }
                                .map { |k, v| [k.split('_').join('-'), v] }
                                .sort
                                .flatten]
                @header = Rack::Utils::HeaderHash.new(hash)
            end

            def call
                @start_time = Time.now
                status, header, body = @app.call(env)
                @finish_time = Time.now

                @response = Rack::Response.new(body, status, header)
                req = self
                @response.finish do
                    req.end_time = Time.now
                    yield if block_given?
                end
            end

            attr_reader :response, :start_time, :finish_time, :header
            attr_accessor :end_time

            def filename
                path_info[-1] == '/' ? nil : File.basename(path_info)
            end

            def request_line
                format(
                    '%<method>s %<path>s%<query>s %<http_version>s',
                    method: request_method,
                    path: path_info,
                    query: query_string,
                    http_version: env['HTTP_VERSION']
                )
            end

            def query_string
                qs = super
                return if qs.empty?
                '?' + qs
            end
        end
    end
end
