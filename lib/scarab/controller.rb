# frozen_string_literal: true

require 'sinatra/base'

module Scarab
    # Base class for Scarab controllers
    class Controller < Sinatra::Base
        # Class methods
        module ClassMethods
            # Defines a method 'Controller' on the target which is be used to
            # create subclasses of Controller dynamically with specified
            # settings. Inspired by Sequel's `Sequel::Model()` method.
            def def_controller_method(mod, base = self)
                mod.define_singleton_method(:Controller) do |prefix = ''|
                    Class.new(base) do
                        define_singleton_method(:route_prefix) { prefix }

                        define_singleton_method(:inherited) do |othermod|
                            super(othermod)
                            return unless mod.respond_to? :register_controller
                            mod.register_controller(othermod)
                        end
                    end
                end
            end

            %i[get put post delete head options patch link unlink].each do |vrb|
                define_method(vrb) do |path = '', **options, &block|
                    super(path, options, &block)
                end
            end

            def route(verb, path, **options, &block)
                path = route_prefix + path if respond_to? :route_prefix
                if respond_to? :logger
                    logger.debug "Registering route #{verb} #{path}"
                end
                super(verb, path, options, &block)
            end
        end

        extend ClassMethods

        def_controller_method(::Scarab)
    end
end
