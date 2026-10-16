-- card.lua : separate glass tiles (Alterf style) drawn with cairo
require 'cairo'
pcall(require, 'cairo_xlib')

local HOME    = os.getenv("HOME") or ""
local SCRIPTS = HOME .. "/.config/conky/Alterf/scripts"

-- palette (matches the misty wallpaper + pink bow)
local PINK  = {0.96, 0.66, 0.77}
local GREEN = {0.62, 0.83, 0.66}
local WHITE = {0.95, 0.96, 0.95}
local GREY  = {0.62, 0.67, 0.70}
local DARK  = {0.07, 0.09, 0.10}
local TILE_ALPHA = 0.80   -- tile opacity: raise for darker, lower for glassier

local function p(s)
    local r = conky_parse(s) or ""
    return (r:gsub("^%s+", ""):gsub("%s+$", ""))
end

local function cut(s, n)
    if utf8 and utf8.len(s) and utf8.len(s) > n then
        return s:sub(1, utf8.offset(s, n + 1) - 1) .. "…"
    end
    return s
end

local function title(s)
    return (s:gsub("(%a)([%w']*)", function(a, b) return a:upper() .. b end))
end

local function rrect(cr, x, y, w, h, r)
    cairo_new_sub_path(cr)
    cairo_arc(cr, x + w - r, y + r,     r, -math.pi / 2, 0)
    cairo_arc(cr, x + w - r, y + h - r, r, 0,            math.pi / 2)
    cairo_arc(cr, x + r,     y + h - r, r, math.pi / 2,  math.pi)
    cairo_arc(cr, x + r,     y + r,     r, math.pi,      3 * math.pi / 2)
    cairo_close_path(cr)
end

local function tile(cr, x, y, w, h, r, col, a)
    col = col or DARK
    rrect(cr, x, y, w, h, r)
    cairo_set_source_rgba(cr, col[1], col[2], col[3], a or TILE_ALPHA)
    cairo_fill_preserve(cr)
    cairo_set_source_rgba(cr, 1, 1, 1, 0.10)
    cairo_set_line_width(cr, 1)
    cairo_stroke(cr)
end

local function text(cr, s, x, y, size, bold, col, a, align)
    cairo_select_font_face(cr, "Inter", CAIRO_FONT_SLANT_NORMAL,
        bold and CAIRO_FONT_WEIGHT_BOLD or CAIRO_FONT_WEIGHT_NORMAL)
    cairo_set_font_size(cr, size)
    cairo_set_source_rgba(cr, col[1], col[2], col[3], a or 1)
    if align == "center" or align == "right" then
        local e = cairo_text_extents_t:create()
        if tolua then tolua.takeownership(e) end
        cairo_text_extents(cr, s, e)
        if align == "center" then x = x - e.x_advance / 2 else x = x - e.x_advance end
    end
    cairo_move_to(cr, x, y)
    cairo_show_text(cr, s)
end

local function ring(cr, cx, cy, r, pct, col)
    cairo_set_line_width(cr, 5)
    cairo_set_line_cap(cr, CAIRO_LINE_CAP_ROUND)
    cairo_set_source_rgba(cr, 1, 1, 1, 0.15)
    cairo_arc(cr, cx, cy, r, 0, 2 * math.pi)
    cairo_stroke(cr)
    local a0 = -math.pi / 2
    cairo_set_source_rgba(cr, col[1], col[2], col[3], 1)
    cairo_arc(cr, cx, cy, r, a0, a0 + 2 * math.pi * math.min(pct, 100) / 100)
    cairo_stroke(cr)
end

local function wifi_glyph(cr, cx, cy, col)
    cairo_set_source_rgba(cr, col[1], col[2], col[3], 1)
    cairo_set_line_width(cr, 2.4)
    cairo_set_line_cap(cr, CAIRO_LINE_CAP_ROUND)
    for _, r in ipairs({ 8, 14, 20 }) do
        cairo_arc(cr, cx, cy, r, -3 * math.pi / 4, -math.pi / 4)
        cairo_stroke(cr)
    end
    cairo_arc(cr, cx, cy, 2.2, 0, 2 * math.pi)
    cairo_fill(cr)
end

local function calendar_glyph(cr, x, y, col)
    cairo_set_source_rgba(cr, col[1], col[2], col[3], 1)
    cairo_set_line_width(cr, 2)
    rrect(cr, x, y, 24, 22, 4)
    cairo_stroke(cr)
    rrect(cr, x, y, 24, 8, 4)
    cairo_fill(cr)
    cairo_move_to(cr, x + 7, y - 3);  cairo_line_to(cr, x + 7, y + 3)
    cairo_move_to(cr, x + 17, y - 3); cairo_line_to(cr, x + 17, y + 3)
    cairo_stroke(cr)
end

-- draws a PNG centered at cx,cy scaled to size x size (optionally clipped to a circle)
local function png(cr, path, cx, cy, size, circle)
    local img = cairo_image_surface_create_from_png(path)
    if cairo_surface_status(img) ~= 0 then
        cairo_surface_destroy(img)
        return
    end
    local w = cairo_image_surface_get_width(img)
    local h = cairo_image_surface_get_height(img)
    cairo_save(cr)
    if circle then
        cairo_new_path(cr)
        cairo_arc(cr, cx, cy, size / 2, 0, 2 * math.pi)
        cairo_clip(cr)
    end
    cairo_translate(cr, cx - size / 2, cy - size / 2)
    cairo_scale(cr, size / w, size / h)
    cairo_set_source_surface(cr, img, 0, 0)
    cairo_paint(cr)
    cairo_restore(cr)
    cairo_surface_destroy(img)
