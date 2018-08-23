# Scarab

Scarab is a lightweight web routing framework built on Sinatra, similar to
Sinatra's "namespace" plugin.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'scarab', git: 'https://github.com/Co-Chu/Scarab'
```

And then execute:

    $ bundle

## Usage

```ruby
require 'scarab'

class UserController < Scarab::Controller('/users')
    get do # GET /users
        # do something here...
    end

    get '/:id' do # GET /users/:id
        # do something here...
    end
end

class SessionController < Scarab::Controller('/sessions')
    post do # POST /sessions
        # do something here...
    end

    delete '/:id' do # DELETE /sessions/:id
        # do something here...
    end
end

Scarab::App.run
```

Controllers and apps are just normal Sinatra modular applications and should be
able to use anything that you would expect to be able to use with Sinatra. They
are fully encapsulated from each other, and automatically registered with the
`Scarab::App` container application.

## Contributing

Bug reports and pull requests are welcome at [Scarab on GitHub][github]. This
project is intended to be a safe, welcoming space for collaboration, and
contributors are expected to adhere to the [Contributor Covenant][covenant] code
of conduct.

## License

The gem is available as open source under the terms of the
[MIT License][license].

## Code of Conduct

Everyone interacting in the Scarab project’s codebases, issue trackers, chat
rooms and mailing lists is expected to follow the [code of conduct][conduct].

[github]: https://github.com/Co-Chu/Scarab
[covenant]: http://contributor-covenant.org
[license]: https://github.com/Co-Chu/Scarab/blob/master/LICENSE.md
[conduct]: https://github.com/Co-Chu/Scarab/blob/master/CODE_OF_CONDUCT.md
