print("*** LOADING sfd_light_canvas.nas ... ***");

#===============================================================================
#                                                                      CONSTANTS
var colors = {
    'light_grey': 'rgba(200, 200, 200, 1)',
    'green':      'rgba(20, 250, 20, 1)',
    'red':        'rgba(200, 20, 20, 1)',
    'yellow':     'rgba(250, 250, 20, 1)'
};

var rayon_static = 115;
var rayon_gauge = 100;

var x_rpm_engine  = 440;
var y_rpm_engine  = 800;

var x_torque_engine  = 880;
var y_torque_engine  = 800;

var x_n2_engine  = 1320;
var y_n2_engine  = 800;

var x_ff_engine  = 1600;
var y_ff_engine  = 650;



#===============================================================================
#                                                                      FUNCTIONS

#-------------------------------------------------------------------------------
#                                                            draw_circular_gauge
# this function creates a circular gauge
#   the drawed clockwise arc start on EAST
# params :
# - element  : canvas object created by createChild()
# - center_x : center of the circle in px
# - center_y : center of the circle in px
# - rayon    : radius of the circle in px
# - angle    : angle of the arc in deg
# - color    : color of the arc (light_grey|green|red)
# - width    : width of the arc in px
#
var draw_circular_gauge = func(element, center_x, center_y, rayon, angle, color, width)
{
    var coord_x_start = center_x + rayon;
    var coord_y_start = center_y;

    angle = (angle > 270) ? 270 : angle;

    var coord_x_end = -rayon + (rayon * math.cos(angle * D2R));
    var coord_y_end =           rayon * math.sin(angle * D2R);

    if(angle > 180)
    {
        element.setStrokeLineWidth(width)
            .set('stroke', colors[color])
            .moveTo(coord_x_start, coord_y_start)
            .arcLargeCW(rayon, rayon, 0, coord_x_end, coord_y_end);
    }
    else
    {
        element.setStrokeLineWidth(width)
            .set('stroke', colors[color])
            .moveTo(coord_x_start, coord_y_start)
            .arcSmallCW(rayon, rayon, 0, coord_x_end, coord_y_end);
    }
}

#-------------------------------------------------------------------------------
#                                                          update_circular_gauge
# this function updates the angle of a circular gauge
#   the drawed clockwise arc start on EAST
# params :
# - element  : canvas object created by createChild()
# - center_x : center of the circle in px
# - center_y : center of the circle in px
# - rayon    : radius of the circle in px
# - angle    : angle of the arc in deg
# - color    : color of the arc (light_grey|green|red)
#
var update_circular_gauge = func(element, center_x, center_y, rayon, angle, color)
{
    var coord_x_start = center_x + rayon;
    var coord_y_start = center_y;

    angle = (angle > 270) ? 270 : angle;

    var coord_x_end = -rayon + (rayon * math.cos(angle * D2R));
    var coord_y_end =           rayon * math.sin(angle * D2R);

    if(angle > 180)
    {
        element._node.getNode("cmd[1]", 1).setValue(23); # 23=arcLargeCW
    }
    else
    {
        element._node.getNode("cmd[1]", 1).setValue(19); # 19=arcSmallCW
    }
    element._node.getNode("stroke", 1).setValue(colors[color]);
    element._node.getNode("coord[5]", 1).setValue(coord_x_end);
    element._node.getNode("coord[6]", 1).setValue(coord_y_end);
}

#-------------------------------------------------------------------------------
#                                                                 draw_rectangle
# this function creates a rectangle
# params :
# - element  : canvas object created by createChild()
# - start_x  : coords of the bottom left angle in px
# - start_y  : coords of the bottom left angle in px
# - color    : color of the rectangle (light_grey|green|red)
# - width    : width of the rectangle in px
# - height   : height of the rectangle in px
#
var draw_rectangle = func(element, start_x, start_y, color, width, height)
{
    element.setStrokeLineWidth(3)
        .set('stroke', colors['light_grey'])
        .moveTo(start_x, start_y)
        .lineTo(start_x + width, start_y)
        .lineTo(start_x + width, start_y + height)
        .lineTo(start_x, start_y + height)
        .close();
}

#-------------------------------------------------------------------------------
#                                                                     draw_gauge
# this function creates a gauge
# params :
# - element  : canvas object created by createChild()
# - start_x  : start of the gauge in px
# - start_y  : start of the gauge in px
# - end_x    : relative end of the gauge in px
# - end_y    : relative end of the gauge in px
# - color    : color of the arc (light_grey|blue|red)
# - width    : width of the gauge in px
#
var draw_gauge = func(element, start_x, start_y, end_x, end_y, color, width)
{
        element.moveTo(start_x, start_y)
            .line(end_x, end_y)
            .setStrokeLineWidth(width)
            .set('stroke', colors[color]);
}

