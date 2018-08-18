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

                        def self.extended(child)
                            return unless mod.respond_to? :register_controller
                            mod.register_controller(child)
                        end
                    end
                end
            end
        end

        %i[get put post delete head options patch link unlink].each do |verb|
            define_method(verb) do |path = '', **options, &block|
                super(path, options, &block)
            end
        end

        def route(verb, path, options = {}, &block)
            if self.class.respond_to? :route_prefix
                path.prepend self.class.route_prefix
            end
            super
        end

        extend ClassMethods

        def_controller_method(::Scarab)
    end
end
