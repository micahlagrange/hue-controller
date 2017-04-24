# Hue::Lights - Methods related to controlling or getting info on hue bridge lights

require 'json'
require 'hue/http'

module Hue
  RED = 0
  YELLOW = 12750
  GREEN = 25500
  MAGENTA = 40604
  BLUE = 46920
  DARKRED = 47104
  PURPLE = 53311
  AQUAMARINE = 35903
  ORANGE = 53311
  PINK = 56100

  class ColorNotFoundError < StandardError; end

  def self.color(name)
    dname = name.downcase
    return case dname
    when 'red'
      then ::Hue::RED
    when 'darkred'
      then ::Hue::DARKRED
    when 'dark red'
      then ::Hue::DARKRED
    when 'orange'
      then ::Hue::ORANGE
    when 'yellow'
      then ::Hue::YELLOW
    when 'green'
      then ::Hue::GREEN
    when 'blue'
      then ::Hue::BLUE
    when 'pink'
      then ::Hue::PINK
    when 'aqua'
      then ::Hue::AQUAMARINE
    when 'aquamarine'
      then ::Hue::AQUAMARINE
    when 'purple'
      then ::Hue::PURPLE
    when 'magenta'
      then ::Hue::MAGENTA
    else
      raise ColorNotFoundError.new("No color '#{dname}'")
    end
  end

  class Lights
    BRIGHTNESS = 'bri'
    SATURATION = 'sat'
    HUE = 'hue'
    MAX_BRIGHTNESS = '254'
    MAX_SATURATION = '254'
    MAX_HUE = '65535'

    include Hue::Api
    attr_accessor :resp
    def initialize(secret:)
      @secret = secret
    end

    def lights
      api_get("/api/#{@secret}/lights")
      @resp
    end

    def light_numbers
      lights.keys.map {|id| id.to_i}
    end

    def select_light(name)
      lights.select {|id,l| l if l['name'].downcase == name}
    end

    def rooms
      api_get("/api/#{@secret}/groups")
      @resp
    end

    def room_ids(name)
      select_room(name).keys.map {|id| id.to_i}
    end

    def select_room(name)
      rooms.select {|id,r| r if r['name'].downcase == name}
    end

    def room_lights(name)
      room(name).map {|id,r| r['lights'].map {|id| id.to_i }}.flatten
    end

    def get_states_by_lnum(light_number)
      api_get("/api/#{@secret}/lights/#{light_number}")
      @resp
    end

    def get_states_by_group(group)
      api_get("/api/#{@secret}/groups/#{group}")
      @resp
    end

    def group_color(group_id, name)
      if hue_color = ::Hue.color(name)
        set_states_by_group(group_id, ::Hue::Lights::HUE => hue_color)
      else
        raise StandardError.new("This is awkward.")
      end
    end

    def all_off
      # Turn off group 0 (all lights)
      set_states_by_group(0, on: false)
    end

    def all_on
      # Turn on group 0 (all lights)
      set_states_by_group(0, on: true)
    end

    def all_bright
      # Make all lights on and 100% BRIGHTNESS
      states = {::Hue::Lights::BRIGHTNESS => 254, ::Hue::Lights::SATURATION => 40, ::Hue::Lights::HUE => 8402}
      states['on'] = true
      set_states_by_group(0, states)
    end

    def all_dim
      # Make all lights on and 100% BRIGHTNESS
      states = percent_of_max(::Hue::Lights::BRIGHTNESS => 50, ::Hue::Lights::SATURATION => 20, ::Hue::Lights::HUE => 50)
      states['on'] = true
      set_states_by_group(0, states)
    end

    def set_state_by_lnum(light_number, state, value)
      api_post("/api/#{@secret}/lights/#{light_number}/state", {state => value}, method: ::Hue::Api::Method_PUT)
    end

    def set_states_by_lnum(light_number, states)
      api_post("/api/#{@secret}/lights/#{light_number}/state", states, method: ::Hue::Api::Method_PUT)
    end

    def set_states_by_group(group, states)
      api_post("/api/#{@secret}/groups/#{group}/action", states, method: ::Hue::Api::Method_PUT)
    end

    def percent_of_max_by_lnum(light_number, doc)
      set_states_by_lnum(light_number, percent_of_max(doc))
    end

    def percent_of_max(doc)
      converted_doc = {}
      doc.keys.each do |k|
        puts("Converting #{k}")
        if k.to_s == ::Hue::Lights::BRIGHTNESS
          max = ::Hue::Lights::MAX_BRIGHTNESS.to_f
        elsif k.to_s == ::Hue::Lights::SATURATION
          max = ::Hue::Lights::MAX_SATURATION.to_f
        elsif k.to_s == ::Hue::Lights::HUE
          max = ::Hue::Lights::MAX_HUE.to_f
        else
          raise ::Hue::Api::HueApiError.new("Tried to get a percentage without a maximum number for value #{k}")
        end
        # Convert the percentage to the real value
        converted_doc[k] = (doc[k].to_f / 100 * max).to_i
      end
      return converted_doc
    end
  end
end
