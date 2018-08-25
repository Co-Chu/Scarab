# frozen_string_literal: true

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
            use other
        end

        def self.setup_logging(builder) end
    end
end
