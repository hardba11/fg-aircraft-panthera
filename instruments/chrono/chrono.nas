print("*** LOADING instrument_chrono - chrono.nas ... ***");

# namespace : instrument_chrono


# controls :
# - btn2 : start/pause chrono
# - btn3 : hold/run | RESET

var is_running        = 0;
var is_hold           = 0;
var is_pause          = 0;

var start_time        = 0;
var stop_time         = 0;
var run_time          = 0;
var accumulated_time  = 0; # accumulated_time between pauses


var event_reset = func()
{
    is_running        = 0;
    is_hold           = 0;
    is_pause          = 0;
    setprop("/instrumentation/my_aircraft/chrono/is-running", is_running);
    setprop("/instrumentation/my_aircraft/chrono/is-hold",    is_hold);
    setprop("/instrumentation/my_aircraft/chrono/is-pause",   is_pause);

    start_time        = 0;
    stop_time         = 0;
    run_time          = 0;
    accumulated_time  = 0;
    setprop("/instrumentation/my_aircraft/chrono/et-hour", 0);
    setprop("/instrumentation/my_aircraft/chrono/et-min",  0);
    setprop("/instrumentation/my_aircraft/chrono/et-sec",  0);
    setprop("/instrumentation/my_aircraft/chrono/et-msec", 0);
}


var event_start_pause = func()
{
    is_hold = 0;
    setprop("/instrumentation/my_aircraft/chrono/is-hold", is_hold);
    if(is_running == 0)
    {
        # first start
        start_time        = getprop("/sim/time/elapsed-sec") or 0;
        is_running        = 1;
        is_pause          = 0;
        setprop("/instrumentation/my_aircraft/chrono/is-running", is_running);
        setprop("/instrumentation/my_aircraft/chrono/is-pause",   is_pause);
        loop_chrono();
    }
    else
    {
        # pause : keep last elapsed time
        stop_time = getprop("/sim/time/elapsed-sec") or 0;
        run_time = stop_time - start_time;
        accumulated_time += run_time;

        is_pause = getprop("/instrumentation/my_aircraft/chrono/is-pause") or 0;
        is_running = 0;
        is_pause = (is_pause == 1) ? 0 : 1;
        setprop("/instrumentation/my_aircraft/chrono/is-running", is_running);
        setprop("/instrumentation/my_aircraft/chrono/is-pause",   is_pause);

    }
}


var loop_chrono = func()
{
    is_running = getprop("/instrumentation/my_aircraft/chrono/is-running") or 0;
    is_pause   = getprop("/instrumentation/my_aircraft/chrono/is-pause") or 0;
    if((is_running == 1) and (is_pause == 0))
    {
        var et = getprop("/sim/time/elapsed-sec") or 0;

        et = et - start_time + accumulated_time;

        var et_hour = et / 3600;
        var et_min  = int(math.mod(et / 60, 60));
        var et_sec  = int(math.mod(et, 60));
        var et_msec = int(math.mod(et * 1000, 1000) / 10);

        is_hold = getprop("/instrumentation/my_aircraft/chrono/is-hold") or 0;
        if(is_hold == 0)
        {
            setprop("/instrumentation/my_aircraft/chrono/et-hour", et_hour);
            setprop("/instrumentation/my_aircraft/chrono/et-min",  et_min);
            setprop("/instrumentation/my_aircraft/chrono/et-sec",  et_sec);
            setprop("/instrumentation/my_aircraft/chrono/et-msec", et_msec);
        }
        var time_speed = getprop("/sim/speed-up") or 1;
        var loop_speed = (time_speed == 1) ? .01 : 2 * time_speed;
        settimer(loop_chrono, loop_speed);
    }
}






