# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'scarab/version'

Gem::Specification.new do |spec|
    spec.name          = 'scarab'
    spec.version       = Scarab::VERSION
    spec.authors       = ['Matthew Lanigan']
    spec.email         = ['rintaun@gmail.com']

    spec.summary       = 'A lightweight web routing framework for Sinatra.'
    spec.description   = <<~DESCRIPTION
        Scarab is a lightweight web routing framework built on Sinatra, similar
        to Sinatra's "namespace" plugin.
    DESCRIPTION
    spec.homepage      = 'https://github.com/Co-Chu/Scarab'
    spec.license       = 'MIT'

    spec.files         = Dir.chdir(File.expand_path('.', __dir__)) do
        `git ls-files -z`.split("\x0")
                         .reject { |f| f.match(%r{^(test|spec|features)/}) }
    end
    spec.bindir        = 'bin'
    spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
    spec.require_paths = ['lib']

    spec.add_development_dependency 'bundler', '~> 1.16'
    spec.add_development_dependency 'rspec', '~> 3.0'
    spec.add_development_dependency 'yard', '~> 0.9'

    spec.add_dependency 'sinatra', '~> 2.0'
end
