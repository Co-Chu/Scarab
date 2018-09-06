# frozen_string_literal: true

require 'set'
require 'sinatra/base'

module Scarab
    # Container for Scarab controllers
    #
    # Largely exists as a convenience class; controllers can be used in *any*
    # Sinatra application by using `use`.
    class App < Sinatra::Base
        # Internal method called to register controllers
        # @param other [Controller] a Scarab controller
        def self.register_controller(other)
            controllers.add other
        end

        def self.controllers
            @controllers ||= Set.new
        end

        def self.setup_logging(builder); end

        def initialize(app = nil)
            super
            @controllers = self.class.controllers.map do |controller|
                controller.new(self)
            end
        end

        attr_reader :controllers

        # Passes control to any controllers for which the route prefix matches
        # the requested path. Reverts to App-level control if the controller
        # passes or has no matching route.
        def route!(base = settings, pass_block = nil)
            return super unless base == settings
            controllers.each { |controller| check_controller!(controller) }
            super
        end

        # Checks a controller for match and attempts to call if it does.
        def check_controller!(controller)
            if (pattern = controller.settings.route_pattern)
                return unless pattern === request.path_info
            end
            catch(:pass) do
                controller.dup.tap do |c|
                    c.app = self
                end.call!(env)
            end
        end
    end
end
