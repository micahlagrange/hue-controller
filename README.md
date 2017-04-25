# hue-controller
Control your philips hue bridge from your local network.

# Setup

- Ruby >= 2.3 should be installed, but older might be ok

- Put `192.168.X.X hue.local` in your hosts file so that requests to `hue.local` get routed to your hue bridge.
- Optionally create `~/.hue.config` with:
`{"default":{"hostname":"some.dns.entry", "port":"some.port"}}`

- Then simply execute `./hue.rb` when ready to press the link button on your hue bridge. It will authenticate to the hue and create the necessary credentials config on your computer:

```
$ ./hue.rb
Press the link button on the hue bridge.
 ... ... ... ...Successfully authenticated. Your new api token is: opEVP6wurpAyrCsE6mIQY5aL
Writing to config file /Users/USERNAME/.hue.creds.
```
- Optionally if you already have an auth token, create `~/.hue.creds` with:
`{"default":{"username":"20q4tq9038arghtaser89ohgitaewrgt"}}`

## Getting info about the lights
```
$ ./hue.rb 1
Selected lights: [1]
Light: 1 name: Micah's night stand | on? true
All info:{"state"=>{"on"=>true, "bri"=>254, "hue"=>7676, "sat"=>199, "effect"=>"none", "xy"=>[0.5016, 0.4151], "ct"=>443, "alert"=>"none", "colormode"=>"xy", "reachable"=>true}, "type"=>"Extended color light", "name"=>"Bob's night stand", "modelid"=>"LCT014", "manufacturername"=>"Philips", "uniqueid"=>"00:11:89:03:12:76:36:n1-1f", "swversion"=>"1.15.2_r19181", "swconfigid"=>"A315E69E", "productid"=>"Philips-LCT014-1-A19ECLv4"}
```

```
$ ./hue.rb bedroom
Selected groups: [1]
Group: 1 | name: Bedroom | All info: {"name"=>"Bedroom", "lights"=>["1", "3"], "type"=>"Room", "state"=>{"all_on"=>true, "any_on"=>true}, "recycle"=>false, "class"=>"Bedroom", "action"=>{"on"=>true, "bri"=>254, "hue"=>7676, "sat"=>199, "effect"=>"none", "xy"=>[0.5016, 0.4151], "ct"=>443, "alert"=>"none", "colormode"=>"xy"}}
```

## Controlling individual states of a light

`turn on|off`
  - `./hue.rb 1 turn on` -- turn on the first light.
  - `./hue 3 turn off` -- turn off light number 3

`setstate bri|sat|hue {value}`
  - `./hue.rb 1 set bri {value}` -- set the brightness between 0 and 254 for light number 1
  - `./hue.rb 3 set sat {value}` -- set the color saturation between 0 and 254 for light number 3
  - `./hue.rb 2 set hue {value}` -- set the color/hue from 0 to 65535 for light number 2

```
$ ./hue.rb 1 set hue 55535
Successfully authenticated to bridge: Philips hue
Running command setstate with params: ["hue", "55535"]
Setting light number 1 state hue to 55535
```

## Randomize!
  - `./hue.rb 42 randomize` -- set hue/brightness/saturation to random levels for light number 42

```
$ ./hue.rb 1 randomize
Successfully authenticated to bridge: Philips hue
Running command randomize
Brightness: 225 | Hue: 57739 | Saturation: 197
```


# Documentation for hue api
View the [getting started](https://www.developers.meethue.com/documentation/getting-started) guide to see how this is set up.
