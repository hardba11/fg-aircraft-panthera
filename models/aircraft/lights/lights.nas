print("*** LOADING lights - lights.nas ... ***");

# namespace : lights

# management of blinking
var strobe = aircraft.light.new("/sim/model/lights/strobe", [0.05, 0.1, 0.05, 1]);
strobe.switch(0);

var beacon = aircraft.light.new("/sim/model/lights/beacon", [0.1, 0.8]);
beacon.switch(0);

var lights = func()
{
    strobe.switch(getprop("/controls/lighting/strobe-lights"));
    beacon.switch(getprop("/controls/lighting/strobe-lights"));

    var is_internal  = getprop("sim/current-view/internal") or 0;
    var is_gear_down = getprop("gear/gear[0]/position-norm") or 0;

    var is_on = 0;

    # disable als lights if exterior view and gear up
    if(is_internal and is_gear_down)
    {
        is_on = getprop("/controls/lighting/landing-lights") or 0;
    }

    # left landing-light
    setprop("/sim/rendering/als-secondary-lights/use-alt-landing-light", is_on);
    # right landing-light
    setprop("/sim/rendering/als-secondary-lights/use-landing-light", is_on);


    settimer(lights, .5);
}

setlistener("sim/signals/fdm-initialized", lights);



