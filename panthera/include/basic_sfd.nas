print("*** LOADING basic_sfd.nas ... ***");

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

var x_egt_engine  = 600;
var y_egt_engine  = 1150;

var x_oil_temp_engine  = 600;
var y_oil_temp_engine  = 1300;

var x_ff_engine  = 600;
var y_ff_engine  = 1450;

var x_tank0  = 1400;
var y_tank0  = 1100;

var x_tank1  = 1500;
var y_tank1  = 1100;

var x_tank2  = 1600;
var y_tank2  = 1100;


#===============================================================================
#                                                                      FUNCTIONS

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
#                                                            draw_vertical_gauge
# this function creates a vertical gauge
# params :
# - element  : canvas object created by createChild()
# - start_x  : start of the gauge in px
# - start_y  : start of the gauge in px
# - end_x    : relative end of the gauge in px
# - end_y    : relative end of the gauge in px
# - color    : color of the gauge (light_grey|blue|red)
# - width    : width of the gauge in px
#
var draw_vertical_gauge = func(element, start_x, start_y, end_x, end_y, color, width)
{
        element.moveTo(start_x, start_y)
            .line(end_x, end_y)
            .setStrokeLineWidth(width)
            .set('stroke', colors[color]);
}


#-------------------------------------------------------------------------------
#                                                          draw_horizontal_gauge
# this function creates an horizontal gauge
# params :
# - element  : canvas object created by createChild()
# - start_x  : start of the gauge in px
# - start_y  : start of the gauge in px
# - end_x    : relative end of the gauge in px
# - end_y    : relative end of the gauge in px
# - color    : color of the gauge (light_grey|blue|red)
# - width    : width of the gauge in px
#
var draw_horizontal_gauge = func(element, start_x, start_y, end_x, end_y, color, width)
{
        element.moveTo(start_x, start_y)
            .line(end_x, end_y)
            .setStrokeLineWidth(width)
            .set('stroke', colors[color])
            .setCenter(start_x, start_y)
            .setRotation(90 * D2R);
}

