# frozen_string_literal: true

require 'mustermann'
require 'scarab/app'
require 'sinatra/base'

module Scarab
    # Base class for Scarab controllers
    class Controller < Sinatra::Base
        # Class methods
        module ClassMethods
            # Defines a method 'Controller' on the target which is be used to
            # create subclasses of Controller dynamically with specified
            # settings. Inspired by Sequel's `Sequel::Model()` method.
            def def_controller_method(mod, app: mod, base: self)
                mod.define_singleton_method(:Controller) do |prefix = ''|
                    pattern = Mustermann.new(%r{#{prefix}(/.*)?})
                    Class.new(base) do
                        define_singleton_method(:route_prefix) { prefix }

                        define_singleton_method(:inherited) do |othermod|
                            othermod.set :app_file, caller_files[1]
                            othermod.set :route_pattern, pattern
                            super(othermod)
                            return unless app.respond_to? :register_controller
                            app.register_controller(othermod)
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

            def setup_logging(builder) end
        end

        # Passes control back to the app if the controller is part of a
        # {Scarab::App}, but otherwise acts like a normal Sinatra application.
        def route_missing
            @app.is_a?(App) ? throw(:pass) : super
        end

        # Passes control back to the app if the controller is part of a
        # {Scarab::App}, but otherwise acts like a normal Sinatra application.
        def invoke
            @app.is_a?(App) ? yield : super
        end

        def method_missing(name, *args)
            return super unless @app.is_a?(App) && @app.respond_to?(name)
            @app.send(name, *args)
        end

        def respond_to_missing?(name)
            @app.is_a?(App) ? @app.respond_to?(name) : super
        end

        extend ClassMethods

        def_controller_method(::Scarab, app: Scarab::App)
    end
end
