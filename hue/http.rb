# Hue::Http - Methods related to http calls to the bridge api
require 'json'
require 'base64'
require 'net/http'
$VERBOSE = true if ENV['VERBOSE'] == 'true'

module Hue
  module Api
    Method_PUT = ::Net::HTTP::Put
    Method_POST = ::Net::HTTP::Post

    API_HOST = 'hue.local'
    API_PORT = 80

    def self.port
      # To use a different port, in your code do:
      # ::Hue::Api.port = 'other.hostname'
      @port || API_PORT
    end

    def self.port=(value)
      @port = value
    end

    def self.hostname
      # To use a different host, in your code do:
      # ::Hue::Api.hostname = 'other.hostname'
      @hostname || API_HOST
    end

    def self.hostname=(value)
      @hostname = value
    end

    class HueApiError < StandardError; end

    attr_accessor :resp, :status
    def http_init
      @http = Net::HTTP.new(::Hue::Api.hostname, ::Hue::Api.port)
      @http.start
    end

    def check_response
      if @resp.any? { |r| r.class == Hash && r.has_key?('error') }
        raise HueApiError.new("Errors receieved from hue api: #{@resp.map {|r| r['error']['description']}}")
      end
    end

    def api_get(path)
      http_init unless @http && @http.started?
      req = Net::HTTP::Get.new(path)
      req['Accept'] = "application/json"
      req.content_type = "application/json"
      http_resp = @http.request(req)
      if http_resp.code =~ /^2\d\d/
        @resp = JSON.parse(http_resp.body)
        @status = http_resp.code
        puts("Host: #{::Hue::Api.hostname}:#{::Hue::Api.port} | Code: #{@status} | Path: #{path} | Response: #{@resp}") if $VERBOSE
        check_response
      else
        raise HueApiError.new("Could not poll api at: #{::Hue::Api.hostname}:#{::Hue::Api.port}. Error: #{http_resp.body}")
      end
    end

    def api_post(path, body, method: ::Hue::Api::Method_POST)
      puts("Doing an http #{method}") if $VERBOSE
      http_init unless @http && @http.started?
      req = method.new(path)
      req['Accept'] = "application/json"
      req.content_type = "application/json"
      puts("Body: #{body}") if $VERBOSE
      http_resp = @http.request(req, JSON.generate(body))
      if http_resp.code =~ /^2\d\d/
        @resp = JSON.parse(http_resp.body)
        @status = http_resp.code
        puts("Host: #{::Hue::Api.hostname}:#{::Hue::Api.port} | Code: #{@status} | Path: #{path} | Response: #{@resp}") if $VERBOSE
        check_response
      else
        raise HueApiError.new("Could not poll api at: #{::Hue::Api.hostname}:#{::Hue::Api.port}. Error: #{http_resp.body}")
      end
    end
  end
end
