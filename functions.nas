print("*** LOADING my_aircraft_functions - functions.nas ... ***");

# namespace : my_aircraft_functions

#===============================================================================
#                                                                    CONVERSIONS

# inHg to hPa
var INHG2HPA = 33.86389;

# farenheit to celsius
var DF2DC = func(DF)
{
    if(! DF) DF = 0;
    var out = ((DF - 32) / 1.8);
    return out;
}

# celsius to farenheit
var DC2DF = func(DC)
{
    if(! DC) DC = 0;
    return (DC * 1.8) + 32;
}

var LBS2KG = 0.45359237;


#===============================================================================
#                                                                         INPUTS
# used in include/input-properties.xml

var throttle_mouse = func() {
    # throttle only if center mouse button pressed
    if(! getprop("/devices/status/mice/mouse[0]/button[1]"))
    {
        return;
    }

    var delta = cmdarg().getNode("offset").getValue() * -4;
    var thr0_value = getprop("/controls/engines/engine[0]/throttle") or 0;
    var thr1_value = getprop("/controls/engines/engine[1]/throttle") or 0;

    var new_thr0_value = thr0_value + delta;
    var new_thr1_value = thr1_value + delta;
    if(size(arg) > 0)
    {
        new_thr0_value = -new_thr0_value;
        new_thr1_value = -new_thr1_value;
    }
    setprop("/controls/engines/engine[0]/throttle", new_thr0_value);
    setprop("/controls/engines/engine[1]/throttle", new_thr1_value);
}

var inc_throttle = func() {

    var lock_speed = getprop("/autopilot/locks/speed");
    if(lock_speed)
    {
        var node = props.globals.getNode("/autopilot/settings/target-speed-kt", 1);
        if(node.getValue() == nil)
        {
            node.setValue(0.0);
        }
        node.setValue(node.getValue() + arg[1]);
        if(node.getValue() < 0.0)
        {
            node.setValue(0.0);
        }
    }
    else
    {
        var thr0_value = getprop("/controls/engines/engine[0]/throttle") or 0;
        var thr1_value = getprop("/controls/engines/engine[1]/throttle") or 0;

        var new_thr0_value = thr0_value + arg[0];
        var new_thr1_value = thr1_value + arg[0];

        new_thr0_value = (new_thr0_value < -1.0) ? -1.0 : (new_thr0_value > 1.0) ? 1.0 : new_thr0_value;
        new_thr1_value = (new_thr1_value < -1.0) ? -1.0 : (new_thr1_value > 1.0) ? 1.0 : new_thr1_value;
        setprop("/controls/engines/engine[0]/throttle", new_thr0_value);
        setprop("/controls/engines/engine[1]/throttle", new_thr1_value);
    }
}

var inc_elevator = func() {

    var lock_alt = getprop("/autopilot/locks/altitude") or '';
    if(lock_alt == 'altitude-hold')
    {
        var node = props.globals.getNode("/autopilot/settings/target-altitude-ft", 1);
        if(node.getValue() == nil)
        {
            node.setValue(0.0);
        }
        node.setValue(node.getValue() + arg[1]);
        if(node.getValue() < 0)
        {
            node.setValue(0);
        }
        else if(node.getValue() > 40000)
        {
            node.setValue(40000);
        }
    }
    else
    {
        var elevator_value = getprop("/controls/flight/elevator") or 0;
        var new_elevator_value = elevator_value + arg[0];

        new_elevator_value = (new_elevator_value < -1.0) ? -1.0 : (new_elevator_value > 1.0) ? 1.0 : new_elevator_value;
        setprop("/controls/flight/elevator", new_elevator_value);
    }
}

var inc_aileron = func() {

    var lock_hdg = getprop("/autopilot/locks/heading") or '';
    if(lock_hdg == 'dg-heading-hold')
    {
        var node = props.globals.getNode("/autopilot/settings/heading-bug-deg", 1);
        if(node.getValue() == nil)
        {
            node.setValue(0.0);
        }
        node.setValue(node.getValue() + arg[1]);
        if(node.getValue() < 0)
        {
            node.setValue(node.getValue() + 360.0);
        }
        elsif(node.getValue() > 360.0)
        {
            node.setValue(node.getValue() - 360.0);
        }
    }
    else
    {
        var aileron_value = getprop("/controls/flight/aileron") or 0;
        var new_aileron_value = aileron_value + arg[0];

        new_aileron_value = (new_aileron_value < -1.0) ? -1.0 : (new_aileron_value > 1.0) ? 1.0 : new_aileron_value;
        setprop("/controls/flight/aileron", new_aileron_value);
    }
}

var center_flight_controls = func() {
    setprop("/controls/flight/elevator", 0);
    setprop("/controls/flight/aileron", 0);
    setprop("/controls/flight/rudder", 0);
}

var center_flight_controls_trim = func() {
    setprop("/controls/flight/elevator-trim", 0);
    setprop("/controls/flight/aileron-trim", 0);
    setprop("/controls/flight/rudder-trim", 0);
}


