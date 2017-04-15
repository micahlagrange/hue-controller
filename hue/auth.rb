# Hue::Auth - Methods related to authenticating with the hue api

require 'json'
require 'hue/http'

module Hue
  class Auth
    include Hue::Api
    attr_accessor :resp
    def initialize(secret:)
      @secret = secret
    end

    def check_auth
      api_get("/api/#{@secret}/config")
      if @resp.has_key?('name')
        return @resp['name']
      else
        raise HueApiError.new("Could not fetch bridge name. Authentitcation failure. Message: #{@resp}")
      end
    end

    def create_user(devicetype)
      api_post("/api", devicetype: devicetype)
      # Try initial attempt
      # The api returned an error object
      if @resp[0].has_key?('error')
        err = @resp[0]['error']
        if err['type'] == 101 && err['description'] =~ /link.button/
          # Expecting the user to press the link button here. Return nil
          return nil
        else
          raise HueApiError.new("Did not receive expected response from api. Message: #{@resp}")
        end
      # The api returned a success object
      elsif @resp[0].has_key?('success')
        return @resp[0]['success']['username']
      end
    end
  end
end
