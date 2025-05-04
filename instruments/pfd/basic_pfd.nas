print("*** LOADING basic_pfd.nas ... ***");


# TODO:
# [V] lbl ap en gris si ils ne sont pas actifs
# [V] decaler chrono
# [V] vertical speed : lbl + jauge 
# [ ] accel : jauge
# [ ] nav2


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


var draw_label = func(element_bg, element_lbl, center_x, center_y, font_size, bg_width, align='center')
{
    if(align == 'right')
    {
        element_bg.rect(center_x - bg_width, center_y, bg_width, font_size + 6);
        element_lbl.setTranslation(center_x - 3, center_y + 3 + (font_size / 2))
            .setAlignment('right-center')
            .setFont('LiberationFonts/LiberationSansNarrow-Bold.ttf')
            .setFontSize(font_size);
    }
    elsif(align == 'left')
    {
        element_bg.rect(center_x, center_y, bg_width, font_size + 6);
        element_lbl.setTranslation(center_x + 3, center_y + 3 + (font_size / 2))
            .setAlignment('left-center')
            .setFont('LiberationFonts/LiberationSansNarrow-Bold.ttf')
            .setFontSize(font_size);
    }
    else
    {
        element_bg.rect(center_x - (bg_width / 2), center_y, bg_width, font_size + 6);
        element_lbl.setTranslation(center_x, center_y + 3 + (font_size / 2))
            .setAlignment('center-center')
            .setFont('LiberationFonts/LiberationSansNarrow-Bold.ttf')
            .setFontSize(font_size);
    }
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
        .rect(-512, -512, 2048, 1024)
        .setColorFill(.1, .5, 1);
    ground = container.createChild('path', 'ground')
        .rect(-512, 512, 2048, 1024)
        .setColorFill(.30, .15, .1);
    horizon_line = container.createChild('path', 'horizon_line')
        .setColor(1, 1, 1)
        .setStrokeLineWidth(6)
        .moveTo(-512, 512)
        .lineTo((1024 + 512), 512);

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
                ? 512 + (angle_to_pixel_factor * deg)
                : 512 - (angle_to_pixel_factor * deg);

            if(math.mod(deg, 10) == 0)
            {
                deg_line[pos_or_min ~ deg] = deg_mark['deg_mark_'~ pos_or_min ~'-'~ deg].createChild('path', 'deg_line_'~ pos_or_min ~'-'~ deg)
                    .setColor(1, 1, 1)
                    .setStrokeLineWidth(3)
                    .moveTo(461, line_offset)
                    .lineTo(563, line_offset);

                deg_label_left[pos_or_min ~ deg] = deg_mark['deg_mark_'~ pos_or_min ~'-'~ deg].createChild('text', 'deg_label_l_'~ pos_or_min ~'-'~ deg)
                    .setTranslation(461 - 10, line_offset)
                    .setAlignment('right-center')
                    .setFont('LiberationFonts/LiberationSansNarrow-Bold.ttf')
                    .setFontSize(25)
                    .setColor(1, 1, 1, 1)
                    .setText(deg);
                deg_label_right[pos_or_min ~ deg] = deg_mark['deg_mark_'~ pos_or_min ~'-'~ deg].createChild('text', 'deg_label_r_'~ pos_or_min ~'-'~ deg)
                    .setTranslation(563 + 10, line_offset)
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
                    .moveTo(495, line_offset)
                    .lineTo(529, line_offset);
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
            .moveTo(512, 512 + 60)
            .lineTo(512, 512 + 50);
        hsi_mark['hsi_label-'~ deg] = hsi_mark['hsi_grp-'~ deg].createChild('text', 'hsi_label-'~ deg)
            .setTranslation(512, 512 + 80)
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
                .moveTo(512, 512 + 60)
                .lineTo(512, 512 + 50);
            hsi_mark['hsi_label-'~ deg] = hsi_mark['hsi_grp-'~ deg].createChild('text', 'hsi_label-'~ deg)
                .setTranslation(512, 512 + 80)
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
                .moveTo(512, 512 + 60)
                .lineTo(512, 512 + 50);
        }
        else
        {
# 5, 15, 25, ...
            hsi_mark['hsi_mark-'~ deg] = hsi_mark['hsi_grp-'~ deg].createChild('path', 'hsi_mark-'~ deg)
                .setColor(1, 1, 1)
                .setStrokeLineWidth(3)
                .moveTo(512, 512 + 57)
                .lineTo(512, 512 + 50);
        }
        hsi_mark['hsi_grp-'~ deg]
            .setCenter(512, 512 + 150)
            .setRotation(deg * D2R);

    }
}

#-------------------------------------------------------------------------------
# this function draws heading bug
#
var draw_hsi_hdgbug = func(container)
{
    var hsi_hdgbug = container.createChild('path', 'hsi_hdgbug')
        .setColor(1, 0, 1)
        .setStrokeLineWidth(1)
        .moveTo(512, 512 + 55)
        .lineTo(512 - 5,  512 + 55 + 5)
        .lineTo(512 - 5,  512 + 55 + 5 - 10)
        .lineTo(512 + 5,  512 + 55 + 5 - 10)
        .lineTo(512 + 5,  512 + 55 + 5)
        .setColorFill(1, 0, 1)
        .close();
}


#-------------------------------------------------------------------------------
# this function draws nav1 needle
#
var draw_hsi_nav1_needle = func(container)
{
    var hsi_nav1_needle = container.createChild('path', 'hsi_nav1_needle')
        .setColor(0, 1, 0)
        .setStrokeLineWidth(2)
        .moveTo(512, 512 + 58)
        .lineTo(512 - 7, 512 + 58 + 7)
        .lineTo(512 - 1, 512 + 58 + 7)
        .lineTo(512 - 1, 512 + 58 + 10)
        .lineTo(512 + 1, 512 + 58 + 10)
        .lineTo(512 + 1, 512 + 58 + 7)
        .lineTo(512 + 7, 512 + 58 + 7)
        .setColorFill(0, 1, 0)
        .close();
}

