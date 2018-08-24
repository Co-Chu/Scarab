# frozen_string_literal: true

# Scarab
#
# Scarab is a lightweight web routing framework built on Sinatra, similar to
# Sinatra's "namespace" plugin.
#
# @author Matthew Lanigan <rintaun@gmail.com>
# @since 1.0.0
module Scarab
    # Various utility middleware used by Scarab
    module Middleware
        require 'scarab/middleware/request_id'
        require 'scarab/middleware/server_aware'
    end

    require 'scarab/app'
    require 'scarab/controller'
    require 'scarab/server'
    require 'scarab/version'
end
