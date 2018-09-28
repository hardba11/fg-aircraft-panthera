print("*** LOADING pfd_light_canvas.nas ... ***");

var width = 1024;
var height = 1024;

var PFD_LIGHT = {
    canvas_settings: {
        'name': 'pfd_light',
        'size': [1024, 1024],
        'view': [width, height],
        'mipmapping': 1
    },
    new: func(placement)
    {
        var m = {
            parents: [PFD_LIGHT],
            canvas: canvas.new(PFD_LIGHT.canvas_settings)
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
        m.horizon = m.vertical_container.createChild('path', 'horizon')
            .setColor(1, 1, 1)
            .setStrokeLineWidth(4)
            .moveTo(-(width / 2), (height / 2))
            .lineTo((width + (width / 2)), (height / 2));
        m.d10 = m.vertical_container.createChild('path', 'd10')
            .setColor(1, 1, 1)
            .setStrokeLineWidth(2)
            .moveTo(3 * (width / 8), (height / 2) + (10 * 10))
            .lineTo(5 * (width / 8), (height / 2) + (10 * 10));
        m.t10 = m.vertical_container.createChild('path', 't10')
            .setColor(1, 1, 1)
            .setStrokeLineWidth(2)
            .moveTo(3 * (width / 8), (height / 2) - (10 * 10))
            .lineTo(5 * (width / 8), (height / 2) - (10 * 10));
        m.d20 = m.vertical_container.createChild('path', 'd20')
            .setColor(1, 1, 1)
            .setStrokeLineWidth(2)
            .moveTo(3 * (width / 8), (height / 2) + (10 * 20))
            .lineTo(5 * (width / 8), (height / 2) + (10 * 20));
        m.t20 = m.vertical_container.createChild('path', 't20')
            .setColor(1, 1, 1)
            .setStrokeLineWidth(2)
            .moveTo(3 * (width / 8), (height / 2) - (10 * 20))
            .lineTo(5 * (width / 8), (height / 2) - (10 * 20));



        m.top_symbol = m.horizontal_container.createChild('path', 'top_symbol')
            .setStrokeLineWidth(10)
            .set('stroke', 'rgb(255, 255, 255)')
            .moveTo((width / 2), (height / 3) + 45)
            .lineTo((width / 2) - 4, (height / 3) + 50)
            .lineTo((width / 2) + 4, (height / 3) + 50)
            .close();




        m.center = m.my_container.createChild('path', 'center')
            .rect((width / 2) - 5, (height / 2) - 5, 10, 10)
            .setColorFill(1, 1, 0);
        m.speed_bg = m.my_container.createChild('path', 'speed_bg')
            .set('stroke', 'rgb(255, 255, 255)')
            .rect((width / 4) - 95, (height / 2) - 15, 100, 30)
            .setColorFill(0, 0, 0);
        m.speed = m.my_container.createChild('text', 'speed')
            .setTranslation((width / 4), (height / 2))
            .setAlignment('right-center')
            .setFont('LiberationFonts/LiberationSansNarrow-Bold.ttf')
            .setFontSize(30)
            .setColor(1, 1, 1, 1)
            .setText('SPEED');

        m.alt_bg = m.my_container.createChild('path', 'alt_bg')
            .set('stroke', 'rgb(255, 255, 255)')
            .rect((3 * (width / 4)) - 5, (height / 2) - 15, 100, 30)
            .setColorFill(0, 0, 0);
        m.alt = m.my_container.createChild('text', 'alt')
            .setTranslation(3 * (width / 4), (height / 2))
            .setAlignment('left-center')
            .setFont('LiberationFonts/LiberationSansNarrow-Bold.ttf')
            .setFontSize(30)
            .setColor(1, 1, 1, 1)
            .setText('ALT');

        m.hdg_bg = m.my_container.createChild('path', 'hdg_bg')
            .set('stroke', 'rgb(255, 255, 255)')
            .rect((width / 2) - 50, (height / 3) - 15, 100, 30)
            .setColorFill(0, 0, 0);
        m.hdg = m.my_container.createChild('text', 'hdg')
            .setTranslation((width / 2), (height / 3))
            .setAlignment('center-center')
            .setFont('LiberationFonts/LiberationSansNarrow-Bold.ttf')
            .setFontSize(30)
            .setColor(1, 1, 1, 1)
            .setText('HDG');

        return m;
    },
    update: func()
    {

        var pitch_deg      = getprop("/orientation/pitch-deg");
        var roll_deg       = getprop("/orientation/roll-deg");
        var speed          = getprop("/instrumentation/airspeed-indicator/true-speed-kt");
        var alt            = getprop("/instrumentation/altimeter/indicated-altitude-ft");
        var hdg            = getprop("/orientation/heading-magnetic-deg");

        me.t_vertical_container.setTranslation(0, pitch_deg * 10);
        me.t_horizontal_container.setRotation(-(roll_deg * D2R), (width / 2), (height / 2));

        me.speed.setText(sprintf('%d', speed));
        me.alt.setText(sprintf('%d', alt));
        me.hdg.setText(sprintf('%d', hdg));


        var time_speed = getprop("/sim/speed-up") or 1;
        var loop_speed = (time_speed == 1) ? .1 : 10 * time_speed;
        settimer(func() { me.update(); }, loop_speed);
    }
};

var init = setlistener("/sim/signals/fdm-initialized", func() {
    removelistener(init); # only call once
    var my_pfd_light = PFD_LIGHT.new({'node': 'left.screen'});
    my_pfd_light.update();
});














