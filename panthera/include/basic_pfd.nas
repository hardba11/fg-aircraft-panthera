print("*** LOADING basic_pfd.nas ... ***");

var width = 1024;
var height = 1024;

var angle_to_pixel_factor = 10 ;

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


var draw_label = func(element_bg, element_lbl, center_x, center_y, font_size, bg_width)
{
    element_bg.rect(center_x - (bg_width / 2), center_y, bg_width, font_size + 6);
    element_lbl.setTranslation(center_x, center_y + 3 + (font_size / 2))
        .setAlignment('center-center')
        .setFont('LiberationFonts/LiberationSansNarrow-Bold.ttf')
        .setFontSize(font_size);
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
    var deg_label_left = {};
    var deg_label_right = {};
    var line_offset = 0;
    for (var deg = 5; deg < 40 ; deg = deg + 5)
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
                    .setStrokeLineWidth(3)
                    .moveTo(18 * width / 40, line_offset)
                    .lineTo(22 * width / 40, line_offset);

                deg_label_left[pos_or_min ~ deg] = deg_mark['deg_mark_'~ pos_or_min ~'-'~ deg].createChild('text', 'deg_label_l_'~ pos_or_min ~'-'~ deg)
                    .setTranslation((18 * width / 40) - 10, line_offset)
                    .setAlignment('right-center')
                    .setFont('LiberationFonts/LiberationSansNarrow-Bold.ttf')
                    .setFontSize(25)
                    .setColor(1, 1, 1, 1)
                    .setText(deg);
                deg_label_right[pos_or_min ~ deg] = deg_mark['deg_mark_'~ pos_or_min ~'-'~ deg].createChild('text', 'deg_label_r_'~ pos_or_min ~'-'~ deg)
                    .setTranslation((22 * width / 40) + 10, line_offset)
                    .setAlignment('left-center')
                    .setFont('LiberationFonts/LiberationSansNarrow-Bold.ttf')
                    .setFontSize(25)
                    .setColor(1, 1, 1, 1)
                    .setText(deg);
            }
            else
            {
                deg_line[pos_or_min ~ deg] = deg_mark['deg_mark_'~ pos_or_min ~'-'~ deg].createChild('path', 'deg_line_'~ pos_or_min ~'-'~ deg)
                    .setColor(1, 1, 1)
                    .setStrokeLineWidth(2)
                    .moveTo(29 * width / 60, line_offset)
                    .lineTo(31 * width / 60, line_offset);
            }
        }
    }
}

