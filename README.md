# hue-controller
Control your philips hue bridge from your local network.

# Setup

- Put `192.168.X.X hue.local` in your hosts file so that requests to `hue.local` get routed to your hue bridge.

- Then simply execute `./hue.rb` when ready to press the link button on your hue bridge. It will authenticate to the hue and create the necessary credentials config on your computer.

## Getting info about the lights
  - `./hue.rb 1` -- get the whole current state of light number 1
  - `./hue.rb 1 getstate hue` -- get the hue for light number 1
  - `./hue.rb 2 getstate sat` -- get the color saturation for light number 2

## Controlling individual states of a light

`turn on|off`
  - `./hue.rb 1 turn on` -- turn on the first light.
  - `./hue 3 turn off` -- turn off light number 3

`setstate bri|sat|hue {value}`
  - `./hue.rb 1 setstate bri {value}` -- set the brightness between 0 and 254 for light number 1
  - `./hue.rb 3 setstate sat {value}` -- set the color saturation between 0 and 254 for light number 3
  - `./hue.rb 2 setstate hue {value}` -- set the color/hue from 0 to 65535 for light number 2

## Randomize!
  - `./hue.rb 42 randomize` -- set hue/brightness/saturation to random levels for light number 42


# Documentation for hue api
View the [getting started](https://www.developers.meethue.com/documentation/getting-started) guide to see how this is set up.