#-------------------------------------------------------------------------------
# this function draws nav1 crs
#
var draw_hsi_nav1_crs = func(container)
{
    var hsi_nav1_crs_head = container.createChild('path', 'hsi_nav1_crs_head')
        .setColor(0, 1, 0)
        .setStrokeLineWidth(2)
        .moveTo(512, 512 + 68)
        .lineTo(512 - 5, 512 + 68 + 5)
        .lineTo(512 - 1, 512 + 68 + 5)
        .lineTo(512 - 1, 512 + 68 + 30)
        .lineTo(512 + 1, 512 + 68 + 30)
        .lineTo(512 + 1, 512 + 68 + 5)
        .lineTo(512 + 5, 512 + 68 + 5)
        .setColorFill(0, 1, 0)
        .close();
    var hsi_nav1_crs_tail = container.createChild('path', 'hsi_nav1_crs_tail')
        .setColor(0, 1, 0)
        .setStrokeLineWidth(2)
        .moveTo(512, 512 + 188 + 5)
        .lineTo(512 - 1, 512 + 178 + 5)
        .lineTo(512 - 1, 512 + 178 + 30)
        .lineTo(512 + 1, 512 + 178 + 30)
        .lineTo(512 + 1, 512 + 178 + 5)
        .setColorFill(0, 1, 0)
        .close();
}

#-------------------------------------------------------------------------------
# this function draws nav1 deflection
#
var draw_hsi_nav1_deflection = func(container)
{
    var hsi_nav1_deflection = container.createChild('path', 'hsi_nav1_deflection')
        .setColor(0, 1, 0)
        .setStrokeLineWidth(2)
        .moveTo(512 - 1, 512 + 68 + 30)
        .lineTo(512 - 1, 512 + 178 + 5)
        .lineTo(512 + 1, 512 + 178 + 5)
        .lineTo(512 + 1, 512 + 68 + 30)
        .setColorFill(0, 1, 0)
        .close();
}


#-------------------------------------------------------------------------------
# this function draws nav2 needle
#
var draw_hsi_nav2_needle = func(container)
{
    var hsi_nav2_needle = container.createChild('path', 'hsi_nav2_needle')
        .setColor(1, 1, 0)
        .setStrokeLineWidth(2)
        .moveTo(512, 512 + 58)
        .lineTo(512 - 7, 512 + 58 + 7)
        .lineTo(512 - 1, 512 + 58 + 7)
        .lineTo(512 - 1, 512 + 58 + 10)
        .lineTo(512 + 1, 512 + 58 + 10)
        .lineTo(512 + 1, 512 + 58 + 7)
        .lineTo(512 + 7, 512 + 58 + 7)
        .close();
}

#-------------------------------------------------------------------------------
# this function draws nav1 crs
#
var draw_hsi_nav2_crs = func(container)
{
    var hsi_nav2_crs_head = container.createChild('path', 'hsi_nav2_crs_head')
        .setColor(1, 1, 0)
        .setStrokeLineWidth(2)
        .moveTo(512, 512 + 68)
        .lineTo(512 - 5, 512 + 68 + 5)
        .lineTo(512 - 1, 512 + 68 + 5)
        .lineTo(512 - 1, 512 + 68 + 30)
        .lineTo(512 + 1, 512 + 68 + 30)
        .lineTo(512 + 1, 512 + 68 + 5)
        .lineTo(512 + 5, 512 + 68 + 5)
        .close();
    var hsi_nav2_crs_tail = container.createChild('path', 'hsi_nav2_crs_tail')
        .setColor(1, 1, 0)
        .setStrokeLineWidth(2)
        .moveTo(512, 512 + 188 + 5)
        .lineTo(512 - 1, 512 + 178 + 5)
        .lineTo(512 - 1, 512 + 178 + 30)
        .lineTo(512 + 1, 512 + 178 + 30)
        .lineTo(512 + 1, 512 + 178 + 5)
        .close();
}

