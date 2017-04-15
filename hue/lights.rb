# Hue::Lights - Methods related to controlling or getting info on hue bridge lights

require 'json'
require 'hue/http'

module Hue
  class Lights
    include Hue::Api
    attr_accessor :resp
    def initialize(secret:)
      @secret = secret
    end

    def get_states_by_lnum(light_number)
      api_get("/api/#{@secret}/lights/#{light_number}")
      @resp
    end

    def set_state_by_lnum(light_number, state, value)
      api_post("/api/#{@secret}/lights/#{light_number}/state", {state => value}, method: ::Hue::Api::Method_PUT)
    end

    def set_states_by_lnum(light_number, states)
      api_post("/api/#{@secret}/lights/#{light_number}/state", states, method: ::Hue::Api::Method_PUT)
    end
  end
end
