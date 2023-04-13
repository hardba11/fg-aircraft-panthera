print("*** LOADING basic_sfd.nas ... ***");

#===============================================================================
#                                                                      CONSTANTS
var colors = {
    'light_grey': 'rgba(200, 200, 200, 1)',
    'yellow':     'rgba(250, 250, 20, 1)',
    'green':      'rgba(20, 250, 20, 1)',
    'orange':     'rgba(100, 40, 0, 1)',
    'red':        'rgba(200, 20, 20, 1)',
};

var rayon_static = 116;
var rayon_gauge = 100;

var x_rpm_engine = 420;
var y_rpm_engine = 700;
var x_torque_engine = 800;
var y_torque_engine = y_rpm_engine;

var x_tank0 = 1050;
var y_tank0 = 590;
var x_tank1 = x_tank0 + 100;
var y_tank1 = y_tank0;
var x_tank2 = x_tank0 + 200;
var y_tank2 = y_tank0;

var x_egt_engine = 600;
var y_egt_engine = 1000;
var x_oil_temp_engine = x_egt_engine;
var y_oil_temp_engine = y_egt_engine + 100;
var x_ff_engine = x_egt_engine;
var y_ff_engine = y_egt_engine + 200;

var x_text_gears = 250;
var y_text_gears = 1350;
var x_text_flaps = x_text_gears;
var y_text_flaps = y_text_gears + 50;
var x_text_doors = x_text_gears;
var y_text_doors = y_text_gears + 100;
var x_text_parkbrake = x_text_gears;
var y_text_parkbrake = y_text_gears + 150;

var x_text_datetime = 1400;
var y_text_datetime = 600;

var x_text_qnh = 1400;
var y_text_qnh = 700;
var x_text_temp = x_text_qnh;
var y_text_temp = y_text_qnh + 50;
var x_text_wind = x_text_qnh;
var y_text_wind = y_text_qnh + 100;



#===============================================================================
#                                                                      FUNCTIONS


#-------------------------------------------------------------------------------
#                                                     draw_circular_static_gauge
# this function creates a circular gauge
#   the drawed clockwise arc start on EAST
# params :
# - element     : canvas object created by createChild()
# - center_x    : center of the circle in px
# - center_y    : center of the circle in px
# - rayon       : radius of the circle in px
# - angle_start : start angle of the arc in deg
# - angle_end   : end angle of the arc in deg
# - color       : color of the arc (light_grey|green|red)
# - width       : width of the arc in px
#
var draw_circular_static_gauge = func(element, center_x, center_y, rayon, angle_start, angle_end, color, width)
{
    var coord_x_start = center_x + (rayon * math.cos(angle_start * D2R));
    var coord_y_start = center_y + (rayon * math.sin(angle_start * D2R));

    var to_x = -(rayon * math.cos(angle_start * D2R)) + (rayon * math.cos(angle_end * D2R));
    var to_y = -(rayon * math.sin(angle_start * D2R)) + (rayon * math.sin(angle_end * D2R));

    var angle = (angle_end - angle_start);

    if(angle >= 180)
    {
        element.setStrokeLineWidth(width)
            .set('stroke', colors[color])
            .moveTo(coord_x_start, coord_y_start)
            .arcLargeCW(rayon, rayon, 0, to_x, to_y);
    }
    else
    {
        element.setStrokeLineWidth(width)
            .set('stroke', colors[color])
            .moveTo(coord_x_start, coord_y_start)
            .arcSmallCW(rayon, rayon, 0, to_x, to_y);
    }
}

#-------------------------------------------------------------------------------
#                                                            draw_circular_gauge
# this function creates a circular gauge
#   the drawed clockwise arc start on EAST
# params :
# - element   : canvas object created by createChild()
# - center_x  : center of the circle in px
# - center_y  : center of the circle in px
# - rayon     : radius of the circle in px
# - angle     : angle of the arc in deg
# - color     : color of the arc (light_grey|green|red)
# - width     : width of the arc in px
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
#                                                                      draw_line
# this function creates a line
# params :
# - element  : canvas object created by createChild()
# - start_x  : coords of the start line
# - start_y  : coords of the start line
# - end_x    : coords of the end line
# - end_y    : coords of the end line
# - color    : color of the rectangle (light_grey|green|yellow|orange|red)
# - width    : line width
#
var draw_line = func(element, start_x, start_y, end_x, end_y, color, width)
{
    element.setStrokeLineWidth(width)
        .set('stroke', colors[color])
        .moveTo(start_x, start_y)
        .lineTo(end_x, end_y);
}