#-------------------------------------------------------------------------------
# this function draws objects which will move with heading (horizontal
# situation indicator)
#   - heading marks
#   - main heading letters
#   - some heading numbers
#
var draw_hsi = func(container)
{
    hdg_to_letter = { 0:'N', 90:'E', 180:'S', 270:'W'};
    var hsi_mark = {};
    for (var i = 0; i < 72; i = i + 1)
    {
        var deg = i * 5 ;
        hsi_mark['hsi_grp-'~ deg] = container.createChild('group', 'hsi_grp-'~ deg);

        if(math.mod(i, 18) == 0)
        {
# N, E, S, W
        hsi_mark['hsi_mark-'~ deg] = hsi_mark['hsi_grp-'~ deg].createChild('path', 'hsi_mark-'~ deg)
            .setColor(1, 1, 1)
            .setStrokeLineWidth(2)
            .moveTo((width / 2), (height / 2) + 60)
            .lineTo((width / 2), (height / 2) + 50);
        hsi_mark['hsi_label-'~ deg] = hsi_mark['hsi_grp-'~ deg].createChild('text', 'hsi_label-'~ deg)
            .setTranslation((width / 2), (height / 2) + 80)
            .setAlignment('center-bottom')
            .setFont('LiberationFonts/LiberationSansNarrow-Bold.ttf')
            .setFontSize(20)
            .setColor(1, 1, 1, 1)
            .setText(hdg_to_letter[deg]);
        }
        elsif(math.mod(i, 6) == 0)
        {
# 30, 60, 120, ...
            hsi_mark['hsi_mark-'~ deg] = hsi_mark['hsi_grp-'~ deg].createChild('path', 'hsi_mark-'~ deg)
                .setColor(1, 1, 1)
                .setStrokeLineWidth(3)
                .moveTo((width / 2), (height / 2) + 60)
                .lineTo((width / 2), (height / 2) + 50);
            hsi_mark['hsi_label-'~ deg] = hsi_mark['hsi_grp-'~ deg].createChild('text', 'hsi_label-'~ deg)
                .setTranslation((width / 2), (height / 2) + 80)
                .setAlignment('center-bottom')
                .setFont('LiberationFonts/LiberationSansNarrow-Bold.ttf')
                .setFontSize(18)
                .setColor(1, 1, 1, 1)
                .setText(sprintf('%d',deg / 10));
        }
        elsif(math.mod(i, 2) == 0)
        {
# 10, 20, 40, ...
            hsi_mark['hsi_mark-'~ deg] = hsi_mark['hsi_grp-'~ deg].createChild('path', 'hsi_mark-'~ deg)
                .setColor(1, 1, 1)
                .setStrokeLineWidth(3)
                .moveTo((width / 2), (height / 2) + 60)
                .lineTo((width / 2), (height / 2) + 50);
        }
        else
        {
# 5, 15, 25, ...
            hsi_mark['hsi_mark-'~ deg] = hsi_mark['hsi_grp-'~ deg].createChild('path', 'hsi_mark-'~ deg)
                .setColor(1, 1, 1)
                .setStrokeLineWidth(3)
                .moveTo((width / 2), (height / 2) + 57)
                .lineTo((width / 2), (height / 2) + 50);
        }
        hsi_mark['hsi_grp-'~ deg]
            .setCenter((width / 2), (height / 2) + 150)
            .setRotation(deg * D2R);

    }
}

#-------------------------------------------------------------------------------
# this function draws static objects of the horizontal situation indicator
#   - center aircraft
#   - some marks
#
var draw_static_hsi = func(container)
{
    var hsi_static_mark = {};
    foreach(var deg ; [0, 45, 90, 135, 180, 225, 270, 305])
    {
        hsi_static_mark['hsi_static_mark-'~ deg] = container.createChild('path', 'hsi_static_mark-'~ deg)
            .setColor(1, 1, 1)
            .setStrokeLineWidth(3)
            .moveTo((width / 2), (height / 2) + 47)
            .lineTo((width / 2), (height / 2) + 37)
            .setCenter((width / 2), (height / 2) + 150)
            .setRotation(deg * D2R);
    }

    # avion au centre
    hsi_static_mark['hsi_static_mark-center'] = container.createChild('path', 'hsi_static_mark-center')
        .setColor(1, 1, 1)
        .setStrokeLineWidth(1)
        .moveTo((width / 2),      (height / 2) + 136)
        .lineTo((width / 2) + 2,  (height / 2) + 138)
        .lineTo((width / 2) + 2,  (height / 2) + 146)
        .lineTo((width / 2) + 12, (height / 2) + 150)
        .lineTo((width / 2) + 12, (height / 2) + 154)
        .lineTo((width / 2) + 2,  (height / 2) + 154)
        .lineTo((width / 2) + 2,  (height / 2) + 160)
        .lineTo((width / 2) + 7,  (height / 2) + 164)
        .lineTo((width / 2) + 7,  (height / 2) + 166)
        .lineTo((width / 2) - 7,  (height / 2) + 166)
        .lineTo((width / 2) - 7,  (height / 2) + 164)
        .lineTo((width / 2) - 2,  (height / 2) + 160)
        .lineTo((width / 2) - 2,  (height / 2) + 154)
        .lineTo((width / 2) - 12, (height / 2) + 154)
        .lineTo((width / 2) - 12, (height / 2) + 150)
        .lineTo((width / 2) - 2,  (height / 2) + 146)
        .lineTo((width / 2) - 2,  (height / 2) + 138)
        .setColorFill(1, 1, 1)
        .close();

}

