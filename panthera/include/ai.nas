print("*** LOADING ai.nas ... ***");

var width = 1024;
var height = 1024;
var angle_to_pixel_factor = 7;

#===============================================================================
#                                              FUNCTIONS TO DRAW SIMPLE ELEMENTS

#-------------------------------------------------------------------------------
#                                                                       draw_arc
# this function draws an arc
# params :
# - element     : canvas object created by createChild()
# - center_x    : coord x of the center of the arc in px
# - center_y    : coord y of the center of the arc in px
# - radius      : radius
# - start_angle : start angle in deg ()
# - end_angle   : end angle in deg ()
# - color       : color
# - line_width  : line_width
#
var draw_arc = func(element, center_x, center_y, radius, start_angle, end_angle, color, line_width)
{
    var coord_start_x = center_x + (radius * math.cos(start_angle * D2R));
    var coord_start_y = center_y - (radius * math.sin(start_angle * D2R));

    var to_x = -(radius * math.cos(start_angle * D2R)) + (radius * math.cos(end_angle * D2R));
    var to_y = (radius * math.sin(start_angle * D2R)) - (radius * math.sin(end_angle * D2R));

    element.setStrokeLineWidth(line_width)
        .set('stroke', color)
        .moveTo(coord_start_x, coord_start_y)
        .arcSmallCCW(radius, radius, 0, to_x, to_y);
}


#===============================================================================
#                                                      FUNCTIONS TO DRAW OBJECTS

#-------------------------------------------------------------------------------
# this function draws objects which will move with roll and pitch (attitude
# indicator) :
#   - sky
#   - ground
#   - ladder
#
var draw_background = func(container)
{
    sky = container.createChild('path', 'sky')
        .rect(-(width / 2), -(height / 2), (width * 2), height)
        .setColorFill(.15, .63, 1);
    ground = container.createChild('path', 'ground')
        .rect(-(width / 2), (height / 2), (width * 2), height)
        .setColorFill(.54, .38, .2);
    horizon_line = container.createChild('path', 'horizon_line')
        .setColor(1, 1, 1)
        .setStrokeLineWidth(6)
        .moveTo(-(width / 2), (height / 2))
        .lineTo((width + (width / 2)), (height / 2));

    var deg_mark = {};
    var deg_line = {};
    var deg_label = {};
    var line_offset = 0;
    for (var deg = 5; deg < 90 ; deg = deg + 5)
    {
        foreach(var pos_or_min ; ['m', 'p'])
        {
            deg_mark['deg_mark_'~ pos_or_min ~'-'~ deg] = container.createChild('group', 'deg_mark_'~ pos_or_min ~'-'~ deg);
            line_offset = (pos_or_min == 'm')
                ? (height / 2) + (angle_to_pixel_factor * deg)
                : (height / 2) - (angle_to_pixel_factor * deg);

            if(math.mod(deg, 10) == 0)
            {
                deg_line[pos_or_min ~ deg] = deg_mark['deg_mark_'~ pos_or_min ~'-'~ deg].createChild('path', 'deg_line_'~ pos_or_min ~'-'~ deg)
                    .setColor(1, 1, 1)
                    .setStrokeLineWidth(5)
                    .moveTo(16 * width / 40, line_offset)
                    .lineTo(19 * width / 40, line_offset)
                    .moveTo(21 * width / 40, line_offset)
                    .lineTo(24 * width / 40, line_offset);

                deg_label[pos_or_min ~ deg] = deg_mark['deg_mark_'~ pos_or_min ~'-'~ deg].createChild('text', 'deg_label_'~ pos_or_min ~'-'~ deg)
                    .setTranslation(width / 2, line_offset)
                    .setAlignment('center-center')
                    .setFont('LiberationFonts/LiberationSansNarrow-Bold.ttf')
                    .setFontSize(45)
                    .setColor(1, 1, 1, 1)
                    .setText(deg);
            }
            else
            {
                deg_line[pos_or_min ~ deg] = deg_mark['deg_mark_'~ pos_or_min ~'-'~ deg].createChild('path', 'deg_line_'~ pos_or_min ~'-'~ deg)
                    .setColor(1, 1, 1)
                    .setStrokeLineWidth(5)
                    .moveTo(9 * width / 20, line_offset)
                    .lineTo(11 * width / 20, line_offset);
            }
        }
    }
}

