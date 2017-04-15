#!/usr/bin/env ruby
# Hue Controller script. Pass arguments to get info or control a hue bridge.

ENV['RUBYLIB'] = '.:..'

require 'json'
require 'hue/lights'
require 'hue/auth'

class ArgumentError < StandardError; end

# Checking for credentials
$USERNAME = ""
$WAIT_TIME = 1
creds_path = "#{Dir.home}/.hue.creds"
if File.file?(creds_path)
	creds = JSON.parse(File.open(creds_path).read)
	# Set username for later api use
	$USERNAME = creds['default']['username']
else
  authenticated = false
  until authenticated == true
    username = ::Hue::Auth.new(secret: 'pre-auth-token').create_user("hue-controller#ruby")
    if username.nil?
      puts("Press the link button on the hue bridge.") if $WAIT_TIME == 1
      sleep($WAIT_TIME)
      print(' ...')
      $WAIT_TIME = $WAIT_TIME * 2
    elsif username.class == String
      puts("Successfully authenticated. Your new api token is: #{username}")
      puts("Writing to config file #{creds_path}.")
      begin
        File.write(creds_path, JSON.generate(default: {username: username}))
      rescue StandardError => e
        puts("Error was: #{e}")
        puts("Write operation failed. Please manually create the file #{creds_path} and put this in it:\n")
        puts("{ \"default\" : {\n  \"username\" : \"#{username}\"\n  }\n}")
        abort('exiting.')
      end
      authenticated = true
    else
      abort('Unexpected route.')
    end
  end
end

# Check that we're connected and have an authenticated user
bridge_name = ::Hue::Auth.new(secret: $USERNAME).check_auth
puts("Successfully authenticated to bridge: #{bridge_name}")

STATES = [ 'on', 'sat', 'hue', 'bri', 'effect' ]
COMMANDS = [ 'turn', 'color', 'setstate', 'getstate', 'randomize' ]

def set_state(light, state, value)
  if STATES.include?(state) && light =~ /[0-9]/
    puts("Setting light number #{light} state #{state} to #{value}")
    value = true if value == 'true'
    value = false if value == 'false'
    value = value.to_i if value =~ /[0-9]/
    status = ::Hue::Lights.new(secret: $USERNAME).set_state_by_lnum(light, state, value)
    puts(status)
  end
end

def run_command(light, command, params)
  command = command.downcase
  puts("Running command #{command} with params: #{params}")
  if command == 'turn'
    if ['on', 'off'].include?(params[0])
      value = params[0] == 'on' ? true : false
      set_state(light, 'on', value)
    end
  end

  # Try to set a manual attribute at your own risk
  if command == 'setstate'
    hue_state = params[0]
    value = params[1]
    if STATES.include?(hue_state)
      set_state(light, hue_state, value)
    else
      abort("Only these states are allowed: #{STATES}")
    end
  end

  # Try to get a specific attribute
  if command == 'getstate'
    hue_state = params[0]
    puts(::Hue::Lights.new(secret: $USERNAME).get_states_by_lnum(light)['state'][hue_state])
  end

  # Set random values for color, saturation, brightness
  if command == 'randomize'
    states = {
      hue: rand(0..65535),
      bri: rand(30..254),
      sat: rand(30..254)
    }
    puts(::Hue::Lights.new(secret: $USERNAME).set_states_by_lnum(light, states))
  end
end

if ARGV[0]
  light=ARGV[0]
end
if ARGV[1]
  if COMMANDS.include?(ARGV[1])
    command = ARGV[1]
    run_command(light, command, ARGV[2..-1])
  end
else
  light_info = ::Hue::Lights.new(secret: $USERNAME).get_states_by_lnum(light)
  puts("Light name: #{light_info['name']} | on? #{light_info['state']['on']}\nAll info:#{light_info}")
end