var event_toggle_lights = func() {
    var beacon = getprop("/controls/lighting/beacon") or 0;
    var nav    = getprop("/controls/lighting/nav-lights") or 0;
    var pos    = getprop("/controls/lighting/pos-lights") or 0;
    var strobe = getprop("/controls/lighting/strobe") or 0;

    var toggle_lights = ((beacon * nav * pos * strobe) == 0) ? 1 : 0;

    setprop("/controls/lighting/beacon",     toggle_lights);
    setprop("/controls/lighting/nav-lights", toggle_lights);
    setprop("/controls/lighting/pos-lights", toggle_lights);
    setprop("/controls/lighting/strobe",     toggle_lights);
}

var event_toggle_landing_lights = func() {
    var taxi = getprop("/controls/lighting/taxi-light") or 0;

    var toggle_lights = (taxi == 0) ? 1 : 0;

    setprop("/controls/lighting/taxi-light", toggle_lights);
}

var event_smoke = func(do_enable) {
    var is_smokepod_installed = getprop("/sim/model/wing-pylons-smoke-pod") or 0;
    var is_smoking = getprop("/sim/model/smoking") or 0;

    if(is_smokepod_installed == 1)
    {
        if(do_enable == -1)
        {
            # do_enable == -1 : toggle
            do_enable = (is_smoking == 0) ? 1 : 0;
        }
        setprop("/sim/model/smoking", do_enable);
    }
}

var event_acknowledge_master_caution = func() {
    setprop("/instrumentation/my_aircraft/command_h/ack_alert", 1);
}

var event_swap_sfd_screen = func() {
    var current_screen = getprop("/instrumentation/my_aircraft/sfd/controls/display_sfd_screen") or '';

    # first click : alert remain (master caution no blinking and alert-sound disabled) :
    if(current_screen == 'EICAS')
    {
        setprop("/instrumentation/my_aircraft/sfd/controls/display_sfd_screen", 'RADAR');
    }
    # second click : reinit
    elsif(current_screen == 'RADAR')
    {
        setprop("/instrumentation/my_aircraft/sfd/controls/display_sfd_screen", 'EICAS');
    }
}

var event_toggle_launchbar = func(do_enable) {
    var is_carrier_equiped = getprop("/sim/model/carrier-equipment") or 0;
    if(is_carrier_equiped != 1) { return; }

    var is_launchbar_enabled = getprop("/controls/gear/launchbar") or 0;
    if(do_enable == -1)
    {
        # do_enable == -1 : toggle
        do_enable = (is_launchbar_enabled == 0) ? 1 : 0;
    }

    if(do_enable == 1)
    {
        # lower launchbar
        setprop("/controls/gear/launchbar", 1);

        # raise launchbar if could not have engaged
        settimer(func() {
            var state_launchbar = getprop("/gear/launchbar/state") or ''; # Disengaged, Engaged, Launching, Completed
            if(state_launchbar != 'Engaged')
            {
                setprop("/controls/gear/catapult-launch-cmd", 0);
                setprop("/controls/gear/launchbar", 0);
            }
        }, 1);
    }
    else
    {
        # raise launchbar unless engaged
        var state_launchbar = getprop("/gear/launchbar/state") or ''; # Disengaged, Engaged, Launching, Completed
        if(state_launchbar != 'Engaged')
        {
            setprop("/controls/gear/catapult-launch-cmd", 0);
            setprop("/controls/gear/launchbar", 0);
        }
    }
}

var event_launch = func() {
    var is_carrier_equiped = getprop("/sim/model/carrier-equipment") or 0;
    if(is_carrier_equiped != 1) { return; }

    var state_launchbar = getprop("/gear/launchbar/state") or ''; # Disengaged, Engaged, Launching, Completed
    if(state_launchbar == 'Engaged')
    {
        # catapult launching command
        setprop("/controls/gear/catapult-launch-cmd", 1);
        # reinit some values after launch (~2 seconds)
        settimer(func() {
            setprop("/controls/gear/launchbar", 0);
            setprop("/controls/gear/catapult-launch-cmd", 0);
        }, 2);
    }
}


var event_choose_enabled_cams = func() {
    # view managed by this function must have :
    # <enabled type="bool">false</enabled>

    # refueling cam if pod
    var center_pod = getprop("/sim/model/center-refuel-pod") or 0;
    if(center_pod == 1)
    {
        setprop("/sim/view[104]/enabled", 1);
    }
    else
    {
        setprop("/sim/view[104]/enabled", 0);
    }

    # tail cam if empty backseat
    var is_copilot = getprop("/controls/pax/copilot") or 0;
    if(is_copilot == 1)
    {
        setprop("/sim/view[101]/enabled", 1);
        setprop("/sim/view[103]/enabled", 1);
        setprop("/sim/view[105]/enabled", 0);
    }
    else
    {
        setprop("/sim/view[101]/enabled", 0);
        setprop("/sim/view[103]/enabled", 0);
        setprop("/sim/view[105]/enabled", 1);
    }
}

var event_brake = func(do_enable) {
    setprop("/controls/gear/brake-left", do_enable);
    setprop("/controls/gear/brake-right", do_enable);
}