end

function conky_draw_card()
    if conky_window == nil then return end

    local cs = cairo_xlib_surface_create(conky_window.display,
        conky_window.drawable, conky_window.visual,
        conky_window.width, conky_window.height)
    local cr = cairo_create(cs)

    -- live values
    local user   = title(p("${execi 600 whoami}"))
    local greet  = p("${execi 300 " .. SCRIPTS .. "/Greeting.sh}")
    local day    = p("${time %d}")
    local wday   = p("${time %A}")
    local month  = p("${time %B %Y}")
    local city   = p("${execi 100 cat ~/.cache/weather.json | jq -r '.name'}")
    local desc   = title(p("${execi 100 cat ~/.cache/weather.json | jq -r '.weather[0].description'}"))
    local temp   = p("${execi 100 cat ~/.cache/weather.json | jq '.main.temp' | awk '{print int($1+0.5)}'}")
    local ssid   = p("${execi 5 " .. SCRIPTS .. "/ssid}")
    local cpu    = tonumber(p("${cpu cpu0}")) or 0
    local mem    = tonumber(p("${memperc}")) or 0
    local fsused = p("${fs_used /}")
    local fssize = p("${fs_size /}")
    local down   = p("${downspeed}")
    local up     = p("${upspeed}")
    local song   = p("${execi 3 playerctl metadata title 2>/dev/null}")
    local artist = p("${execi 3 playerctl metadata artist 2>/dev/null}")

    -- 1. avatar + hello
    tile(cr, 18, 18, 64, 64, 32, PINK, 0.95)                 -- pink ring
    png(cr, HOME .. "/.config/conky/Alterf/res/ava.png", 50, 50, 56, true)
    tile(cr, 96, 18, 294, 64, 32)                            -- hello pill
    text(cr, "Welcome back", 124, 43, 9.5, false, GREY)
    text(cr, "Hello " .. user, 124, 66, 16, true, WHITE)

    -- 2. greeting
    tile(cr, 20, 96, 370, 52, 26)
    text(cr, greet, 44, 130, 21, true, PINK)

    -- 3. calendar + date
    tile(cr, 20, 165, 66, 66, 33, PINK, 0.95)
    calendar_glyph(cr, 41, 181, DARK)
    text(cr, "Calendar", 53, 220, 7.5, true, DARK, 1, "center")
    tile(cr, 96, 165, 294, 66, 33)
    text(cr, day, 124, 210, 34, true, WHITE)
    text(cr, wday, 196, 197, 13, true, PINK)
    text(cr, month, 196, 216, 11, false, WHITE, 0.85)

    -- 4. weather card
    tile(cr, 20, 246, 176, 150, 28)
    text(cr, cut(city, 16), 40, 282, 14, true, PINK)
    text(cr, cut(desc, 20), 40, 302, 10, false, WHITE)
    tile(cr, 32, 318, 152, 62, 31, PINK, 0.92)
    text(cr, temp .. "°C", 52, 359, 25, true, DARK)
    tile(cr, 129, 325, 48, 48, 24, DARK, 0.9)                -- icon circle
    png(cr, HOME .. "/.cache/weather-icon.png", 153, 349, 32, false)

    -- 5. wifi pill
    tile(cr, 206, 246, 184, 64, 32, PINK, 0.95)
    wifi_glyph(cr, 238, 290, DARK)
    text(cr, "Wi-Fi :", 268, 273, 10.5, true, DARK)
    text(cr, cut(ssid, 14), 268, 292, 10, false, DARK)

    -- 6. RAM + CPU
    tile(cr, 206, 322, 88, 74, 26)
    ring(cr, 250, 359, 25, mem, GREEN)
    text(cr, "RAM", 250, 358, 9, true, WHITE, 1, "center")
    text(cr, string.format("%d%%", mem), 250, 369, 7.5, false, GREY, 1, "center")
    tile(cr, 302, 322, 88, 74, 26)
    ring(cr, 346, 359, 25, cpu, GREEN)
    text(cr, "CPU", 346, 358, 9, true, WHITE, 1, "center")
    text(cr, string.format("%d%%", cpu), 346, 369, 7.5, false, GREY, 1, "center")

    -- 7. storage + network
    tile(cr, 20, 410, 176, 62, 31)
    text(cr, "ROOT", 46, 435, 9, true, PINK)
    text(cr, fsused .. " / " .. fssize, 46, 455, 10.5, false, WHITE)
    tile(cr, 206, 410, 184, 62, 31)
    text(cr, "Down", 232, 435, 9, true, PINK)
    text(cr, down, 366, 435, 10, false, WHITE, 1, "right")
    text(cr, "Up", 232, 455, 9, true, PINK)
    text(cr, up, 366, 455, 10, false, WHITE, 1, "right")

    -- 8. music
    tile(cr, 20, 486, 370, 62, 31)
    text(cr, "NOW PLAYING", 46, 510, 8.5, true, PINK)
    if song ~= "" then
        local line = cut(song, 30)
        if artist ~= "" then line = line .. "  ·  " .. cut(artist, 16) end
        text(cr, line, 46, 531, 11.5, true, WHITE)
    else
        text(cr, "Nothing playing", 46, 531, 11.5, false, GREY)
    end

    cairo_destroy(cr)
    cairo_surface_destroy(cs)
end