#-------------------------------------------------------------------------------
#                                                                   update_gauge
# this function updates the lenght of a gauge
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
var BASIC_SFD = {
    canvas_settings: {
        'name': 'sfd_eicas',
        'size': [2048, 2048],
        'view': [2048, 2048],
        'mipmapping': 1
    },
    new: func(placement)
    {
        var m = {
            parents: [BASIC_SFD],
            canvas: canvas.new(BASIC_SFD.canvas_settings),
        };
        m.canvas.addPlacement(placement);
        m.canvas.setColorBackground(0, 0, 0, 1);
        m.my_container = m.canvas.createGroup('my_container');
        m.my_group = m.my_container.createChild('group');

# display RPM

        # static arc
        m.static_rpm_engine_circle = m.my_group.createChild('path', 'static_rpm_engine_circle');
        draw_circular_gauge(m.static_rpm_engine_circle, x_rpm_engine, y_rpm_engine, rayon_static, 270, 'light_grey', 3);
        #m.static_rpm_engine_circle_green = m.my_group.createChild('path', 'static_rpm_engine_circle_green');
        #draw_arc(m.static_rpm_engine_circle_green, x_rpm_engine, y_rpm_engine, rayon_static, 120, 350, 'green', 3);
        #m.static_rpm_engine_circle_red = m.my_group.createChild('path', 'static_rpm_engine_circle_red');
        #draw_arc(m.static_rpm_engine_circle_red, x_rpm_engine, y_rpm_engine, rayon_static, 60, 120, 'red', 3);

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

# display egt
        m.egt_frame = m.my_group.createChild('path', 'egt_frame');
        draw_rectangle(m.egt_frame, x_egt_engine, y_egt_engine, colors['light_grey'], 30, 358);
        m.egt_frame.setCenter(x_egt_engine, y_egt_engine).setRotation(90 * D2R);
        m.egt_gauge = m.my_group.createChild('path', 'egt_gauge');
        draw_vertical_gauge(m.egt_gauge, x_egt_engine + 15, y_egt_engine + 358, 0, -100, 'green', 20);
        m.egt_gauge.setCenter(x_egt_engine, y_egt_engine).setRotation(90 * D2R);
        m.egt_engine_text = m.my_group.createChild('text', 'egt_engine_text')
            .setTranslation(x_egt_engine + 125, y_egt_engine - 15)
            .setAlignment('center-center')
            .setFont('LiberationFonts/LiberationSansNarrow-Bold.ttf')
            .setFontSize(36)
            .setColor(1, 1, 1, 1)
            .setText('');

        # label
        m.egt_label = m.my_group.createChild('text', 'egt_label')
            .setTranslation(x_egt_engine + 125, y_egt_engine + 15)
            .setAlignment('center-center')
            .setFont('LiberationFonts/LiberationSansNarrow-Bold.ttf')
            .setFontSize(36)
            .setColor(1, 1, 1, 1)
            .setText('EGT');

# display oil temp
        m.oil_temp_frame = m.my_group.createChild('path', 'oil_temp_frame');
        draw_rectangle(m.oil_temp_frame, x_oil_temp_engine, y_oil_temp_engine, colors['light_grey'], 30, 358);
        m.oil_temp_frame.setCenter(x_oil_temp_engine, y_oil_temp_engine).setRotation(90 * D2R);
        m.oil_temp_gauge = m.my_group.createChild('path', 'oil_temp_gauge');
        draw_horizontal_gauge(m.oil_temp_gauge, x_oil_temp_engine + 15, y_oil_temp_engine + 358, 0, -100, 'green', 20);
        m.oil_temp_gauge.setCenter(x_oil_temp_engine, y_oil_temp_engine).setRotation(90 * D2R);
        m.oil_temp_engine_text = m.my_group.createChild('text', 'oil_temp_engine_text')
            .setTranslation(x_oil_temp_engine + 125, y_oil_temp_engine - 15)
            .setAlignment('center-center')
            .setFont('LiberationFonts/LiberationSansNarrow-Bold.ttf')
            .setFontSize(36)
            .setColor(1, 1, 1, 1)
            .setText('');

        # label
        m.oil_temp_label = m.my_group.createChild('text', 'oil_temp_label')
            .setTranslation(x_oil_temp_engine + 125, y_oil_temp_engine + 15)
            .setAlignment('center-center')
            .setFont('LiberationFonts/LiberationSansNarrow-Bold.ttf')
            .setFontSize(36)
            .setColor(1, 1, 1, 1)
            .setText('OIL TEMP');

# display FUEL FLOW
        m.ff_frame = m.my_group.createChild('path', 'ff_frame');
        draw_rectangle(m.ff_frame, x_ff_engine, y_ff_engine, colors['light_grey'], 30, 358);
        m.ff_frame.setCenter(x_ff_engine, y_ff_engine).setRotation(90 * D2R);
        m.ff_gauge = m.my_group.createChild('path', 'ff_gauge');
        draw_horizontal_gauge(m.ff_gauge, x_ff_engine + 15, y_ff_engine + 358, 0, -100, 'green', 20);
        m.ff_gauge.setCenter(x_ff_engine, y_ff_engine).setRotation(90 * D2R);
        m.ff_engine_text = m.my_group.createChild('text', 'ff_engine_text')
            .setTranslation(x_ff_engine + 125, y_ff_engine - 15)
            .setAlignment('center-center')
            .setFont('LiberationFonts/LiberationSansNarrow-Bold.ttf')
            .setFontSize(36)
            .setColor(1, 1, 1, 1)
            .setText('');

        # label
        m.ff_label = m.my_group.createChild('text', 'ff_label')
            .setTranslation(x_ff_engine + 125, y_ff_engine + 15)
            .setAlignment('center-center')
            .setFont('LiberationFonts/LiberationSansNarrow-Bold.ttf')
            .setFontSize(36)
            .setColor(1, 1, 1, 1)
            .setText('FF');

# display FUEL TANK

        m.tank0_frame = m.my_group.createChild('path', 'tank0_frame');
        draw_rectangle(m.tank0_frame, x_tank0, y_tank0, colors['light_grey'], 30, 258);
        m.tank0_gauge = m.my_group.createChild('path', 'tank0_gauge');
        draw_vertical_gauge(m.tank0_gauge, x_tank0 + 15, y_tank0 + 258, 0, -100, 'green', 20);

        m.tank1_frame = m.my_group.createChild('path', 'tank1_frame');
        draw_rectangle(m.tank1_frame, x_tank1, y_tank1, colors['light_grey'], 30, 258);
        m.tank1_gauge = m.my_group.createChild('path', 'tank1_gauge');
        draw_vertical_gauge(m.tank1_gauge, x_tank1 + 15, y_tank1 + 258, 0, -100, 'green', 20);

        m.tank2_frame = m.my_group.createChild('path', 'tank2_frame');
        draw_rectangle(m.tank2_frame, x_tank2, y_tank2, colors['light_grey'], 30, 258);
        m.tank2_gauge = m.my_group.createChild('path', 'tank2_gauge');
        draw_vertical_gauge(m.tank2_gauge, x_tank2 + 15, y_tank2 + 258, 0, -100, 'green', 20);

        # label
        m.tank_label = m.my_group.createChild('text', 'tank_label')
            .setTranslation(x_tank1 + 25, y_tank1 + 360)
            .setAlignment('center-center')
            .setFont('LiberationFonts/LiberationSansNarrow-Bold.ttf')
            .setFontSize(50)
            .setColor(1, 1, 1, 1)
            .setText('FUEL TANK');


        return m;
    },
    update: func()
    {
        var rpm      = getprop("/engines/engine[0]/rpm") or 0;
        var torque   = getprop("/engines/engine[0]/torque-ftlb") or 0;
        var ff       = getprop("/engines/engine[0]/fuel-flow-gph") or 0;
        var egt      = getprop("/engines/engine[0]/egt-degf") or 0;
        var oil_temp = getprop("/engines/engine[0]/oil-temperature-degf") or 0;

        var flap_pos   = getprop("/surface_positions/flap-pos-norm") or 0;
        var parkbrk    = getprop("/controls/gear/brake-parking") or 0;
        var prop_pitch = getprop("/controls/engines/engine[0]/propeller-pitch") or 0;

        var tank0  = getprop("/consumables/fuel/tank[0]/level-lbs") or 0;
        var tank1  = getprop("/consumables/fuel/tank[1]/level-lbs") or 0;
        var tank2  = getprop("/consumables/fuel/tank[2]/level-lbs") or 0;

        # gauge + value rpm
        update_circular_gauge(me.rpm_engine_circle, x_rpm_engine, y_rpm_engine, rayon_gauge, (rpm * 270 / 2600), 'green');
        me.rpm_engine_text.setText(sprintf('%.1f', rpm));

        # gauge + value torque
        update_circular_gauge(me.torque_engine_circle, x_torque_engine, y_torque_engine, rayon_gauge, (torque * 270 / 1500), 'green');
        me.torque_engine_text.setText(sprintf('%.1f', torque));

        # gauge + value egt
        update_gauge(me.egt_gauge, 0, -egt * 350 / 100, 'green');
        me.egt_engine_text.setText(sprintf('%.1f', egt));

        # gauge + value oil temp
        update_gauge(me.oil_temp_gauge, 0, -oil_temp * 350 / 300, 'green');
        me.oil_temp_engine_text.setText(sprintf('%.1f', oil_temp));

        # gauge + value fuel flow
        update_gauge(me.ff_gauge, 0, -ff * 350 / 120, 'green');
        me.ff_engine_text.setText(sprintf('%.1f', ff));

        # gauge + value tanks
        update_gauge(me.tank0_gauge, 0, -tank0 * 250 / 400, 'green');
        update_gauge(me.tank1_gauge, 0, -tank1 * 250 / 700, 'green');
        update_gauge(me.tank2_gauge, 0, -tank2 * 250 / 400, 'green');

        var time_speed = getprop("/sim/speed-up") or 1;
        var loop_speed = (time_speed == 1) ? .05 : 5;
        settimer(func() { me.update(); }, loop_speed);
    }
};

var init = setlistener("/sim/signals/fdm-initialized", func() {
    removelistener(init); # only call once
    var my_sfd = BASIC_SFD.new({'node': 'right.screen'});
    my_sfd.update();
});


# @TODO :
# - fuel tanks : /consumables/fuel/tank[0], [1] et [2]
# - fuel pump : /controls/fuel/tank[0]/boost-pump
# - pitot heat : /controls/switches/pitot-heat
# - fuel consumed : /engines/engine[0]/fuel-consumed-lbs
# - time / time elapsed / time in air
# - ??? /engines/engine[0]/prop-thrust
# - battery
# - oil press : /engines/engine[0]/oil-pressure-psi
# - oil temp : /engines/engine[0]/oil-temperature-degf
# - fuel press
# - ??? : /engines/engine[0]/cht-degf
# - egt : /engines/engine[0]/egt-degf
# - mp-inhg : /engines/engine[0]/mp-inhg