#-------------------------------------------------------------------------------
#                                                                 draw_rectangle
# this function creates a rectangle
# params :
# - element  : canvas object created by createChild()
# - start_x  : coords of the bottom left corner in px
# - start_y  : coords of the bottom left corner in px
# - color    : color of the rectangle (light_grey|green|yellow|orange|red)
# - width    : width of the rectangle in px
# - height   : height of the rectangle in px
#
var draw_rectangle = func(element, start_x, start_y, color, width, height)
{
    element.setStrokeLineWidth(3)
        .set('stroke', colors[color])
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
        m.static_rpm_engine_circle_grey = m.my_group.createChild('path', 'static_rpm_engine_circle_grey');
        draw_circular_static_gauge(m.static_rpm_engine_circle_grey, x_rpm_engine, y_rpm_engine, rayon_static, 0, 270, 'light_grey', 3);
        m.static_rpm_engine_circle_green = m.my_group.createChild('path', 'static_rpm_engine_circle_green');
        draw_circular_static_gauge(m.static_rpm_engine_circle_green, x_rpm_engine, y_rpm_engine, rayon_static + 6, 90, 190, 'green', 5);
        m.static_rpm_engine_circle_orange = m.my_group.createChild('path', 'static_rpm_engine_circle_orange');
        draw_circular_static_gauge(m.static_rpm_engine_circle_orange, x_rpm_engine, y_rpm_engine, rayon_static + 6, 190, 240, 'yellow', 5);
        m.static_rpm_engine_circle_red = m.my_group.createChild('path', 'static_rpm_engine_circle_red');
        draw_circular_static_gauge(m.static_rpm_engine_circle_red, x_rpm_engine, y_rpm_engine, rayon_static + 6, 240, 270, 'red', 5);

        # gauge (will be updated)
        m.rpm_engine_circle = m.my_group.createChild('path', 'rpm_engine_circle');
        draw_circular_gauge(m.rpm_engine_circle, x_rpm_engine, y_rpm_engine, rayon_gauge, 0, 'green', 23);

        # rectangle
        m.rpm_engine_frame = m.my_group.createChild('path', 'rpm_engine_frame');
        draw_rectangle(m.rpm_engine_frame, x_rpm_engine + 20, y_rpm_engine - 100, 'light_grey', 160, 80);

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
        #m.static_torque_engine_circle = m.my_group.createChild('path', 'static_torque_engine_circle');
        #draw_circular_static_gauge(m.static_torque_engine_circle, x_torque_engine, y_torque_engine, rayon_static, 0, 270, 'light_grey', 2);

        m.static_torque_engine_circle_grey = m.my_group.createChild('path', 'static_torque_engine_circle_grey');
        draw_circular_static_gauge(m.static_torque_engine_circle_grey, x_torque_engine, y_torque_engine, rayon_static, 0, 270, 'light_grey', 3);
        m.static_torque_engine_circle_green = m.my_group.createChild('path', 'static_torque_engine_circle_green');
        draw_circular_static_gauge(m.static_torque_engine_circle_green, x_torque_engine, y_torque_engine, rayon_static + 6, 90, 190, 'green', 5);
        m.static_torque_engine_circle_orange = m.my_group.createChild('path', 'static_torque_engine_circle_orange');
        draw_circular_static_gauge(m.static_torque_engine_circle_orange, x_torque_engine, y_torque_engine, rayon_static + 6, 190, 240, 'yellow', 5);
        m.static_torque_engine_circle_red = m.my_group.createChild('path', 'static_torque_engine_circle_red');
        draw_circular_static_gauge(m.static_torque_engine_circle_red, x_torque_engine, y_torque_engine, rayon_static + 6, 240, 270, 'red', 5);

        # gauge (will be updated)
        m.torque_engine_circle = m.my_group.createChild('path', 'torque_engine_circle');
        draw_circular_gauge(m.torque_engine_circle, x_torque_engine, y_torque_engine, rayon_gauge, 0, 'green', 23);

        # rectangle
        m.torque_engine_frame = m.my_group.createChild('path', 'torque_engine_frame');
        draw_rectangle(m.torque_engine_frame, x_torque_engine + 20, y_torque_engine - 100, 'light_grey', 160, 80);

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
        draw_rectangle(m.egt_frame, x_egt_engine, y_egt_engine, 'light_grey', 30, 358);
        m.egt_frame.setCenter(x_egt_engine, y_egt_engine).setRotation(90 * D2R);

        m.static_egt_green = m.my_group.createChild('path', 'static_egt_green');
        draw_line(m.static_egt_green, x_egt_engine + 30 + 5, y_egt_engine + 358 - 100, x_egt_engine + 30 + 5, y_egt_engine + 358 - 280, 'green', 5);
        m.static_egt_green.setCenter(x_egt_engine, y_egt_engine).setRotation(90 * D2R);

        m.static_egt_orange = m.my_group.createChild('path', 'static_egt_orange');
        draw_line(m.static_egt_orange, x_egt_engine + 30 + 5, y_egt_engine + 358 - 280, x_egt_engine + 30 + 5, y_egt_engine + 358 - 320, 'yellow', 5);
        m.static_egt_orange.setCenter(x_egt_engine, y_egt_engine).setRotation(90 * D2R);

        m.static_egt_red = m.my_group.createChild('path', 'static_egt_red');
        draw_line(m.static_egt_red, x_egt_engine + 30 + 5, y_egt_engine + 358 - 320, x_egt_engine + 30 + 5, y_egt_engine + 358 - 358, 'red', 5);
        m.static_egt_red.setCenter(x_egt_engine, y_egt_engine).setRotation(90 * D2R);

        m.egt_gauge = m.my_group.createChild('path', 'egt_gauge');
        draw_vertical_gauge(m.egt_gauge, x_egt_engine + 15, y_egt_engine + 358, 0, -100, 'green', 20);
        m.egt_gauge.setCenter(x_egt_engine, y_egt_engine).setRotation(90 * D2R);
        m.egt_engine_text = m.my_group.createChild('text', 'egt_engine_text')
            .setTranslation(x_egt_engine + 40, y_egt_engine - 15)
            .setAlignment('left-center')
            .setFont('LiberationFonts/LiberationSansNarrow-Bold.ttf')
            .setFontSize(36)
            .setColor(1, 1, 1, 1)
            .setText('');

        # label
        m.egt_label = m.my_group.createChild('text', 'egt_label')
            .setTranslation(x_egt_engine + 40, y_egt_engine + 15)
            .setAlignment('left-center')
            .setFont('LiberationFonts/LiberationSansNarrow-Bold.ttf')
            .setFontSize(36)
            .setColor(1, 1, 1, 1)
            .setText('EGT');

# display oil temp
        m.oil_temp_frame = m.my_group.createChild('path', 'oil_temp_frame');
        draw_rectangle(m.oil_temp_frame, x_oil_temp_engine, y_oil_temp_engine, 'light_grey', 30, 358);
        m.oil_temp_frame.setCenter(x_oil_temp_engine, y_oil_temp_engine).setRotation(90 * D2R);

        m.static_oil_temp_green = m.my_group.createChild('path', 'static_oil_temp_green');
        draw_line(m.static_oil_temp_green, x_oil_temp_engine + 30 + 5, y_oil_temp_engine + 358 - 100, x_oil_temp_engine + 30 + 5, y_oil_temp_engine + 358 - 280, 'green', 5);
        m.static_oil_temp_green.setCenter(x_oil_temp_engine, y_oil_temp_engine).setRotation(90 * D2R);

        m.static_oil_temp_orange = m.my_group.createChild('path', 'static_oil_temp_orange');
        draw_line(m.static_oil_temp_orange, x_oil_temp_engine + 30 + 5, y_oil_temp_engine + 358 - 280, x_oil_temp_engine + 30 + 5, y_oil_temp_engine + 358 - 320, 'yellow', 5);
        m.static_oil_temp_orange.setCenter(x_oil_temp_engine, y_oil_temp_engine).setRotation(90 * D2R);

        m.static_oil_temp_red = m.my_group.createChild('path', 'static_oil_temp_red');
        draw_line(m.static_oil_temp_red, x_oil_temp_engine + 30 + 5, y_oil_temp_engine + 358 - 320, x_oil_temp_engine + 30 + 5, y_oil_temp_engine + 358 - 358, 'red', 5);
        m.static_oil_temp_red.setCenter(x_oil_temp_engine, y_oil_temp_engine).setRotation(90 * D2R);

        m.oil_temp_gauge = m.my_group.createChild('path', 'oil_temp_gauge');
        draw_horizontal_gauge(m.oil_temp_gauge, x_oil_temp_engine + 15, y_oil_temp_engine + 358, 0, -100, 'green', 20);
        m.oil_temp_gauge.setCenter(x_oil_temp_engine, y_oil_temp_engine).setRotation(90 * D2R);
        m.oil_temp_engine_text = m.my_group.createChild('text', 'oil_temp_engine_text')
            .setTranslation(x_oil_temp_engine + 40, y_oil_temp_engine - 15)
            .setAlignment('left-center')
            .setFont('LiberationFonts/LiberationSansNarrow-Bold.ttf')
            .setFontSize(36)
            .setColor(1, 1, 1, 1)
            .setText('');

        # label
        m.oil_temp_label = m.my_group.createChild('text', 'oil_temp_label')
            .setTranslation(x_oil_temp_engine + 40, y_oil_temp_engine + 15)
            .setAlignment('left-center')
            .setFont('LiberationFonts/LiberationSansNarrow-Bold.ttf')
            .setFontSize(36)
            .setColor(1, 1, 1, 1)
            .setText('OIL TEMP');

# display FUEL FLOW
        m.ff_frame = m.my_group.createChild('path', 'ff_frame');
        draw_rectangle(m.ff_frame, x_ff_engine, y_ff_engine, 'light_grey', 30, 358);
        m.ff_frame.setCenter(x_ff_engine, y_ff_engine).setRotation(90 * D2R);


        m.static_ff_green = m.my_group.createChild('path', 'static_ff_green');
        draw_line(m.static_ff_green, x_ff_engine + 30 + 5, y_ff_engine + 358 - 100, x_ff_engine + 30 + 5, y_ff_engine + 358 - 280, 'green', 5);
        m.static_ff_green.setCenter(x_ff_engine, y_ff_engine).setRotation(90 * D2R);

        m.static_ff_orange = m.my_group.createChild('path', 'static_ff_orange');
        draw_line(m.static_ff_orange, x_ff_engine + 30 + 5, y_ff_engine + 358 - 280, x_ff_engine + 30 + 5, y_ff_engine + 358 - 320, 'yellow', 5);
        m.static_ff_orange.setCenter(x_ff_engine, y_ff_engine).setRotation(90 * D2R);

        m.static_ff_red = m.my_group.createChild('path', 'static_ff_red');
        draw_line(m.static_ff_red, x_ff_engine + 30 + 5, y_ff_engine + 358 - 320, x_ff_engine + 30 + 5, y_ff_engine + 358 - 358, 'red', 5);
        m.static_ff_red.setCenter(x_ff_engine, y_ff_engine).setRotation(90 * D2R);

        m.ff_gauge = m.my_group.createChild('path', 'ff_gauge');
        draw_horizontal_gauge(m.ff_gauge, x_ff_engine + 15, y_ff_engine + 358, 0, -100, 'green', 20);
        m.ff_gauge.setCenter(x_ff_engine, y_ff_engine).setRotation(90 * D2R);
        m.ff_engine_text = m.my_group.createChild('text', 'ff_engine_text')
            .setTranslation(x_ff_engine + 40, y_ff_engine - 15)
            .setAlignment('left-center')
            .setFont('LiberationFonts/LiberationSansNarrow-Bold.ttf')
            .setFontSize(36)
            .setColor(1, 1, 1, 1)
            .setText('');

        # label
        m.ff_label = m.my_group.createChild('text', 'ff_label')
            .setTranslation(x_ff_engine + 40, y_ff_engine + 15)
            .setAlignment('left-center')
            .setFont('LiberationFonts/LiberationSansNarrow-Bold.ttf')
            .setFontSize(36)
            .setColor(1, 1, 1, 1)
            .setText('FF');

# display FUEL TANK

        m.tank0_frame = m.my_group.createChild('path', 'tank0_frame');
        draw_rectangle(m.tank0_frame, x_tank0, y_tank0, 'light_grey', 30, 200);
        m.tank0_gauge = m.my_group.createChild('path', 'tank0_gauge');
        draw_vertical_gauge(m.tank0_gauge, x_tank0 + 15, y_tank0 + 200, 0, -100, 'green', 20);

        m.tank1_frame = m.my_group.createChild('path', 'tank1_frame');
        draw_rectangle(m.tank1_frame, x_tank1, y_tank1, 'light_grey', 30, 200);
        m.tank1_gauge = m.my_group.createChild('path', 'tank1_gauge');
        draw_vertical_gauge(m.tank1_gauge, x_tank1 + 15, y_tank1 + 200, 0, -100, 'green', 20);

        m.tank2_frame = m.my_group.createChild('path', 'tank2_frame');
        draw_rectangle(m.tank2_frame, x_tank2, y_tank2, 'light_grey', 30, 200);
        m.tank2_gauge = m.my_group.createChild('path', 'tank2_gauge');
        draw_vertical_gauge(m.tank2_gauge, x_tank2 + 15, y_tank2 + 200, 0, -100, 'green', 20);

        # label
        m.tank_label = m.my_group.createChild('text', 'tank_label')
            .setTranslation(x_tank1 + 25, y_tank1 + 300)
            .setAlignment('center-center')
            .setFont('LiberationFonts/LiberationSansNarrow-Bold.ttf')
            .setFontSize(50)
            .setColor(1, 1, 1, 1)
            .setText('FUEL TANK');

# display INFOS

        # gears
        m.text_gears = m.my_group.createChild('text', 'text_gears')
            .setTranslation(x_text_gears, y_text_gears)
            .setFont('LiberationFonts/LiberationSansNarrow-Bold.ttf')
            .setFontSize(36)
            .setColor(1, 1, 0, 1)
            .setText('GEARS : down');

        # flaps
        m.text_flaps = m.my_group.createChild('text', 'text_flaps')
            .setTranslation(x_text_flaps, y_text_flaps)
            .setFont('LiberationFonts/LiberationSansNarrow-Bold.ttf')
            .setFontSize(36)
            .setColor(0, 1, 0, 1)
            .setText('FLAPS : 0%');

        # doors
        m.text_doors = m.my_group.createChild('text', 'text_doors')
            .setTranslation(x_text_doors, y_text_doors)
            .setFont('LiberationFonts/LiberationSansNarrow-Bold.ttf')
            .setFontSize(36)
            .setColor(0, 1, 0, 1)
            .setText('DOORS : closed');

        # parkbrake
        m.text_parkbrake = m.my_group.createChild('text', 'text_parkbrake')
            .setTranslation(x_text_parkbrake, y_text_parkbrake)
            .setFont('LiberationFonts/LiberationSansNarrow-Bold.ttf')
            .setFontSize(36)
            .setColor(0, 1, 0, 1)
            .setText('PRKBRK : released');

# display ENVIRONMENT

        # date time
        m.text_datetime = m.my_group.createChild('text', 'text_datetime')
            .setTranslation(x_text_datetime, y_text_datetime)
            .setFont('LiberationFonts/LiberationSansNarrow-Bold.ttf')
            .setFontSize(42)
            .setColor(.9, .9, .9, 1)
            .setText('..-.. ..:..:..');

        # qnh
        m.text_qnh = m.my_group.createChild('text', 'text_qnh')
            .setTranslation(x_text_qnh, y_text_qnh)
            .setFont('LiberationFonts/LiberationSansNarrow-Bold.ttf')
            .setFontSize(36)
            .setColor(.9, .9, .9, 1)
            .setText('QNH : --.-- inhg');

        # ext temp
        m.text_temp = m.my_group.createChild('text', 'text_temp')
            .setTranslation(x_text_temp, y_text_temp)
            .setFont('LiberationFonts/LiberationSansNarrow-Bold.ttf')
            .setFontSize(36)
            .setColor(.9, .9, .9, 1)
            .setText('TEMP : --');

        # wind
        m.text_wind = m.my_group.createChild('text', 'text_wind')
            .setTranslation(x_text_wind, y_text_wind)
            .setFont('LiberationFonts/LiberationSansNarrow-Bold.ttf')
            .setFontSize(36)
            .setColor(.9, .9, .9, 1)
            .setText('WIND : --kt from ---');


        return m;
    },
    update: func()
    {
        var rpm      = getprop("/engines/engine[0]/rpm") or 0;
        var torque   = getprop("/engines/engine[0]/torque-ftlb") or 0;
        var ff       = getprop("/engines/engine[0]/fuel-flow-gph") or 0;
        var egt      = getprop("/engines/engine[0]/egt-degf") or 0;
        var oil_temp = getprop("/engines/engine[0]/oil-temperature-degf") or 0;

        var prop_pitch = getprop("/controls/engines/engine[0]/propeller-pitch") or 0;

        var tank0  = getprop("/consumables/fuel/tank[0]/level-lbs") or 0;
        var tank1  = getprop("/consumables/fuel/tank[1]/level-lbs") or 0;
        var tank2  = getprop("/consumables/fuel/tank[2]/level-lbs") or 0;

        var gears      = getprop("/controls/gear/gear-down") or 0;
        var flaps      = getprop("/controls/flight/flaps") or 0;
        #var flap_pos   = getprop("/surface_positions/flap-pos-norm") or 0;
        var door_av_g  = getprop("/controls/doors/porte-av-g") or 0;
        var door_av_d  = getprop("/controls/doors/porte-av-d") or 0;
        var door_ar_g  = getprop("/controls/doors/porte-ar-g") or 0;
        var door_ar_d  = getprop("/controls/doors/porte-ar-d") or 0;
        var parkbrk    = getprop("/controls/gear/brake-parking") or 0;

        var day        = getprop("/sim/time/real/day") or 0;
        var month      = getprop("/sim/time/real/month") or 0;
        var time       = getprop("/instrumentation/clock/indicated-string") or 0;

        var qnh        = getprop("/environment/pressure-sea-level-hpa") or 0;
        var temp       = getprop("/environment/temperature-degc") or 0;
        var windspeed  = getprop("/environment/wind-speed-kt") or 0;
        var windfrom   = getprop("/environment/wind-from-heading-deg") or 0;

        # gauge + value rpm
        update_circular_gauge(me.rpm_engine_circle, x_rpm_engine, y_rpm_engine, rayon_gauge, (rpm * 270 / 2600), 'green');
        me.rpm_engine_text.setText(sprintf('%.1f', rpm));

        # gauge + value torque
        if(torque < 0) { torque = 0; }
        update_circular_gauge(me.torque_engine_circle, x_torque_engine, y_torque_engine, rayon_gauge, (torque * 270 / 2000), 'green');
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
        update_gauge(me.tank0_gauge, 0, -tank0 * 200 / 400, 'green');
        update_gauge(me.tank1_gauge, 0, -tank1 * 200 / 700, 'green');
        update_gauge(me.tank2_gauge, 0, -tank2 * 200 / 400, 'green');

        if(gears > 0)
        {
            me.text_gears.setText('GEARS : down').setColor(1, 1, 0, 1);
        }
        else
        {
            me.text_gears.setText('GEARS : up').setColor(0, 1, 0, 1);
        }

        if(flaps > 0.1)
        {
            me.text_flaps.setText(sprintf('FLAPS : %d%%', flaps * 100)).setColor(1, 1, 0, 1);
        }
        else
        {
            me.text_flaps.setText('FLAPS : retracted').setColor(0, 1, 0, 1);
        }

        if((door_av_g + door_av_d + door_ar_g + door_ar_d) > 0.1)
        {
            var txt_tmp = 'open';
            txt_tmp = (door_av_g > 0) ? txt_tmp ~' avg' : txt_tmp;
            txt_tmp = (door_av_d > 0) ? txt_tmp ~' avd' : txt_tmp;
            txt_tmp = (door_ar_g > 0) ? txt_tmp ~' arg' : txt_tmp;
            txt_tmp = (door_ar_d > 0) ? txt_tmp ~' ard' : txt_tmp;
            me.text_doors.setText(sprintf('DOORS : %s', txt_tmp)).setColor(1, 1, 0, 1);
        }
        else
        {
            me.text_doors.setText('DOORS : closed').setColor(0, 1, 0, 1);
        }

        if(parkbrk > 0)
        {
            me.text_parkbrake.setText('PRKBRK : pulled').setColor(1, 1, 0, 1);
        }
        else
        {
            me.text_parkbrake.setText('PRKBRK : released').setColor(0, 1, 0, 1);
        }

        me.text_datetime.setText(sprintf('%02d-%02d %s', day, month, time));
        me.text_qnh.setText(sprintf('QNH : %.2f hPa', qnh));
        me.text_temp.setText(sprintf('TEMP : %d', temp));
        me.text_wind.setText(sprintf('WIND : %dkt from %d', windspeed, windfrom));


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



# inhg
# /instrumentation/altimeter/setting-hpa

# date/heure
# /instrumentation/clock/local-hour
# /instrumentation/clock/indicated-hour
# /instrumentation/clock/indicated-min
# /instrumentation/clock/indicated-sec
# /sim/time/real/day
# /sim/time/real/month

# chrono