#-------------------------------------------------------------------------------
# this function draws static objects of the attitude indicator
#   - pitch arc
#   - marks : 0, 10, 20, 30, 45 and 60
#
var draw_static_marks = func(container)
{
        center = container.createChild('path', 'center')
            .rect((width / 2) - 5, (height / 2) - 5, 10, 10)
            .setColorFill(1, 1, 0);
        roll_arc = container.createChild('path', 'roll_arc');
        draw_arc(roll_arc,
            width / 2,
            height / 2,
            (height / 6) - 30,
            30,
            150,
            'rgb(255, 255, 255)',
            3);

        zero_deg_mark = container.createChild('path', 'zero_deg_mark')
            .setStrokeLineWidth(2)
            .set('stroke', 'rgb(255, 255, 255)')
            .moveTo((width / 2), (height / 2) - (height / 6) + 25)
            .lineTo((width / 2) - 6, (height / 2) - (height / 6) + 15)
            .lineTo((width / 2) + 6, (height / 2) - (height / 6) + 15)
            .setColorFill(1, 1, 1)
            .close();
        horizontal_mark_left = container.createChild('path', 'horizontal_mark_left')
            .setColor(1, 1, 0)
            .setStrokeLineWidth(8)
            .moveTo(6 * width / 16, height / 2)
            .lineTo(7 * width / 16, height / 2);
        horizontal_mark_right = container.createChild('path', 'horizontal_mark_right')
            .setColor(1, 1, 0)
            .setStrokeLineWidth(8)
            .moveTo(9 * width / 16, height / 2)
            .lineTo(10 * width / 16, height / 2);

        var roll_mark = {};
        foreach(var deg ; [30, 60])
        {
            roll_mark['roll_mark_m'~ deg] = container.createChild('path', 'roll_mark_m'~ deg)
                .setColor(1, 1, 1)
                .setStrokeLineWidth(3)
                .moveTo((width / 2), (height / 2) - (height / 6) + 30)
                .lineTo((width / 2), (height / 2) - (height / 6) + 10)
                .setCenter((width / 2), (height / 2))
                .setRotation(-deg * D2R);
            roll_mark['roll_mark_p'~ deg] = container.createChild('path', 'roll_mark_p'~ deg)
                .setColor(1, 1, 1)
                .setStrokeLineWidth(3)
                .moveTo((width / 2), (height / 2) - (height / 6) + 30)
                .lineTo((width / 2), (height / 2) - (height / 6) + 10)
                .setCenter((width / 2), (height / 2))
                .setRotation(deg * D2R);
        }
        foreach(var deg ; [10, 20, 45])
        {
            roll_mark['roll_mark_m'~ deg] = container.createChild('path', 'roll_mark_m'~ deg)
                .setColor(1, 1, 1)
                .setStrokeLineWidth(3)
                .moveTo((width / 2), (height / 2) - (height / 6) + 30)
                .lineTo((width / 2), (height / 2) - (height / 6) + 15)
                .setCenter((width / 2), (height / 2))
                .setRotation(-deg * D2R);
            roll_mark['roll_mark_p'~ deg] = container.createChild('path', 'roll_mark_p'~ deg)
                .setColor(1, 1, 1)
                .setStrokeLineWidth(3)
                .moveTo((width / 2), (height / 2) - (height / 6) + 30)
                .lineTo((width / 2), (height / 2) - (height / 6) + 15)
                .setCenter((width / 2), (height / 2))
                .setRotation(deg * D2R);
        }
}

#===============================================================================
#                                                                          CLASS