#-------------------------------------------------------------------------------
# this function draws nav2 deflection
#
var draw_hsi_nav2_deflection = func(container)
{
    var hsi_nav2_deflection = container.createChild('path', 'hsi_nav2_deflection')
        .setColor(1, 1, 0)
        .setStrokeLineWidth(2)
        .moveTo(512 - 1, 512 + 68 + 30)
        .lineTo(512 - 1, 512 + 178 + 5)
        .lineTo(512 + 1, 512 + 178 + 5)
        .lineTo(512 + 1, 512 + 68 + 30)
        .close();
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
            .moveTo(512, 512 + 47)
            .lineTo(512, 512 + 37)
            .setCenter(512, 512 + 150)
            .setRotation(deg * D2R);
    }

    # symbole avion au centre
    hsi_static_mark['hsi_static_mark-center'] = container.createChild('path', 'hsi_static_mark-center')
        .setColor(1, 1, 1)
        .setStrokeLineWidth(1)
        .moveTo(512,      512 + 136)
        .lineTo(512 + 2,  512 + 138)
        .lineTo(512 + 2,  512 + 146)
        .lineTo(512 + 12, 512 + 150)
        .lineTo(512 + 12, 512 + 154)
        .lineTo(512 + 2,  512 + 154)
        .lineTo(512 + 2,  512 + 160)
        .lineTo(512 + 7,  512 + 164)
        .lineTo(512 + 7,  512 + 166)
        .lineTo(512 - 7,  512 + 166)
        .lineTo(512 - 7,  512 + 164)
        .lineTo(512 - 2,  512 + 160)
        .lineTo(512 - 2,  512 + 154)
        .lineTo(512 - 12, 512 + 154)
        .lineTo(512 - 12, 512 + 150)
        .lineTo(512 - 2,  512 + 146)
        .lineTo(512 - 2,  512 + 138)
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
        .rect(512 - 5, 512 - 5, 10, 10)
        .setColorFill(1, 1, 0);
    roll_arc = container.createChild('path', 'roll_arc');
    draw_arc(roll_arc,
        512,
        512,
        171 - 30,
        30,
        150,
        'rgb(255, 255, 255)',
        3);

    zero_deg_mark = container.createChild('path', 'zero_deg_mark')
        .setStrokeLineWidth(2)
        .set('stroke', 'rgb(255, 255, 255)')
        .moveTo(512, 512 - 171 + 25)
        .lineTo(512 - 6, 512 - 171 + 15)
        .lineTo(512 + 6, 512 - 171 + 15)
        .setColorFill(1, 1, 1)
        .close();
    horizontal_mark_left = container.createChild('path', 'horizontal_mark_left')
        .setColor(1, 1, 0)
        .setStrokeLineWidth(8)
        .moveTo(384, 512)
        .lineTo(448, 512);
    horizontal_mark_right = container.createChild('path', 'horizontal_mark_right')
        .setColor(1, 1, 0)
        .setStrokeLineWidth(8)
        .moveTo(576, 512)
        .lineTo(640, 512);

    var roll_mark = {};
    foreach(var deg ; [30, 60])
    {
        roll_mark['roll_mark_m'~ deg] = container.createChild('path', 'roll_mark_m'~ deg)
            .setColor(1, 1, 1)
            .setStrokeLineWidth(3)
            .moveTo(512, 512 - 171 + 30)
            .lineTo(512, 512 - 171 + 10)
            .setCenter(512, 512)
            .setRotation(-deg * D2R);
        roll_mark['roll_mark_p'~ deg] = container.createChild('path', 'roll_mark_p'~ deg)
            .setColor(1, 1, 1)
            .setStrokeLineWidth(3)
            .moveTo(512, 512 - 171 + 30)
            .lineTo(512, 512 - 171 + 10)
            .setCenter(512, 512)
            .setRotation(deg * D2R);
    }
    foreach(var deg ; [10, 20, 45])
    {
        roll_mark['roll_mark_m'~ deg] = container.createChild('path', 'roll_mark_m'~ deg)
            .setColor(1, 1, 1)
            .setStrokeLineWidth(3)
            .moveTo(512, 512 - 171 + 30)
            .lineTo(512, 512 - 171 + 15)
            .setCenter(512, 512)
            .setRotation(-deg * D2R);
        roll_mark['roll_mark_p'~ deg] = container.createChild('path', 'roll_mark_p'~ deg)
            .setColor(1, 1, 1)
            .setStrokeLineWidth(3)
            .moveTo(512, 512 - 171 + 30)
            .lineTo(512, 512 - 171 + 15)
            .setCenter(512, 512)
            .setRotation(deg * D2R);
    }
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
# - width    : width of the gauge in px
#
var draw_vertical_gauge = func(element, start_x, start_y, end_x, end_y, width)
{
    element.moveTo(start_x, start_y)
        .line(end_x, end_y)
        .setStrokeLineWidth(width)
        .set('stroke', 'rgba(250, 100, 50, 1)');
}

#-------------------------------------------------------------------------------
#                                                                   update_gauge
# this function updates the lenght of a gauge
# params :
# - element  : canvas object created by createChild()
# - end_x    : relative end of the gauge in px
# - end_y    : relative end of the gauge in px
#
var update_gauge = func(element, end_x, end_y)
{
    element._node.getNode("coord[2]", 1).setValue(end_x);
    element._node.getNode("coord[3]", 1).setValue(end_y);
}

#===============================================================================
#                                                                          CLASS