var event_airbrake = func(do_enable) {
    var speedbrake = getprop("/controls/flight/speedbrake") or 0;
    if(do_enable == 1)
    {
        speedbrake = (speedbrake >= .75) ? 1 : speedbrake + .2;
        setprop("/controls/flight/speedbrake", speedbrake);
    }
    else
    {
        speedbrake = (speedbrake <= .25) ? 0 : speedbrake - .2;
        setprop("/controls/flight/speedbrake", speedbrake);
    }
}

var event_toggle_std_atm = func(do_enable) {
    var is_std_atm = getprop("/instrumentation/my_aircraft/stdby-alt/controls/std-alt") or 0;
    if(do_enable == -1)
    {
        # do_enable == -1 : toggle
        do_enable = (is_std_atm == 0) ? 1 : 0;
    }
    if(do_enable == 1)
    {
        setprop("/instrumentation/my_aircraft/stdby-alt/controls/std-alt", 1);
        var setting_inhg_previous = getprop("/instrumentation/altimeter/setting-inhg");
        setprop("/instrumentation/my_aircraft/stdby-alt/controls/setting-inhg-previous", setting_inhg_previous);
        setprop("/instrumentation/altimeter/setting-inhg", 29.92);
    }
    else
    {
        setprop("/instrumentation/my_aircraft/stdby-alt/controls/std-alt", 0);
        var setting_inhg_previous = getprop("/instrumentation/my_aircraft/stdby-alt/controls/setting-inhg-previous");
        setprop("/instrumentation/altimeter/setting-inhg", setting_inhg_previous);
    }
}

var event_set_view = func(action) {
    if(action == 0)
    {
        setprop("/sim/current-view/view-number", 0);
    }
    else
    {
        view.stepView(action);
    }
}

























var event_click_hold_autopilot = func()
{
    # set AP altitude as curent altitude
    var curr_alt = getprop("/instrumentation/altimeter/indicated-altitude-ft") or 5000;
    setprop("/autopilot/settings/target-altitude-ft", curr_alt);

    # set AP speed as current speed
    var curr_speed = getprop("/instrumentation/airspeed-indicator/true-speed-kt") or 300;
    setprop("/autopilot/settings/target-speed-kt", curr_speed);

    # set AP heading as curent heading
    var curr_heading = getprop("/orientation/heading-magnetic-deg") or 0;
    setprop("/autopilot/settings/heading-bug-deg", curr_heading);

    # arm AP for altitude, speed and heading
    setprop("/autopilot/internal/target-roll-deg",          0);
    setprop("/autopilot/internal/target-climb-rate-fps",    0);
    setprop("/autopilot/locks/altitude",                    'altitude-hold');
    setprop("/autopilot/locks/heading",                     'dg-heading-hold');
    event_click_lock_speed(1);
}

var event_click_disengage_autopilot = func()
{
    # disengage AP for altitude, speed and heading
    event_click_lock_alt(0);
    event_click_lock_speed(0);
    setprop("/autopilot/locks/heading",  '');
}

var event_click_lock_speed = func(do_enable)
{
    # do_enable == -1 : toggle
    if(do_enable == -1)
    {
        var is_ap_speed_locked = getprop("/autopilot/locks/speed") or '';
        do_enable = (is_ap_speed_locked == '') ? 1 : 0;
    }

    if(do_enable == 1)
    {
        setprop("/autopilot/locks/speed", 'speed-with-throttle');
        setprop("/instrumentation/my_aircraft/pfd/controls/lock-speed-stdby", 1);
    }
    else
    {
        setprop("/autopilot/locks/speed", '');
        setprop("/instrumentation/my_aircraft/pfd/controls/lock-speed-stdby", 0);
    }
}

var event_click_lock_alt = func(do_enable)
{
    # do_enable == -1 : toggle
    if(do_enable == -1)
    {
        var is_ap_alt_locked = getprop("/autopilot/locks/altitude") or '';
        do_enable = (is_ap_alt_locked == '') ? 1 : 0;
    }

    if(do_enable == 1)
    {
        setprop("/autopilot/locks/altitude", 'altitude-hold');
    }
    else
    {
        setprop("/autopilot/locks/altitude", '');
    }
    setprop("/autopilot/internal/target-climb-rate-fps", 0);
}





















#===============================================================================
#                                                                          TOOLS

var reload_fx = func() {
    fgcommand("reinit", props.Node.new({ subsystem: "sound" }));
}

var check_source_aliases = func() {
    var list_of_properties = [
        "/orientation/pitch-deg",
        "/orientation/roll-deg",
        "/orientation/heading-magnetic-deg",
    ];
    
    for(var i = 0 ; i < size(list_of_properties) ; i += 1)
    {
        var property = list_of_properties[i];
        var value = getprop(property);
        if(! value) value = 'NULL !';
        printf ('la propriete %s vaut %s', property, value);
    }
}

var dump_properties = func() {
    io.write_properties('/home/nico/.fgfs/Export/foo.xml', '/');
}