var BASIC_PFD = {
    canvas_settings: {
        'name': 'pfd_light',
        'size': [1024, 1024],
        'view': [width, height],
        'mipmapping': 1
    },
    new: func(placement)
    {
        var m = {
            parents: [BASIC_PFD],
            canvas: canvas.new(BASIC_PFD.canvas_settings)
        };

        m.canvas.addPlacement(placement);
        m.my_container = m.canvas.createGroup('my_container');

        m.horizontal_container = m.my_container.createChild('group');
        m.t_horizontal_container = m.horizontal_container.createTransform();
        m.vertical_container = m.horizontal_container.createChild('group');
        m.t_vertical_container = m.vertical_container.createTransform();
        m.hsi_container = m.my_container.createChild('group');
        m.t_hsi_container = m.hsi_container.createTransform();

        draw_background(m.vertical_container);

        m.top_symbol = m.horizontal_container.createChild('path', 'top_symbol')
            .setStrokeLineWidth(2)
            .set('stroke', 'rgb(255, 255, 255)')
            .moveTo((width / 2), (height / 2) - (height / 6) + 32)
            .lineTo((width / 2) - 5, (height / 2) - (height / 6) + 44)
            .lineTo((width / 2) + 5, (height / 2) - (height / 6) + 44)
            .setColorFill(1, 1, 1)
            .close();

        m.center = m.my_container.createChild('path', 'center')
            .rect((width / 2) - 5, (height / 2) - 5, 10, 10)
            .setColorFill(1, 1, 0);

# speed
        m.speed_bg = m.my_container.createChild('path', 'speed_bg')
            .set('stroke', 'rgb(255, 255, 255)')
            .rect((7 * width / 20) - 95, (height / 2) - 15, 100, 30)
            .setColorFill(0, 0, 0);
        m.speed = m.my_container.createChild('text', 'speed')
            .setTranslation((7 * width / 20), (height / 2))
            .setAlignment('right-center')
            .setFont('LiberationFonts/LiberationSansNarrow-Bold.ttf')
            .setFontSize(30)
            .setColor(1, 1, 1, 1)
            .setText('SPEED');

# alt
        m.alt_bg = m.my_container.createChild('path', 'alt_bg')
            .set('stroke', 'rgb(255, 255, 255)')
            .rect((13 * width / 20) + 5, (height / 2) - 15, 100, 30)
            .setColorFill(0, 0, 0);
        m.alt = m.my_container.createChild('text', 'alt')
            .setTranslation((13 * width / 20) + 100, (height / 2))
            .setAlignment('right-center')
            .setFont('LiberationFonts/LiberationSansNarrow-Bold.ttf')
            .setFontSize(30)
            .setColor(1, 1, 1, 1)
            .setText('ALT');

# heading
        m.hdg_bg = m.my_container.createChild('path', 'hdg_bg')
            .set('stroke', 'rgb(255, 255, 255)')
            .rect((width / 2) - 50, (2 * height / 7) - 15, 100, 30)
            .setColorFill(0, 0, 0);
        m.hdg = m.my_container.createChild('text', 'hdg')
            .setTranslation((width / 2), (2 * height / 7))
            .setAlignment('center-center')
            .setFont('LiberationFonts/LiberationSansNarrow-Bold.ttf')
            .setFontSize(30)
            .setColor(1, 1, 1, 1)
            .setText('HDG');

# heading bug label
        m.hdgbug_bg = m.my_container.createChild('path', 'hdgbug_bg')
            .setColorFill(0, 0, 0);
        m.hdgbug = m.my_container.createChild('text', 'hdgbug')
            .setColor(1, 0, 1, 1)
            .setText('HDG');
        draw_label(m.hdgbug_bg, m.hdgbug, (7 * width / 20),  (height / 2) + 50, 18, 100);

# course label
        m.crs_bg = m.my_container.createChild('path', 'crs_bg')
            .setColorFill(0, 0, 0);
        m.crs = m.my_container.createChild('text', 'crs')
            .setColor(0, 1, 0, 1)
            .setText('CRS');
        draw_label(m.crs_bg, m.crs, (13 * width / 20),  (height / 2) + 50, 18, 100);

# ap speed
        m.ap_speed_bg = m.my_container.createChild('path', 'ap_speed_bg')
            .setColorFill(0, 0, 0);
        m.ap_speed = m.my_container.createChild('text', 'ap_speed')
            .setColor(1, 0, 1, 1)
            .setText('AP spd');
        draw_label(m.ap_speed_bg, m.ap_speed, (6 * width / 20),  (3 * height / 7), 18, 80);

# ap alt
        m.ap_alt_bg = m.my_container.createChild('path', 'ap_alt_bg')
            .setColorFill(0, 0, 0);
        m.ap_alt = m.my_container.createChild('text', 'ap_alt')
            .setColor(1, 0, 1, 1)
            .setText('AP alt');
        draw_label(m.ap_alt_bg, m.ap_alt, (14 * width / 20),  (3 * height / 7), 18, 80);

# nav1 active
        m.nav1_bg = m.my_container.createChild('path', 'nav1_bg')
            .setColorFill(0, 0, 0);
        m.nav1 = m.my_container.createChild('text', 'nav1')
            .setColor(0, 1, 0, 1)
            .setText('NAV1');
        draw_label(m.nav1_bg, m.nav1, (3 * width / 20),  (2 * height / 7) - 10, 18, 110);

# nav1 stdby
        m.nav1s_bg = m.my_container.createChild('path', 'nav1s_bg')
            .setColorFill(0, 0, 0);
        m.nav1s = m.my_container.createChild('text', 'nav1s')
            .setColor(1, 1, 0, 1)
            .setText('NAV1');
        draw_label(m.nav1s_bg, m.nav1s, (3 * width / 20) + 102,  (2 * height / 7) - 10, 18, 100);

# nav2 active
        m.nav2_bg = m.my_container.createChild('path', 'nav2_bg')
            .setColorFill(0, 0, 0);
        m.nav2 = m.my_container.createChild('text', 'nav2')
            .setColor(0, 1, 0, 1)
            .setText('NAV2');
        draw_label(m.nav2_bg, m.nav2, (3 * width / 20),  (2 * height / 7) - 10 + 26, 18, 110);

# nav2 stdby
        m.nav2s_bg = m.my_container.createChild('path', 'nav2s_bg')
            .setColorFill(0, 0, 0);
        m.nav2s = m.my_container.createChild('text', 'nav2s')
            .setColor(1, 1, 0, 1)
            .setText('NAV2');
        draw_label(m.nav2s_bg, m.nav2s, (3 * width / 20) + 102,  (2 * height / 7) - 10 + 26, 18, 100);

# com1 active
        m.com1_bg = m.my_container.createChild('path', 'com1_bg')
            .setColorFill(0, 0, 0);
        m.com1 = m.my_container.createChild('text', 'com1')
            .setColor(0, 1, 0, 1)
            .setText('COM1');
        draw_label(m.com1_bg, m.com1, (15 * width / 20),  (2 * height / 7) - 10, 18, 110);

# com1 stdby
        m.com1s_bg = m.my_container.createChild('path', 'com1s_bg')
            .setColorFill(0, 0, 0);
        m.com1s = m.my_container.createChild('text', 'com1s')
            .setColor(1, 1, 0, 1)
            .setText('COM1');
        draw_label(m.com1s_bg, m.com1s, (15 * width / 20) + 102,  (2 * height / 7) - 10, 18, 100);

# com2 active
        m.com2_bg = m.my_container.createChild('path', 'com2_bg')
            .setColorFill(0, 0, 0);
        m.com2 = m.my_container.createChild('text', 'com2')
            .setColor(0, 1, 0, 1)
            .setText('COM2');
        draw_label(m.com2_bg, m.com2, (15 * width / 20),  (2 * height / 7) - 10 + 26, 18, 110);

# com2 stdby
        m.com2s_bg = m.my_container.createChild('path', 'com2s_bg')
            .setColorFill(0, 0, 0);
        m.com2s = m.my_container.createChild('text', 'com2s')
            .setColor(1, 1, 0, 1)
            .setText('COM2');
        draw_label(m.com2s_bg, m.com2s, (15 * width / 20) + 102,  (2 * height / 7) - 10 + 26, 18, 100);



        draw_static_marks(m.my_container);
        draw_static_hsi(m.my_container);

        draw_hsi(m.hsi_container);

        return m;
    },
    update: func()
    {

        var pitch_deg      = getprop("/orientation/pitch-deg");
        var roll_deg       = getprop("/orientation/roll-deg");
        var speed          = getprop("/instrumentation/airspeed-indicator/true-speed-kt");
        var alt            = getprop("/instrumentation/altimeter/indicated-altitude-ft");
        var hdg            = getprop("/orientation/heading-magnetic-deg");
        var hdgbug         = getprop("/autopilot/settings/heading-bug-deg") or 0;
        var crs            = getprop("/instrumentation/nav[0]/radials/selected-deg") or 0;
        var ap_alt         = getprop("/autopilot/settings/target-altitude-ft") or 0;
        var ap_speed       = getprop("/autopilot/settings/target-speed-kt") or 0;

        var nav1_active = getprop("/instrumentation/nav[0]/frequencies/selected-mhz-fmt") or '';
        var nav1_stdby  = getprop("/instrumentation/nav[0]/frequencies/standby-mhz-fmt") or '';
        var nav2_active = getprop("/instrumentation/nav[1]/frequencies/selected-mhz-fmt") or '';
        var nav2_stdby  = getprop("/instrumentation/nav[1]/frequencies/standby-mhz-fmt") or '';

        var com1_active = getprop("/instrumentation/comm[0]/frequencies/selected-mhz-fmt") or '';
        var com1_stdby  = getprop("/instrumentation/comm[0]/frequencies/standby-mhz-fmt") or '';
        var com2_active = getprop("/instrumentation/comm[1]/frequencies/selected-mhz-fmt") or '';
        var com2_stdby  = getprop("/instrumentation/comm[1]/frequencies/standby-mhz-fmt") or '';

        # update AI
        me.t_vertical_container.setTranslation(0, pitch_deg * angle_to_pixel_factor);
        me.t_horizontal_container.setRotation(-(roll_deg * D2R), (width / 2), (height / 2));

        # update hsi
        me.t_hsi_container.setRotation(-(hdg * D2R), (width / 2), (height / 2) + 150);

        # update numeric values
        me.speed.setText(sprintf('%d', speed));
        me.alt.setText(sprintf('%d', alt));
        me.hdg.setText(sprintf('%03d', hdg));
        me.hdgbug.setText(sprintf('hdg %03d', hdgbug));
        me.crs.setText(sprintf('crs %d', crs));
        me.ap_speed.setText(sprintf('%d kt', ap_speed));
        me.ap_alt.setText(sprintf('%d ft', ap_alt));

        me.nav1.setText(sprintf('NAV1 %s', nav1_active));
        me.nav2.setText(sprintf('NAV2 %s', nav2_active));
        me.nav1s.setText(sprintf('stdby %s', nav1_stdby));
        me.nav2s.setText(sprintf('stdby %s', nav2_stdby));

        me.com1.setText(sprintf('COM1 %s', com1_active));
        me.com2.setText(sprintf('COM2 %s', com2_active));
        me.com1s.setText(sprintf('stdby %s', com1_stdby));
        me.com2s.setText(sprintf('stdby %s', com2_stdby));

        # hiding deg mark / pitch
        for(var deg = 5 ; deg < 40 ; deg = deg + 5)
        {
            me.vertical_container.getElementById('deg_mark_p-'~ deg).show();
            me.vertical_container.getElementById('deg_mark_m-'~ deg).show();
        }
        for(var deg = 5 ; deg < 40 ; deg = deg + 5)
        {
            var deg_mark = -deg;
            if((pitch_deg - 3) > deg_mark)
            {
                me.vertical_container.getElementById('deg_mark_m-'~ deg).hide();
            }
            deg_mark = deg;
            if((pitch_deg - 3) > deg_mark)
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
    var my_pfd = BASIC_PFD.new({'node': 'left.screen'});
    my_pfd.update();
});