#-------------------------------------------------------------------------------
#                                                                   update_gauge
# this function updates the angle of a circular gauge
#   the drawed clockwise arc start on right
# params :
# - element  : canvas object created by createChild()
# - end_x    : relative end of the gauge in px
# - end_y    : relative end of the gauge in px
# - color    : color of the arc (light_grey|blue|red)
#
var update_gauge = func(element, end_x, end_y, color)
{
    element._node.getNode("stroke", 1).setValue(colors[color]);
    element._node.getNode("coord[2]", 1).setValue(end_x);
    element._node.getNode("coord[3]", 1).setValue(end_y);
}

#===============================================================================
#                                                                CLASS SFD_EICAS
var SFD_EICAS = {
    canvas_settings: {
        'name': 'sfd_eicas',
        'size': [2048, 2048],
        'view': [2048, 2048],
        'mipmapping': 1
    },
    new: func(placement)
    {
        var m = {
            parents: [SFD_EICAS],
            canvas: canvas.new(SFD_EICAS.canvas_settings),
        };
        m.canvas.addPlacement(placement);
        m.canvas.setColorBackground(0, 0, 0, 1);
        m.my_container = m.canvas.createGroup('my_container');
        m.my_group = m.my_container.createChild('group');

# display RPM

        # static arc
        m.static_rpm_engine_circle = m.my_group.createChild('path', 'static_rpm_engine_circle');
        draw_circular_gauge(m.static_rpm_engine_circle, x_rpm_engine, y_rpm_engine, rayon_static, 270, 'light_grey', 3);

        # gauge (will be updated)
        m.rpm_engine_circle = m.my_group.createChild('path', 'rpm_engine_circle');
        draw_circular_gauge(m.rpm_engine_circle, x_rpm_engine, y_rpm_engine, rayon_gauge, 0, 'green', 23);

        # rectangle
        m.rpm_engine_frame = m.my_group.createChild('path', 'rpm_engine_frame');
        draw_rectangle(m.rpm_engine_frame, x_rpm_engine + 20, y_rpm_engine - 100, colors['light_grey'], 160, 80);

        # value (will be updated)
        m.rpm_engine_text = m.my_group.createChild('text', 'rpm_engine_text')
            .setTranslation(x_rpm_engine + 170, y_rpm_engine - 60)
            .setAlignment('right-center')
            .setFont('LiberationFonts/LiberationSansNarrow-Bold.ttf')
            .setFontSize(50)
            .setColor(1, 1, 1, 1)
            .setText('');

        # label
        m.rpm_label = m.my_group.createChild('text', 'rpm_label')
            .setTranslation(x_rpm_engine, y_rpm_engine + 200)
            .setAlignment('center-center')
            .setFont('LiberationFonts/LiberationSansNarrow-Bold.ttf')
            .setFontSize(50)
            .setColor(1, 1, 1, 1)
            .setText('RPM');

# display TORQUE

        # static arc
        m.static_torque_engine_circle = m.my_group.createChild('path', 'static_torque_engine_circle');
        draw_circular_gauge(m.static_torque_engine_circle, x_torque_engine, y_torque_engine, rayon_static, 270, 'light_grey', 3);

        # gauge (will be updated)
        m.torque_engine_circle = m.my_group.createChild('path', 'torque_engine_circle');
        draw_circular_gauge(m.torque_engine_circle, x_torque_engine, y_torque_engine, rayon_gauge, 0, 'green', 23);

        # rectangle
        m.torque_engine_frame = m.my_group.createChild('path', 'torque_engine_frame');
        draw_rectangle(m.torque_engine_frame, x_torque_engine + 20, y_torque_engine - 100, colors['light_grey'], 160, 80);

        # value (will be updated)
        m.torque_engine_text = m.my_group.createChild('text', 'torque_engine_text')
            .setTranslation(x_torque_engine + 170, y_torque_engine - 60)
            .setAlignment('right-center')
            .setFont('LiberationFonts/LiberationSansNarrow-Bold.ttf')
            .setFontSize(50)
            .setColor(1, 1, 1, 1)
            .setText('');

        # label
        m.torque_label = m.my_group.createChild('text', 'torque_label')
            .setTranslation(x_torque_engine, y_torque_engine + 200)
            .setAlignment('center-center')
            .setFont('LiberationFonts/LiberationSansNarrow-Bold.ttf')
            .setFontSize(50)
            .setColor(1, 1, 1, 1)
            .setText('TORQUE');

# display N2

        # static arc
        m.static_n2_engine_circle = m.my_group.createChild('path', 'static_n2_engine_circle');
        draw_circular_gauge(m.static_n2_engine_circle, x_n2_engine, y_n2_engine, rayon_static, 270, 'light_grey', 3);

        # gauge (will be updated)
        m.n2_engine_circle = m.my_group.createChild('path', 'n2_engine_circle');
        draw_circular_gauge(m.n2_engine_circle, x_n2_engine, y_n2_engine, rayon_gauge, 0, 'green', 23);

        # rectangle
        m.n2_engine_frame = m.my_group.createChild('path', 'n2_engine_frame');
        draw_rectangle(m.n2_engine_frame, x_n2_engine + 20, y_n2_engine - 100, colors['light_grey'], 160, 80);

        # value (will be updated)
        m.n2_engine_text = m.my_group.createChild('text', 'n2_engine_text')
            .setTranslation(x_n2_engine + 170, y_n2_engine - 60)
            .setAlignment('right-center')
            .setFont('LiberationFonts/LiberationSansNarrow-Bold.ttf')
            .setFontSize(50)
            .setColor(1, 1, 1, 1)
            .setText('');

        # label
        m.n2_label = m.my_group.createChild('text', 'n2_label')
            .setTranslation(x_n2_engine, y_n2_engine + 200)
            .setAlignment('center-center')
            .setFont('LiberationFonts/LiberationSansNarrow-Bold.ttf')
            .setFontSize(50)
            .setColor(1, 1, 1, 1)
            .setText('N2');

# display FUEL FLOW
        m.ff_frame = m.my_group.createChild('path', 'ff_frame');
        draw_rectangle(m.ff_frame, x_ff_engine, y_ff_engine, colors['light_grey'], 30, 258);
        m.ff_gauge = m.my_group.createChild('path', 'ff_gauge');
        draw_gauge(m.ff_gauge, x_ff_engine + 15, y_ff_engine + 258, 0, -100, 'green', 20);
        m.ff_engine_text = m.my_group.createChild('text', 'ff_engine_text')
            .setTranslation(x_ff_engine + 25, y_ff_engine + 300)
            .setAlignment('center-center')
            .setFont('LiberationFonts/LiberationSansNarrow-Bold.ttf')
            .setFontSize(50)
            .setColor(1, 1, 1, 1)
            .setText('');

        # label
        m.ff_label = m.my_group.createChild('text', 'ff_label')
            .setTranslation(x_ff_engine + 25, y_ff_engine + 360)
            .setAlignment('center-center')
            .setFont('LiberationFonts/LiberationSansNarrow-Bold.ttf')
            .setFontSize(50)
            .setColor(1, 1, 1, 1)
            .setText('FF');


        return m;
    },
    update: func()
    {
        var rpm    = getprop("/engines/engine[0]/rpm") or 0;
        var torque = getprop("/engines/engine[0]/torque-ftlb") or 0;
        var n2     = getprop("/engines/engine[0]/n2") or 0;
        var ff     = getprop("/engines/engine[0]/fuel-flow-gph") or 0;

        # gauge + value rpm
        update_circular_gauge(me.rpm_engine_circle, x_rpm_engine, y_rpm_engine, rayon_gauge, (rpm * 270 / 2600), 'green');
        me.rpm_engine_text.setText(sprintf('%.1f', rpm));

        # gauge + value torque
        update_circular_gauge(me.torque_engine_circle, x_torque_engine, y_torque_engine, rayon_gauge, (torque * 270 / 1500), 'green');
        me.torque_engine_text.setText(sprintf('%.1f', torque));

        # gauge + value n2
        update_circular_gauge(me.n2_engine_circle, x_n2_engine, y_n2_engine, rayon_gauge, (n2 * 270 / 100), 'green');
        me.n2_engine_text.setText(sprintf('%.1f', n2));

        # gauge + value fuel flow
        update_gauge(me.ff_gauge, 0, -ff * 250 / 70, 'green');
        me.ff_engine_text.setText(sprintf('%.1f', ff));

        var time_speed = getprop("/sim/speed-up") or 1;
        var loop_speed = (time_speed == 1) ? .1 : 2 * time_speed;
        settimer(func() { me.update(); }, loop_speed);
    }
};

var init = setlistener("/sim/signals/fdm-initialized", func() {
    removelistener(init); # only call once
    var sfd_eicas = SFD_EICAS.new({'node': 'right.screen'});
    sfd_eicas.update();
});


# @TODO :
# - fuel tanks
# - fuel pump
# - pitot heat
# - fuel consumed : /engines/engine[0]/fuel-consumed-lbs
# - time / time elapsed / time in air
# - ??? /engines/engine[0]/prop-thrust
# - battery
# - oil press
# - oil temp
# - fuel press