#-------------------------------------------------------------------------------
# this function draws static objects of the attitude indicator
#   - pitch arc
#   - marks : 0, 10, 20, 30, 45 and 60
#
var draw_static_marks = func(container)
{
        center = container.createChild('path', 'center')
            .rect((width / 2) - 8, (height / 2) - 8, 16, 16)
            .setColorFill(1, 1, 0);
        roll_arc = container.createChild('path', 'roll_arc');
        draw_arc(roll_arc,
            width / 2,
            height / 2,
            (height / 4) + 25,
            0,
            180,
            'rgb(255, 255, 255)',
            8);
        zero_deg_mark = container.createChild('path', 'zero_deg_mark')
            .setStrokeLineWidth(3)
            .set('stroke', 'rgb(255, 255, 255)')
            .moveTo((width / 2), (height / 4) - 35)
            .lineTo((width / 2) - 15, (height / 4) - 60)
            .lineTo((width / 2) + 15, (height / 4) - 60)
            .setColorFill(1, 1, 1)
            .close();
        horizontal_mark_left = container.createChild('path', 'horizontal_mark_left')
            .setColor(1, 1, 0)
            .setStrokeLineWidth(10)
            .moveTo(3 * width / 16, height / 2)
            .lineTo(6 * width / 16, height / 2)
            .lineTo(6 * width / 16, (height / 2) + 40);
        horizontal_mark_right = container.createChild('path', 'horizontal_mark_right')
            .setColor(1, 1, 0)
            .setStrokeLineWidth(10)
            .moveTo(13 * width / 16, height / 2)
            .lineTo(10 * width / 16, height / 2)
            .lineTo(10 * width / 16, (height / 2) + 40);

        var roll_mark = {};
        foreach(var deg ; [30, 60])
        {
            roll_mark['roll_mark_m'~ deg] = container.createChild('path', 'roll_mark_m'~ deg)
                .setColor(1, 1, 1)
                .setStrokeLineWidth(8)
                .moveTo((width / 2), (height / 4) - 30)
                .lineTo((width / 2), (height / 4) - 60)
                .setCenter((width / 2), (height / 2))
                .setRotation(-deg * D2R);
            roll_mark['roll_mark_p'~ deg] = container.createChild('path', 'roll_mark_p'~ deg)
                .setColor(1, 1, 1)
                .setStrokeLineWidth(8)
                .moveTo((width / 2), (height / 4) - 30)
                .lineTo((width / 2), (height / 4) - 60)
                .setCenter((width / 2), (height / 2))
                .setRotation(deg * D2R);
        }
        foreach(var deg ; [10, 20, 45])
        {
            roll_mark['roll_mark_m'~ deg] = container.createChild('path', 'roll_mark_m'~ deg)
                .setColor(1, 1, 1)
                .setStrokeLineWidth(8)
                .moveTo((width / 2), (height / 4) - 30)
                .lineTo((width / 2), (height / 4) - 45)
                .setCenter((width / 2), (height / 2))
                .setRotation(-deg * D2R);
            roll_mark['roll_mark_p'~ deg] = container.createChild('path', 'roll_mark_p'~ deg)
                .setColor(1, 1, 1)
                .setStrokeLineWidth(8)
                .moveTo((width / 2), (height / 4) - 30)
                .lineTo((width / 2), (height / 4) - 45)
                .setCenter((width / 2), (height / 2))
                .setRotation(deg * D2R);
        }
}

#===============================================================================

var AI = {
    canvas_settings: {
        'name': 'ai',
        'size': [1024, 1024],
        'view': [1024, 1024],
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

        draw_background(m.vertical_container);

        m.top_symbol = m.horizontal_container.createChild('path', 'top_symbol')
            .setStrokeLineWidth(3)
            .set('stroke', 'rgb(255, 255, 0)')
            .moveTo((width / 2), (height / 4) - 20)
            .lineTo((width / 2) - 15, (height / 4) + 12)
            .lineTo((width / 2) + 15, (height / 4) + 12)
            .setColorFill(1, 1, 1)
            .close();

        draw_static_marks(m.my_container);

        return m;
    },
    update: func()
    {

        var pitch_deg      = getprop("/orientation/pitch-deg");
        var roll_deg       = getprop("/orientation/roll-deg");
        var speed          = getprop("/instrumentation/airspeed-indicator/true-speed-kt");
        var alt            = getprop("/instrumentation/altimeter/indicated-altitude-ft");
        var hdg            = getprop("/orientation/heading-magnetic-deg");

        me.t_vertical_container.setTranslation(0, pitch_deg * angle_to_pixel_factor);
        me.t_horizontal_container.setRotation(-(roll_deg * D2R), (width / 2), (height / 2));

        # hiding deg mark / pitch
        for(var deg = 5 ; deg < 90 ; deg = deg + 5)
        {
            me.vertical_container.getElementById('deg_mark_p-'~ deg).show();
            me.vertical_container.getElementById('deg_mark_m-'~ deg).show();
        }
        for(var deg = 5 ; deg < 90 ; deg = deg + 5)
        {
            var deg_mark = -deg;
            if((pitch_deg - 35) > deg_mark)
            {
                me.vertical_container.getElementById('deg_mark_m-'~ deg).hide();
            }
            if((pitch_deg + 30) < deg_mark)
            {
                me.vertical_container.getElementById('deg_mark_m-'~ deg).hide();
            }
            deg_mark = deg;
            if((pitch_deg - 35) > deg_mark)
            {
                me.vertical_container.getElementById('deg_mark_p-'~ deg).hide();
            }
            if((pitch_deg + 30) < deg_mark)
            {
                me.vertical_container.getElementById('deg_mark_p-'~ deg).hide();
            }
        }

        var time_speed = getprop("/sim/speed-up") or 1;
        var loop_speed = (time_speed == 1) ? .05 : 2 * time_speed;
        settimer(func() { me.update(); }, loop_speed);
    }
};

var init = setlistener("/sim/signals/fdm-initialized", func() {
    removelistener(init); # only call once
    var my_ai = AI.new({'node': 'instrument.ai.screen'});
    my_ai.update();
});














