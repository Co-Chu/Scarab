# frozen_string_literal: true

require 'English'

module Scarab
    module Logging
        # Log formatting utility
        module Formatter
            CLS_TIME_FORMAT = '[%d/%b/%Y:%H:%M:%S %z]'

            def self.formatters
                @formatters ||= {}
            end

            def self.add(fmt, &block)
                formatters[fmt] = block
            end

            def self.format(req, fmt)
                output = +fmt
                @formatters.each do |(regex, block)|
                    next unless output.match? regex
                    output.gsub! regex do |*args|
                        opts = match_hash($LAST_MATCH_INFO)
                        block&.call(req, req.response, *args, **opts) || '-'
                    end
                end
                output
            end

            def self.match_hash(match)
                match.names.map(&:to_sym).zip(match.captures).to_h
            end
        end
    end
end

return if defined?(SCARAB_LOGGER_FORMATTER_DEFAULTS)

SCARAB_LOGGER_FORMATTER_DEFAULTS = true

f = Scarab::Logging::Formatter

# Literal '%'
f.add(/%%/) { '%' }

# Time the request was received, with optional formatting
# This needs to be processed first as it contains other formatting tokens
f.add(/%(?:{(?<format>.*?)})?t/) do |req, _, format:|
    format ||= Scarab::Logging::Formatter::CLS_TIME_FORMAT
    case format
    when 'usec_frac'
        req.start_time.tv_usec.to_s.rjust(6, '0')
    when 'msec_frac'
        (req.start_time.tv_usec / 1_000).floor.to_s.rjust(3, '0')
    when 'usec'
        req.start_time.tv_sec * 1_000_000 + req.start_time.tv_usec
    when 'msec'
        (req.start_time.tv_sec * 1_000 + req.start_time.tv_usec).floor
    when 'sec'
        req.start_time.tv_sec
    else
        req.start_time.strftime(format)
    end
end

# Client IP
f.add(/%a/) { |req| req.env['REMOTE_ADDR'] }

# Originating client IP
f.add(/%{c}a/) do |req|
    req.header['X-Client-IP'] || req.header['X-Real-IP'] || req.ip
end

# Local server IP
f.add(/%A/)

# Size of response in bytes, excluding headers
f.add(/%B/) { |_, res| res.content_length }

# Size of response in bytes, excluding headers; '-' when 0 bytes
f.add(/%b/) do |_, res|
    res.content_length unless res.content_length.to_i.zero?
end

# Contents of cookie in request
f.add(/%{(?<cookie>.*?)}C/) { |req, _, cookie:| req.cookies[cookie] }

# Time taken to serve the request, in microseconds.
f.add(/%D/) do |req, _|
    dt = req.end_time.to_f - req.start_time.to_f
    (dt * 1_000_000).round
end

# Contents of the environment variable varname
f.add(/%{(?<varname>.*?)}e/) { |_, _, varname:| ENV[varname] }

# Filename
f.add(/%f/) { |req, _| req.filename }

# Remote hostname
f.add(/%h/) { |req, _| req.env['REMOTE_HOST'] }

# Request protocol
f.add(/%H/) { |req, _| req.env['HTTP_VERSION'] }

# Contents of request header
f.add(/%{(?<header>.*?)}i/) { |req, _, header:| req.header[header] }

# Number of keep-alive requests on this connection
f.add(/%k/) # unsupported

# Remote logname
f.add(/%l/) # unsupported

# Unique identifier for the request
f.add(/%L/) { |req, _| req.header['X-Request-Id'] || req.hash }

# Request method
f.add(/%m/) { |req, _| req.request_method }

# Contents of key in request environment
f.add(/%{(?<key>.*?)}n/) { |req, _, key:| req.env[key]&.to_s }

# Contents of 'header' response header
f.add(/%{(?<header>.*?)}o/) { |_, res, header:| res.header[header] }

# Canonical port of the server, server's actual port, or client's
# actual port
f.add(/%(?:{(?<type>canonical|local|remote)})?p/) do |req, _, type:|
    type ||= 'canonical'
    case type
    when 'local'
        '-'
    when 'remote'
        '-'
    when 'canonical'
        req.port
    else
        '-'
    end
end

# Process ID of the child that serviced the request
f.add(/%(?:{(?<format>pid|tid|hextid)})P/)

# Query string beginning with '?' if present, otherwise empty
f.add(/%q/) { |req, _| req.query_string }

# First line of the request
f.add(/%r/) { |req, _| req.request_line }

# Handler generating the response
f.add(/%R/) do |req, _|
    next if req.env['scarab.server'].nil?
    req.env['scarab.server'].server.to_s.split('::').last
end

# Status of the original request
f.add(/%[<>]?s/) { |_, res| res.status }

# Time taken to serve the request in seconds, milliseconds, or
# microseconds
f.add(/%(?:{(?<unit>[mu]?s)})?T/) do |req, _, unit:|
    unit ||= 's'
    dt = req.end_time - req.start_time
    case unit
    when 'us'
        (dt * 1_000_000).floor
    when 'ms'
        (dt * 1_000).round
    when 's'
        (dt * 1_000).round / 1_000
    else
        '-'
    end
end

# Remote user if the request was authenticated
f.add(/%[<>]?u/) { |req| req.env['REMOTE_USER'] }

# URL path requested, not including query string
f.add(/%U/) { |req, _| req.path_info }

# Canonical server hostname - identical to %V
f.add(/%v/) { |req, _| req.host }

# Server name
f.add(/%V/) { |req, _| req.host }

# Connection status when response is completed,
#   X = aborted
#   + = may be kept alive
#   - = will be closed
f.add(/%X/) # @todo Decide whether or not this should be supported

# Bytes received, including request and headers; cannot be 0
f.add(/%I/) # @todo Implement this

# Bytes sent, including headers
f.add(/%O/) # @todo Implement this

# Bytes transferred (received + sent) including headers)
f.add(/%S/) # @todo Implement this

# Contents of varname trailer line in request
f.add(/%{(?<varname>.*?)}^ti/) # unsupported

# Contents of varname trailer line in response
f.add(/%{(?<varname>.*?)}^to/) # unsupported