var BASIC_PFD = {
    canvas_settings: {
        'name': 'pfd_light',
        'size': [1024, 1024],
        'view': [1024, 1024],
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
        m.hsi_hdgbug_container = m.my_container.createChild('group');
        m.t_hsi_hdgbug_container = m.hsi_hdgbug_container.createTransform();
        m.hsi_nav1_needle_container = m.my_container.createChild('group');
        m.t_hsi_nav1_needle_container = m.hsi_nav1_needle_container.createTransform();
        m.hsi_nav1_crs_container = m.my_container.createChild('group');
        m.t_hsi_nav1_crs_container = m.hsi_nav1_crs_container.createTransform();
        m.hsi_nav1_deflection_container = m.hsi_nav1_crs_container.createChild('group');
        m.t_hsi_nav1_deflection_container = m.hsi_nav1_deflection_container.createTransform();
        m.hsi_nav2_needle_container = m.my_container.createChild('group');
        m.t_hsi_nav2_needle_container = m.hsi_nav2_needle_container.createTransform();
        m.hsi_nav2_crs_container = m.my_container.createChild('group');
        m.t_hsi_nav2_crs_container = m.hsi_nav2_crs_container.createTransform();
        m.hsi_nav2_deflection_container = m.hsi_nav2_crs_container.createChild('group');
        m.t_hsi_nav2_deflection_container = m.hsi_nav2_deflection_container.createTransform();

        draw_background(m.vertical_container);

        m.top_symbol = m.horizontal_container.createChild('path', 'top_symbol')
            .setStrokeLineWidth(2)
            .set('stroke', 'rgb(255, 255, 255)')
            .moveTo(512, 512 - 171 + 32)
            .lineTo(512 - 5, 512 - 171 + 44)
            .lineTo(512 + 5, 512 - 171 + 44)
            .setColorFill(1, 1, 1)
            .close();

        m.center = m.my_container.createChild('path', 'center')
            .rect(512 - 5, 512 - 5, 10, 10)
            .setColorFill(1, 1, 0);

# speed
        m.speed_bg = m.my_container.createChild('path', 'speed_bg')
            .set('stroke', 'rgb(255, 255, 255)')
            .rect(358 - 95, 512 - 15, 100, 30)
            .setColorFill(0, 0, 0);
        m.speed = m.my_container.createChild('text', 'speed')
            .setTranslation(358, 512)
            .setAlignment('right-center')
            .setFont('LiberationFonts/LiberationSansNarrow-Bold.ttf')
            .setFontSize(30)
            .setColor(1, 1, 1, 1)
            .setText('SPEED');

# alt
        m.alt_bg = m.my_container.createChild('path', 'alt_bg')
            .set('stroke', 'rgb(255, 255, 255)')
            .rect(755 - 95, 512 - 15, 100, 30)
            .setColorFill(0, 0, 0);
        m.alt = m.my_container.createChild('text', 'alt')
            .setTranslation(755, 512)
            .setAlignment('right-center')
            .setFont('LiberationFonts/LiberationSansNarrow-Bold.ttf')
            .setFontSize(30)
            .setColor(1, 1, 1, 1)
            .setText('ALT');

# heading
        m.hdg_bg = m.my_container.createChild('path', 'hdg_bg')
            .set('stroke', 'rgb(255, 255, 255)')
            .rect(512 - 50, 292 - 15, 100, 30)
            .setColorFill(0, 0, 0);
        m.hdg = m.my_container.createChild('text', 'hdg')
            .setTranslation(512, 292)
            .setAlignment('center-center')
            .setFont('LiberationFonts/LiberationSansNarrow-Bold.ttf')
            .setFontSize(30)
            .setColor(1, 1, 1, 1)
            .setText('HDG');

# vspeed gauge
        m.vspeed_gauge = m.my_container.createChild('path', 'vspeed_gauge');
        draw_vertical_gauge(m.vspeed_gauge, 783, 512, 0, -100, 16);

# vspeed
        m.vspeed_bg = m.my_container.createChild('path', 'vspeed_bg')
            .set('stroke', 'rgb(255, 255, 255)')
            .rect(830 - 40, 512 - 15, 100, 30)
            .setColorFill(0, 0, 0);
        m.vspeed = m.my_container.createChild('text', 'vspeed')
            .setTranslation(870, 512)
            .setAlignment('right-center')
            .setFont('LiberationFonts/LiberationSansNarrow-Bold.ttf')
            .setFontSize(20)
            .setColor(1, 1, 1, 1)
            .setText('VSPEED');

# nav1 label
        m.crs1_bg = m.my_container.createChild('path', 'crs1_bg')
            .setColorFill(0, 0, 0);
        m.crs1 = m.my_container.createChild('text', 'crs1')
            .setColor(0, 1, 0, 1)
            .setText('CRS1');
        draw_label(m.crs1_bg, m.crs1, 310, 590, 18, 100);

        m.nav1_info_id_bg = m.my_container.createChild('path', 'nav1_info_id_bg')
            .setColorFill(0, 0, 0);
        m.nav1_info_id = m.my_container.createChild('text', 'nav1_info_id')
            .setColor(1, 0, 1, 1)
            .setText('ID');
        draw_label(m.nav1_info_id_bg, m.nav1_info_id, 310, 590 + 20, 18, 100);
        m.nav1_info_dist_bg = m.my_container.createChild('path', 'nav1_info_dist_bg')
            .setColorFill(0, 0, 0);
        m.nav1_info_dist = m.my_container.createChild('text', 'nav1_info_dist')
            .setColor(1, 0, 1, 1)
            .setText('0');
        draw_label(m.nav1_info_dist_bg, m.nav1_info_dist, 310, 590 + 40, 18, 100);
        m.nav1_info_eta_bg = m.my_container.createChild('path', 'nav1_info_eta_bg')
            .setColorFill(0, 0, 0);
        m.nav1_info_eta = m.my_container.createChild('text', 'nav1_info_eta')
            .setColor(1, 0, 1, 1)
            .setText('0');
        draw_label(m.nav1_info_eta_bg, m.nav1_info_eta, 310, 590 + 60, 18, 100);
        m.nav1_info_spd_bg = m.my_container.createChild('path', 'nav1_info_spd_bg')
            .setColorFill(0, 0, 0);
        m.nav1_info_spd = m.my_container.createChild('text', 'nav1_info_spd')
            .setColor(1, 0, 1, 1)
            .setText('0');
        draw_label(m.nav1_info_spd_bg, m.nav1_info_spd, 310, 590 + 80, 18, 100);

# nav2 label
        m.crs2_bg = m.my_container.createChild('path', 'crs2_bg')
            .setColorFill(0, 0, 0);
        m.crs2 = m.my_container.createChild('text', 'crs2')
            .setColor(1, 1, 0, 1)
            .setText('CRS2');
        draw_label(m.crs2_bg, m.crs2, 714,  590, 18, 100);

        m.nav2_info_id_bg = m.my_container.createChild('path', 'nav2_info_id_bg')
            .setColorFill(0, 0, 0);
        m.nav2_info_id = m.my_container.createChild('text', 'nav2_info_id')
            .setColor(1, 0, 1, 1)
            .setText('ID');
        draw_label(m.nav2_info_id_bg, m.nav2_info_id, 714, 590 + 20, 18, 100);
        m.nav2_info_dist_bg = m.my_container.createChild('path', 'nav2_info_dist_bg')
            .setColorFill(0, 0, 0);
        m.nav2_info_dist = m.my_container.createChild('text', 'nav2_info_dist')
            .setColor(1, 0, 1, 1)
            .setText('0');
        draw_label(m.nav2_info_dist_bg, m.nav2_info_dist, 714, 590 + 40, 18, 100);
        m.nav2_info_eta_bg = m.my_container.createChild('path', 'nav2_info_eta_bg')
            .setColorFill(0, 0, 0);
        m.nav2_info_eta = m.my_container.createChild('text', 'nav2_info_eta')
            .setColor(1, 0, 1, 1)
            .setText('0');
        draw_label(m.nav2_info_eta_bg, m.nav2_info_eta, 714, 590 + 60, 18, 100);
        m.nav2_info_spd_bg = m.my_container.createChild('path', 'nav2_info_spd_bg')
            .setColorFill(0, 0, 0);
        m.nav2_info_spd = m.my_container.createChild('text', 'nav2_info_spd')
            .setColor(1, 0, 1, 1)
            .setText('0');
        draw_label(m.nav2_info_spd_bg, m.nav2_info_spd, 714, 590 + 80, 18, 100);

# ap speed
        m.ap_speed_bg = m.my_container.createChild('path', 'ap_speed_bg')
            .rect(358 - 95, 512 - 140 - 15, 100, 30)
            .setColorFill(0, 0, 0);
        m.ap_speed = m.my_container.createChild('text', 'ap_speed')
            .setTranslation(358, 512 - 140)
            .setAlignment('right-center')
            .setFont('LiberationFonts/LiberationSansNarrow-Bold.ttf')
            .setFontSize(25)
            .setColor(0.5, 0.5, 0.5, 1)
            .setText('AP spd');

# ap alt
        m.ap_alt_bg = m.my_container.createChild('path', 'ap_alt_bg')
            .rect(755 - 95, 512 - 140 - 15, 100, 30)
            .setColorFill(0, 0, 0);
        m.ap_alt = m.my_container.createChild('text', 'ap_alt')
            .setTranslation(755, 512 - 140)
            .setAlignment('right-center')
            .setFont('LiberationFonts/LiberationSansNarrow-Bold.ttf')
            .setFontSize(25)
            .setColor(0.5, 0.5, 0.5, 1)
            .setText('AP alt');

# ap heading bug
        m.hdgbug_bg = m.my_container.createChild('path', 'hdgbug_bg')
            .rect(512 - 20, 700 - 15, 40, 30)
            .setColorFill(0, 0, 0);
        m.hdgbug = m.my_container.createChild('text', 'hdgbug')
            .setTranslation(512, 700)
            .setAlignment('center-center')
            .setFont('LiberationFonts/LiberationSansNarrow-Bold.ttf')
            .setFontSize(25)
            .setColor(0.5, 0.5, 0.5, 1)
            .setText('AP HDG');

# nav1 active
        m.nav1_bg = m.my_container.createChild('path', 'nav1_bg')
            .setColorFill(0, 0, 0);
        m.nav1 = m.my_container.createChild('text', 'nav1')
            .setColor(0, 1, 0, 1)
            .setText('NAV1');
        draw_label(m.nav1_bg, m.nav1, 153,  292 - 10, 18, 110);

# nav1 stdby
        m.nav1s_bg = m.my_container.createChild('path', 'nav1s_bg')
            .setColorFill(0, 0, 0);
        m.nav1s = m.my_container.createChild('text', 'nav1s')
            .setColor(0.5, 0.5, 0.5, 1)
            .setText('NAV1');
        draw_label(m.nav1s_bg, m.nav1s, 153 + 102,  292 - 10, 18, 100);

# nav2 active
        m.nav2_bg = m.my_container.createChild('path', 'nav2_bg')
            .setColorFill(0, 0, 0);
        m.nav2 = m.my_container.createChild('text', 'nav2')
            .setColor(1, 1, 0, 1)
            .setText('NAV2');
        draw_label(m.nav2_bg, m.nav2, 153,  292 - 10 + 26, 18, 110);

# nav2 stdby
        m.nav2s_bg = m.my_container.createChild('path', 'nav2s_bg')
            .setColorFill(0, 0, 0);
        m.nav2s = m.my_container.createChild('text', 'nav2s')
            .setColor(0.5, 0.5, 0.5, 1)
            .setText('NAV2');
        draw_label(m.nav2s_bg, m.nav2s, 153 + 102,  292 - 10 + 26, 18, 100);

# com1 active
        m.com1_bg = m.my_container.createChild('path', 'com1_bg')
            .setColorFill(0, 0, 0);
        m.com1 = m.my_container.createChild('text', 'com1')
            .setColor(1, 1, 1, 1)
            .setText('COM1');
        draw_label(m.com1_bg, m.com1, 768,  292 - 10, 18, 110);

# com1 stdby
        m.com1s_bg = m.my_container.createChild('path', 'com1s_bg')
            .setColorFill(0, 0, 0);
        m.com1s = m.my_container.createChild('text', 'com1s')
            .setColor(0.5, 0.5, 0.5, 1)
            .setText('COM1');
        draw_label(m.com1s_bg, m.com1s, 768 + 102,  292 - 10, 18, 100);

# com2 active
        m.com2_bg = m.my_container.createChild('path', 'com2_bg')
            .setColorFill(0, 0, 0);
        m.com2 = m.my_container.createChild('text', 'com2')
            .setColor(1, 1, 1, 1)
            .setText('COM2');
        draw_label(m.com2_bg, m.com2, 768,  292 - 10 + 26, 18, 110);

# com2 stdby
        m.com2s_bg = m.my_container.createChild('path', 'com2s_bg')
            .setColorFill(0, 0, 0);
        m.com2s = m.my_container.createChild('text', 'com2s')
            .setColor(0.5, 0.5, 0.5, 1)
            .setText('COM2');
        draw_label(m.com2s_bg, m.com2s, 768 + 102,  292 - 10 + 26, 18, 100);

# left mfd buttons
        m.l_mfd_k1_bg = m.my_container.createChild('path', 'l_mfd_k1_bg')
            .setColorFill(0, 0, 0);
        m.l_mfd_k1 = m.my_container.createChild('text', 'l_mfd_k1')
            .setColor(1, .5, .5, 1)
            .setText('+ / -');
        draw_label(m.l_mfd_k1_bg, m.l_mfd_k1, 130,  730, 18, 100);

        m.l_mfd_b1_bg = m.my_container.createChild('path', 'l_mfd_b1_bg')
            .setColorFill(0, 0, 0);
        m.l_mfd_b1 = m.my_container.createChild('text', 'l_mfd_b1')
            .setColor(1, .5, .5, 1)
            .setText('off');
        draw_label(m.l_mfd_b1_bg, m.l_mfd_b1, 210,  730, 18, 100);


        m.l_mfd_b2_bg = m.my_container.createChild('path', 'l_mfd_b2_bg')
            .setColorFill(0, 0, 0);
        m.l_mfd_b2 = m.my_container.createChild('text', 'l_mfd_b2')
            .setColor(1, .5, .5, 1)
            .setText('start/pause');
        draw_label(m.l_mfd_b2_bg, m.l_mfd_b2, 298,  730, 18, 100);
        m.l_mfd_b3_bg = m.my_container.createChild('path', 'l_mfd_b3_bg')
            .setColorFill(0, 0, 0);
        m.l_mfd_b3 = m.my_container.createChild('text', 'l_mfd_b3')
            .setColor(1, .5, .5, 1)
            .setText('hld/rst');
        draw_label(m.l_mfd_b3_bg, m.l_mfd_b3, 386,  730, 18, 100);
        m.chrono_bg = m.my_container.createChild('path', 'chrono_bg')
            .setColorFill(0, 0, 0);
        m.chrono = m.my_container.createChild('text', 'chrono')
            .setColor(1, 1, 1, 1)
            .setText('00:00:00.000');
        draw_label(m.chrono_bg, m.chrono, 260,  697, 25, 140, 'left');

# k1 130 730 # b1 210 # b2 298 # b3 386 # b4 # b5 # b6 650 # b7 738 # b8 826 # k2 930 

        m.l_mfd_b7_bg = m.my_container.createChild('path', 'l_mfd_b7_bg')
            .setColorFill(0, 0, 0);
        m.l_mfd_b7 = m.my_container.createChild('text', 'l_mfd_b7')
            .setColor(1, .5, .5, 1)
            .setText('off');
        draw_label(m.l_mfd_b7_bg, m.l_mfd_b7, 738,  730, 18, 100);

        m.l_mfd_b8_bg = m.my_container.createChild('path', 'l_mfd_b8_bg')
            .setColorFill(0, 0, 0);
        m.l_mfd_b8 = m.my_container.createChild('text', 'l_mfd_b8')
            .setColor(1, .5, .5, 1)
            .setText('off');
        draw_label(m.l_mfd_b8_bg, m.l_mfd_b8, 826,  730, 18, 100);


        m.l_mfd_k2_bg = m.my_container.createChild('path', 'l_mfd_k2_bg')
            .setColorFill(0, 0, 0);
        m.l_mfd_k2 = m.my_container.createChild('text', 'l_mfd_k2')
            .setColor(1, .5, .5, 1)
            .setText('+ / -');
        draw_label(m.l_mfd_k2_bg, m.l_mfd_k2, 910,  730, 18, 100);

        draw_static_marks(m.my_container);
        draw_static_hsi(m.my_container);

        draw_hsi(m.hsi_container);
        draw_hsi_hdgbug(m.hsi_hdgbug_container);
        draw_hsi_nav1_needle(m.hsi_nav1_needle_container);
        draw_hsi_nav1_crs(m.hsi_nav1_crs_container);
        draw_hsi_nav1_deflection(m.hsi_nav1_deflection_container);
        draw_hsi_nav2_needle(m.hsi_nav2_needle_container);
        draw_hsi_nav2_crs(m.hsi_nav2_crs_container);
        draw_hsi_nav2_deflection(m.hsi_nav2_deflection_container);

        return m;
    },
    update: func()
    {
        var pitch_deg   = getprop("/orientation/pitch-deg");
        var roll_deg    = getprop("/orientation/roll-deg");
        var speed       = getprop("/instrumentation/airspeed-indicator/true-speed-kt");
        var alt         = getprop("/instrumentation/altimeter/indicated-altitude-ft");
        #var hdg         = getprop("/orientation/heading-magnetic-deg");                     # MAG
        var hdg         = getprop("/orientation/heading-deg");                              # TRU
        var hdgbug      = getprop("/autopilot/settings/heading-bug-deg") or 0;              # MAG
        var hdgbugerr   = getprop("/autopilot/internal/heading-bug-error-deg") or 0;
        var ap_alt      = getprop("/autopilot/settings/target-altitude-ft") or 0;
        var ap_speed    = getprop("/autopilot/settings/target-speed-kt") or 0;
        var vspeed      = getprop("/autopilot/internal/vert-speed-fpm") or 0;

        var deflection  = getprop("/environment/magnetic-variation-deg") or 0;

        var crs1        = getprop("/instrumentation/nav[0]/radials/selected-deg") or 0;
        var nav1_active = getprop("/instrumentation/nav[0]/frequencies/selected-mhz") or '';
        var nav1_stdby  = getprop("/instrumentation/nav[0]/frequencies/standby-mhz") or '';
        var nav1_hdg    = getprop("/instrumentation/nav[0]/heading-deg") or 0;              # TRU
        var nav1_defl   = getprop("/instrumentation/nav[0]/heading-needle-deflection-norm") or 0;

        var crs2        = getprop("/instrumentation/nav[1]/radials/selected-deg") or 0;
        var nav2_active = getprop("/instrumentation/nav[1]/frequencies/selected-mhz") or '';
        var nav2_stdby  = getprop("/instrumentation/nav[1]/frequencies/standby-mhz") or '';
        var nav2_hdg    = getprop("/instrumentation/nav[1]/heading-deg") or 0;              # TRU
        var nav2_defl   = getprop("/instrumentation/nav[1]/heading-needle-deflection-norm") or 0;

        var com1_active = getprop("/instrumentation/comm[0]/frequencies/selected-mhz") or '';
        var com1_stdby  = getprop("/instrumentation/comm[0]/frequencies/standby-mhz") or '';

        var com2_active = getprop("/instrumentation/comm[1]/frequencies/selected-mhz") or '';
        var com2_stdby  = getprop("/instrumentation/comm[1]/frequencies/standby-mhz") or '';

        var mfd_left_current_lb1_set = getprop("/instrumentation/my_aircraft/mfd_left/current_lb1_set") or 'AP';
        var mfd_left_current_lb7_set = getprop("/instrumentation/my_aircraft/mfd_left/current_lb7_set") or 'NAV-COM';
        var mfd_left_current_lb8_set = getprop("/instrumentation/my_aircraft/mfd_left/current_lb8_set") or '';

        var chrono_et_hour = getprop("/instrumentation/my_aircraft/chrono/et-hour") or 0;
        var chrono_et_min = getprop("/instrumentation/my_aircraft/chrono/et-min") or 0;
        var chrono_et_sec = getprop("/instrumentation/my_aircraft/chrono/et-sec") or 0;
        var chrono_et_msec = getprop("/instrumentation/my_aircraft/chrono/et-msec") or 0;
        var chrono_is_running = getprop("/instrumentation/my_aircraft/chrono/is-running") or 0;
        #var chrono_is_hold = getprop("/instrumentation/my_aircraft/chrono/is-hold") or 0;
        #var chrono_is_pause = getprop("/instrumentation/my_aircraft/chrono/is-pause") or 0;

        var nav1_info_id = '---';
        var nav1_info_dist = '';
        var nav1_info_eta = '';
        var nav1_info_spd = '';

        var nav2_info_id = '---';
        var nav2_info_dist = '';
        var nav2_info_eta = '';
        var nav2_info_spd = '';

        var lock_speed = getprop("/autopilot/locks/speed") or '';
        if(lock_speed != '')
        {
            me.ap_speed.setColor(1, 0, 1, 1);
        }
        else
        {
            me.ap_speed.setColor(0.5, 0.5, 0.5, 1);
        }

        var lock_alt = getprop("/autopilot/locks/altitude") or '';
        if(lock_alt == 'altitude-hold')
        {
            me.ap_alt.setColor(1, 0, 1, 1);
        }
        else
        {
            me.ap_alt.setColor(0.5, 0.5, 0.5, 1);
        }

        var lock_hdg = getprop("/autopilot/locks/heading") or '';
        if(lock_hdg == 'dg-heading-hold')
        {
            me.hdgbug.setColor(1, 0, 1, 1);
        }
        else
        {
            me.hdgbug.setColor(0.5, 0.5, 0.5, 1);
        }

        signal_quality = getprop("/instrumentation/nav[0]/signal-quality-norm") or 0;
        nav1_info_is_near = (signal_quality > 0.4);
        if(nav1_info_is_near)
        {
            nav1_info_id = getprop("/instrumentation/nav[0]/nav-id") or '---';
            setprop("/instrumentation/dme/frequencies/source",'/instrumentation/nav[0]/frequencies/selected-mhz');
            var dme_in_range = getprop("/instrumentation/dme/in-range") or 0;
            if(dme_in_range)
            {
                x = getprop("/instrumentation/dme/indicated-distance-nm") or 0;
                nav1_info_dist = sprintf('%.1f NM', x);
                x = getprop("/instrumentation/dme/indicated-time-min") or 0;
                nav1_info_eta = sprintf('%.1f min', x);
                x = getprop("/instrumentation/dme/indicated-ground-speed-kt") or 0;
                nav1_info_spd = sprintf('%.1f KT', x);
            }
            me.nav1_info_id.setColor(0, 1, 0, 1);
            me.nav1_info_dist.setColor(0, 1, 0, 1);
            me.nav1_info_eta.setColor(0, 1, 0, 1);
            me.nav1_info_spd.setColor(0, 1, 0, 1);
        }
        else
        {
            me.nav1_info_id.setColor(0, 0, 0, 1);
            me.nav1_info_dist.setColor(0, 0, 0, 1);
            me.nav1_info_eta.setColor(0, 0, 0, 1);
            me.nav1_info_spd.setColor(0, 0, 0, 1);
        }

        signal_quality = getprop("/instrumentation/nav[1]/signal-quality-norm") or 0;
        nav2_info_is_near = (signal_quality > 0.4);
        if(nav2_info_is_near)
        {
            nav2_info_id = getprop("/instrumentation/nav[1]/nav-id") or '---';
            setprop("/instrumentation/dme/frequencies/source",'/instrumentation/nav[1]/frequencies/selected-mhz');
            var dme_in_range = getprop("/instrumentation/dme/in-range") or 0;
            if(dme_in_range)
            {
                x = getprop("/instrumentation/dme/indicated-distance-nm") or 0;
                nav2_info_dist = sprintf('%.1f NM', x);
                x = getprop("/instrumentation/dme/indicated-time-min") or 0;
                nav2_info_eta = sprintf('%.1f min', x);
                x = getprop("/instrumentation/dme/indicated-ground-speed-kt") or 0;
                nav2_info_spd = sprintf('%.1f KT', x);
            }
            me.nav2_info_id.setColor(1, 1, 0, 1);
            me.nav2_info_dist.setColor(1, 1, 0, 1);
            me.nav2_info_eta.setColor(1, 1, 0, 1);
            me.nav2_info_spd.setColor(1, 1, 0, 1);
        }
        else
        {
            me.nav2_info_id.setColor(0, 0, 0, 1);
            me.nav2_info_dist.setColor(0, 0, 0, 1);
            me.nav2_info_eta.setColor(0, 0, 0, 1);
            me.nav2_info_spd.setColor(0, 0, 0, 1);
        }
        #if(mfd_left_current_lb7_set == 'nav1'){}
        #elsif(mfd_left_current_lb7_set == 'nav2'){}

        # update AI
        me.t_vertical_container.setTranslation(0, pitch_deg * angle_to_pixel_factor);
        me.t_horizontal_container.setRotation(-(roll_deg * D2R), 512, 512);

        # update hsi
        me.t_hsi_container.setRotation(-(hdg * D2R), 512, 512 + 150);
        me.t_hsi_hdgbug_container.setRotation((hdgbugerr * D2R), 512, 512 + 150);

        me.t_hsi_nav1_needle_container.setRotation(-(geo.normdeg(hdg - nav1_hdg) * D2R), 512, 512 + 150);
        me.t_hsi_nav1_crs_container.setRotation(-(geo.normdeg(hdg - crs1 - deflection) * D2R), 512, 512 + 150);
        me.t_hsi_nav1_deflection_container.setTranslation(nav1_defl * 50, 0);

        me.t_hsi_nav2_needle_container.setRotation(-(geo.normdeg(hdg - nav2_hdg) * D2R), 512, 512 + 150);
        me.t_hsi_nav2_crs_container.setRotation(-(geo.normdeg(hdg - crs2 - deflection) * D2R), 512, 512 + 150);
        me.t_hsi_nav2_deflection_container.setTranslation(nav2_defl * 50, 0);

        # update gauges
        update_gauge(me.vspeed_gauge, 0, vspeed / -75);
        if (vspeed > 0)
        {
            me.vspeed_gauge.set('stroke', 'rgba(0, 250, 0, 1)');
        }
        else
        {
            me.vspeed_gauge.set('stroke', 'rgba(250, 250, 0, 1)');
        }

        # update numeric values
        me.speed.setText(sprintf('%d', speed));
        me.alt.setText(sprintf('%d', alt));
        me.hdg.setText(sprintf('%03d', hdg));
        me.ap_speed.setText(sprintf('%d', ap_speed));
        me.ap_alt.setText(sprintf('%d', ap_alt));
        me.hdgbug.setText(sprintf('%03d', geo.normdeg(hdgbug + deflection)));
        me.crs1.setText(sprintf('crs1 %d', crs1));
        me.crs2.setText(sprintf('crs2 %d', crs2));
        me.vspeed.setText(sprintf('%d fpm', vspeed));

        me.nav1.setText(sprintf('NAV1 %0.2f', nav1_active));
        me.nav2.setText(sprintf('NAV2 %0.2f', nav2_active));
        me.nav1s.setText(sprintf('stdby %0.2f', nav1_stdby));
        me.nav2s.setText(sprintf('stdby %0.2f', nav2_stdby));

        me.com1.setText(sprintf('COM1 %0.2f', com1_active));
        me.com2.setText(sprintf('COM2 %0.2f', com2_active));
        me.com1s.setText(sprintf('stdby %0.2f', com1_stdby));
        me.com2s.setText(sprintf('stdby %0.2f', com2_stdby));

        me.l_mfd_b1.setText(sprintf('%s', mfd_left_current_lb1_set));
        me.l_mfd_b7.setText(sprintf('%s', mfd_left_current_lb7_set));
        me.l_mfd_b8.setText(sprintf('%s', mfd_left_current_lb8_set));

        me.nav1_info_id.setText(nav1_info_id);
        me.nav1_info_dist.setText(nav1_info_dist);
        me.nav1_info_eta.setText(nav1_info_eta);
        me.nav1_info_spd.setText(nav1_info_spd);

        me.nav2_info_id.setText(nav2_info_id);
        me.nav2_info_dist.setText(nav2_info_dist);
        me.nav2_info_eta.setText(nav2_info_eta);
        me.nav2_info_spd.setText(nav2_info_spd);

        me.chrono.setText(sprintf('%02d:%02d:%02d.%03d', chrono_et_hour, chrono_et_min, chrono_et_sec, chrono_et_msec));

        if(chrono_is_running)
        {
            me.chrono.setColor(1, 0, 0, 1);
        }
        else
        {
            me.chrono.setColor(1, 1, 1, 1);
        }

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
        var loop_speed = (time_speed == 1) ? .05 : 5;
        settimer(func() { me.update(); }, loop_speed);
    }
};

var init = setlistener("/sim/signals/fdm-initialized", func() {
    removelistener(init); # only call once
    var my_pfd = BASIC_PFD.new({'node': 'left.screen'});
    my_pfd.update();
});














