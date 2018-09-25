print("*** LOADING ai_canvas.nas ... ***");

var width = 1024;
var height = 1024;

var AI = {
    canvas_settings: {
        'name': 'ai',
        'size': [1024, 1024],
        'view': [width, height],
        'mipmapping': 1
    },
    new: func(placement)
    {
        var m = {
            parents: [AI],
            canvas: canvas.new(AI.canvas_settings)
        };

        m.canvas.addPlacement(placement);
        m.my_container = m.canvas.createGroup('my_container');
        m.horizontal_container = m.my_container.createChild('group');
        m.t_horizontal_container = m.horizontal_container.createTransform();
        m.vertical_container = m.horizontal_container.createChild('group');
        m.t_vertical_container = m.vertical_container.createTransform();

        m.sky = m.vertical_container.createChild('path', 'sky')
            .rect(-(width / 2), -(height / 2), (width * 2), height)
            .setColorFill(.15, .63, 1);
        m.ground = m.vertical_container.createChild('path', 'ground')
            .rect(-(width / 2), (height / 2), (width * 2), height)
            .setColorFill(.54, .38, .2);

        return m;
    },
    update: func()
    {

        var pitch_deg      = getprop("/orientation/pitch-deg");
        var roll_deg       = getprop("/orientation/roll-deg");

        me.t_vertical_container.setTranslation(0, pitch_deg * 10);
        me.t_horizontal_container.setRotation(-(roll_deg * D2R), (width / 2), (height / 2));
        var time_speed = getprop("/sim/speed-up") or 1;
        var loop_speed = (time_speed == 1) ? .1 : 10 * time_speed;
        settimer(func() { me.update(); }, loop_speed);
    }
};

var init = setlistener("/sim/signals/fdm-initialized", func() {
    removelistener(init); # only call once
    var my_ai = AI.new({'node': 'instrument.ai.screen'});
    my_ai.update();
    var my_pfd = AI.new({'node': 'left.screen'});
    my_pfd.update();
});














