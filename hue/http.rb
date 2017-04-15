# Hue::Http - Methods related to http calls to the bridge api
require 'json'
require 'base64'
require 'net/http'
# $VERBOSE = true

module Hue
  module Api
    Method_PUT = ::Net::HTTP::Put
    Method_POST = ::Net::HTTP::Post

    API_HOST = 'hue.local'
    API_PORT = 80
    class HueApiError < StandardError; end

    attr_accessor :resp, :status
    def http_init
      @http = Net::HTTP.new(API_HOST, API_PORT)
      @http.start
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
        puts("Code: #{@status} | Path: #{path} | Response: #{@resp}") if $VERBOSE
      else
        raise HueApiError.new("Could not poll api. Error: #{http_resp.body}")
      end
    end

    def api_post(path, body, method: ::Hue::Api::Method_POST)
      puts("Doing an http #{method}") if $VERBOSE
      http_init unless @http && @http.started?
      req = method.new(path)
      req['Accept'] = "application/json"
      req['Authorization'] = "Basic #{Base64.strict_encode64(@secret)}"
      req.content_type = "application/json"
      puts("Body: #{body}") if $VERBOSE
      http_resp = @http.request(req, JSON.generate(body))
      if http_resp.code =~ /^2\d\d/
        @resp = JSON.parse(http_resp.body)
        @status = http_resp.code
        puts("Code: #{@status} | Path: #{path} | Response: #{@resp}") if $VERBOSE
      else
        raise HueApiError.new("Could not poll api. Error: #{http_resp.body}")
      end
    end
  end
end
