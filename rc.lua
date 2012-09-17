-- Standard awesome library
require("awful")
require("awful.autofocus")
require("awful.rules")
require("awful.remote")
-- Theme handling library
require("beautiful")
-- Notification library
require("naughty")
-- Load Vicious library
vicious = require("vicious")

io.output(os.getenv("HOME") .. "/.config/awesome/awesome.sql")

-- {{{ Variable definitions
-- Themes define colours, icons, and wallpapers
--beautiful.init("/usr/share/awesome/themes/sunjack/theme.lua")
--beautiful.init(os.getenv("HOME") .. "/.config/awesome/themes/dust/theme.lua")
--beautiful.init(os.getenv("HOME") .. "/.config/awesome/themes/strict/theme.lua")
--beautiful.init(os.getenv("HOME") .. "/.config/awesome/theme/theme.lua")
beautiful.init(os.getenv("HOME") .. "/.config/awesome/themes/awesome-solarized/dark/theme.lua")

-- This is used later as the default terminal and editor to run.
--terminal = 'xterm -fg white -bg gray7 -fa "Inconsolata" -fs 12'
terminal = "urxvtc"
editor = os.getenv("EDITOR") or "vim"
editor_cmd = terminal .. " -e " .. editor

-- Default modkey.
modkey = "Mod4"

-- Table of layouts to cover with awful.layout.inc, order matters.
layouts =
{
    awful.layout.suit.spiral,
    awful.layout.suit.floating,
    awful.layout.suit.tile,
    awful.layout.suit.tile.left,
    awful.layout.suit.tile.bottom,
    awful.layout.suit.tile.top,
    awful.layout.suit.fair,
    awful.layout.suit.fair.horizontal,
    awful.layout.suit.spiral.dwindle,
    awful.layout.suit.max,
    awful.layout.suit.max.fullscreen,
    awful.layout.suit.magnifier
}
-- }}}

-- {{{ Tags
-- Define a tag table which will hold all screen tags.
tags = {
    names  = { "1", "2", "3", "4", "5", "6", "7", "8" },
    layout = { layouts[3], layouts[3], layouts[3], layouts[2], layouts[3], layouts[3], layouts[3], layouts[3] }
}

for s = 1, screen.count() do
    -- Each screen has its own tag table.
    tags[s] = awful.tag(tags.names, s, tags.layout)
end
-- }}}

-- {{{ Menu
-- Create a laucher widget and a main menu
myawesomemenu = {
   { "manual", terminal .. " -e man awesome" },
   { "edit config", editor_cmd .. " " .. awful.util.getdir("config") .. "/rc.lua" },
   { "restart", awesome.restart },
   { "quit", awesome.quit }
}

mymainmenu = awful.menu({ items = { { "awesome", myawesomemenu, beautiful.awesome_icon },
                                    { "open terminal", terminal }
                                  }
                        })

mylauncher = awful.widget.launcher({ image = image(beautiful.awesome_icon),
                                     menu = mymainmenu })
-- }}}

-- {{{ Wibox
-- Create a textclock widget
mytextclock = awful.widget.textclock({ align = "right"}, string.format("<span foreground='%s'>%%b %%d, </span><span foreground='%s'>%%l:%%M %%p </span>", beautiful.colors.base00, beautiful.colors.blue))

-- Create a systray
mysystray = widget({ type = "systray" })

-- Create a wibox for each screen and add it
mywibox1 = {}
mywibox2 = {}
mypromptbox = {}
mylayoutbox = {}
mytaglist = {}
mytaglist.buttons = awful.util.table.join(
                    awful.button({ }, 1, awful.tag.viewonly),
                    awful.button({ modkey }, 1, awful.client.movetotag),
                    awful.button({ }, 3, awful.tag.viewtoggle),
                    awful.button({ modkey }, 3, awful.client.toggletag),
                    awful.button({ }, 4, awful.tag.viewnext),
                    awful.button({ }, 5, awful.tag.viewprev)
                    )
mytasklist = {}
mytasklist.buttons = awful.util.table.join(
                     awful.button({ }, 1, function (c)
                                              if c == client.focus then
                                                  c.minimized = true
                                              else
                                                  if not c:isvisible() then
                                                      awful.tag.viewonly(c:tags()[1])
                                                  end
                                                  -- This will also un-minimize
                                                  -- the client, if needed
                                                  client.focus = c
                                                  c:raise()
                                              end
                                          end),
                     awful.button({ }, 3, function ()
                                              if instance then
                                                  instance:hide()
                                                  instance = nil
                                              else
                                                  instance = awful.menu.clients({ width=250 })
                                              end
                                          end),
                     awful.button({ }, 4, function ()
                                              awful.client.focus.byidx(1)
                                              if client.focus then client.focus:raise() end
                                          end),
                     awful.button({ }, 5, function ()
                                              awful.client.focus.byidx(-1)
                                              if client.focus then client.focus:raise() end
                                          end))


-- Initialize widget
cpuwidget = awful.widget.graph()
-- Graph properties
cpuwidget:set_width(100)
cpuwidget:set_background_color("#494B4F")
cpuwidget:set_color("#FF5656aa")
-- Register widget
vicious.register(cpuwidget, vicious.widgets.cpu, "$1", 0.5)


local cputxtwidget = widget({ type = "textbox" })
cputxtwidget.text = string.format("<span foreground='%s'> cpu: </span>", beautiful.colors.cyan)

local seperator = widget({ type = "textbox" })
seperator.text = "<span foreground='#ffffff'>|</span>"


-- Initialize widget
mpdwidget = widget({ type = "textbox" })
-- Register widget
vicious.register(mpdwidget, vicious.widgets.mpd,
function (widget, args)
if args["{state}"] == "Stop" then 
    mpdwidget_str = string.format(" <span foreground='%s'>Music: </span><span foreground='%s'>" .. args["{Title}"] .. " </span> ", beautiful.colors.base00, beautiful.colors.orange)
    return mpdwidget_str
else 
    mpdwidget_str = string.format(" <span foreground='%s'>Music: </span><span foreground='%s'> - </span> ", beautiful.colors.base00, beautiful.colors.orange)
    return mpdwidget_str
end
end, 10)

local batwidget = widget({ type = "textbox" })
vicious.register(batwidget, vicious.widgets.bat, " <span foreground='#ce2c51'>bat: </span><span foreground='#66D9EF'>$1$2% $3</span> ", 20, "BAT0")

local pkgwidget = widget({ type = "textbox" })
local pkgwidget_str = string.format(" <span foreground='%s'>Updates: </span><span foreground='%s'>$1</span> ", beautiful.colors.base00, beautiful.colors.orange)
vicious.register(pkgwidget, vicious.widgets.pkg, pkgwidget_str, 900, "Arch")

local weatherwidget = widget({ type = "textbox" })
local weatherwidget_str = string.format(" <span foreground='%s'>Weather: </span><span foreground='%s'>${weather} ${tempf} F</span> ", beautiful.colors.base00, beautiful.colors.orange)
vicious.register(weatherwidget, vicious.widgets.weather, weatherwidget_str, 3000, "KSYR")

local volwidget = widget({ type = "textbox" })
local volwidget_str = string.format(" <span foreground='%s'>vol: </span><span foreground='%s'>$1</span> ", beautiful.colors.base00, beautiful.colors.orange)
vicious.register(volwidget, vicious.widgets.volume, volwidget_str, 0.1, 'Master')

local thermalwidget  = widget({ type = "textbox" })
local thermalwidget_str = string.format(" <span foreground='%s'>temp: </span><span foreground='%s'>$1</span> ", beautiful.colors.base00, beautiful.colors.orange)
vicious.register(thermalwidget, vicious.widgets.thermal, thermalwidget_str, 20, "thermal_zone0")

local wifiwidget = widget({ type = "textbox" })
local wifiwidget_str = string.format(" <span foreground='%s'>wifi: </span><span foreground='%s'>${ssid} ${link} </span>", beautiful.colors.base00, beautiful.colors.orange)
vicious.register(wifiwidget, vicious.widgets.wifi, wifiwidget_str, 60, "wlan0")

local memwidget = widget({ type = "textbox" })
local memwidget_str = string.format(" <span foreground='%s'>mem: </span><span foreground='%s'>$2MB/$3MB</span> ", beautiful.colors.base00, beautiful.colors.orange)
vicious.register(memwidget, vicious.widgets.mem, memwidget_str, 30)


for s = 1, screen.count() do
    -- Create a promptbox for each screen
    mypromptbox[s] = awful.widget.prompt({ layout = awful.widget.layout.horizontal.leftright, prompt = "<span foreground='#ff0000'>Run: </span>" })
    -- Create an imagebox widget which will contains an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    mylayoutbox[s] = awful.widget.layoutbox(s)
    mylayoutbox[s]:buttons(awful.util.table.join(
                           awful.button({ }, 1, function () awful.layout.inc(layouts, 1) end),
                           awful.button({ }, 3, function () awful.layout.inc(layouts, -1) end),
                           awful.button({ }, 4, function () awful.layout.inc(layouts, 1) end),
                           awful.button({ }, 5, function () awful.layout.inc(layouts, -1) end)))
    -- Create a taglist widget
    mytaglist[s] = awful.widget.taglist(s, awful.widget.taglist.label.all, mytaglist.buttons)

    -- Create a tasklist widget
    mytasklist[s] = awful.widget.tasklist(function(c)
                                              return awful.widget.tasklist.label.currenttags(c, s)
                                          end, mytasklist.buttons)

    -- Create the wibox
    mywibox1[s] = awful.wibox({ position = "top", screen = s, opacity = 1, height = "16" })
    -- Add widgets to the wibox - order matters
    mywibox1[s].widgets = {
        {
            mylauncher,
            mytaglist[s],
            mypromptbox[s],
            layout = awful.widget.layout.horizontal.leftright
        },
        mylayoutbox[s],
        mytextclock,
        s == 1 and mysystray or nil,
        ---------------
        --cpuwidget,
        --cputxtwidget,
        memwidget,
        thermalwidget,
        volwidget,
        weatherwidget,
        mpdwidget,
        pkgwidget,
        mytasklist[s],
        ----------
        layout = awful.widget.layout.horizontal.rightleft
    }
--    mywibox2[s] = awful.wibox({ position = "bottom", screen = s, opacity = 1 })
--    -- Add widgets to the wibox - order matters
--    mywibox2[s].widgets = {
--        cputxtwidget,
--        cpuwidget,
--        seperator,
--        memwidget,
--        seperator,
--        thermalwidget,
--        seperator,
--        volwidget,
--        seperator,
--        weatherwidget,
--        seperator,
--        mpdwidget,
--        seperator,
--        pkgwidget,
--        seperator,
--        layout = awful.widget.layout.horizontal.leftright
--    }
end
-- }}}

-- {{{ Mouse bindings
root.buttons(awful.util.table.join(
    awful.button({ }, 3, function () mymainmenu:toggle() end),
    awful.button({ }, 4, awful.tag.viewnext),
    awful.button({ }, 5, awful.tag.viewprev)
))
-- }}}


-- {{{ Key bindings
globalkeys = awful.util.table.join(
    awful.key({ modkey,}, "o",
        function () 
            --naughty.notify({ text = tostring(dbcon), timeout = 10, hover_timeout = 0.5, })
            --if not tostring(dbcon):match'closed' then
            --    dbcon:close()
            --else
            --    dbcon = dbenv:connect(os.getenv("HOME") .. "/.config/awesome/awesome.db")
            --end
        end),
    awful.key({ modkey,           }, "Left",
        function (c) 
            awful.tag.viewprev()       
        end),
    awful.key({ modkey,           }, "Right", 
        function (c) 
            awful.tag.viewnext()
        end),
    awful.key({ modkey,           }, "Escape", awful.tag.history.restore),
    awful.key({ modkey,           }, "e",   revelation    ),

    awful.key({ modkey,           }, "j",
        function ()
            awful.client.focus.byidx( 1)
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey,           }, "k",
        function ()
            awful.client.focus.byidx(-1)
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey,           }, "w", function () mymainmenu:show({keygrabber=true}) end),

    -- Layout manipulation
    awful.key({ modkey,           }, "l",     function () awful.tag.incmwfact( 0.05)    end),
    awful.key({ modkey,           }, "h",     function () awful.tag.incmwfact(-0.05)    end),
    awful.key({ modkey, "Shift"   }, "j", function () awful.client.swap.byidx(  1)    end),
    awful.key({ modkey, "Shift"   }, "k", function () awful.client.swap.byidx( -1)    end),
    awful.key({ modkey, "Control" }, "j", function () awful.screen.focus_relative( 1) end),
    awful.key({ modkey, "Control" }, "k", function () awful.screen.focus_relative(-1) end),
    awful.key({ modkey,           }, "u", awful.client.urgent.jumpto),
    awful.key({ modkey,           }, "Tab",
        function ()
            awful.client.focus.history.previous()
            if client.focus then
                client.focus:raise()
            end
        end),

    -- Standard program
    awful.key({ modkey,           }, "Return", function () awful.util.spawn(terminal) end),
    awful.key({ modkey, "Control" }, "r", awesome.restart),
    awful.key({ modkey, "Shift"   }, "q", awesome.quit),

    --awful.key({ modkey,           }, "l",     function () awful.tag.incmwfact( 0.05)    end),
    --awful.key({ modkey,           }, "h",     function () awful.tag.incmwfact(-0.05)    end),
    awful.key({ modkey, "Shift"   }, "h",     function () awful.tag.incnmaster( 1)      end),
    awful.key({ modkey, "Shift"   }, "l",     function () awful.tag.incnmaster(-1)      end),
    awful.key({ modkey, "Control" }, "h",     function () awful.tag.incncol( 1)         end),
    awful.key({ modkey, "Control" }, "l",     function () awful.tag.incncol(-1)         end),
    awful.key({ modkey,           }, "space", function () awful.layout.inc(layouts,  1) end),
    awful.key({ modkey, "Shift"   }, "space", function () awful.layout.inc(layouts, -1) end),

    awful.key({ modkey, "Control" }, "n", awful.client.restore),

    -- Prompt
    awful.key({ modkey },            "r",     function () mypromptbox[mouse.screen]:run() end),

    awful.key({ modkey }, "x",
              function ()
                  awful.prompt.run({ prompt = "Run Lua code: " },
                  mypromptbox[mouse.screen].widget,
                  awful.util.eval, nil,
                  awful.util.getdir("cache") .. "/history_eval")
              end)
)

clientkeys = awful.util.table.join(
    awful.key({ modkey, }, "f",
        function (c) 
            c.fullscreen = not c.fullscreen  
        end),
    awful.key({ modkey, "Shift"   }, "c", 
        function (c) 
            c:kill()
        end),
    awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle),
    awful.key({ modkey, "Control" }, "Return", 
        function (c) 
            c:swap(awful.client.getmaster()) 
        end),
    awful.key({ modkey, }, "o", awful.client.movetoscreen),
    awful.key({ modkey, "Shift"   }, "r",
        function (c) 
            c:redraw()
        end),
    awful.key({ modkey, }, "t",
        function (c) 
            c.ontop = not c.ontop
        end),
    awful.key({ modkey, }, "n",
        function (c)
            -- The client currently has the input focus, so it cannot be
            -- minimized, since minimized clients can't have the focus.
            c.minimized = true
        end),
    awful.key({ modkey, }, "m",
        function (c)
            c.maximized_horizontal = not c.maximized_horizontal
            c.maximized_vertical   = not c.maximized_vertical
        end)
)

-- Compute the maximum number of digit we need, limited to 9
keynumber = 0
for s = 1, screen.count() do
   keynumber = math.min(9, math.max(#tags[s], keynumber));
end

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it works on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, keynumber do
    globalkeys = awful.util.table.join(globalkeys,
        awful.key({ modkey }, "#" .. i + 9,
            function ()
                local screen = mouse.screen
                if tags[screen][i] then
                    awful.tag.viewonly(tags[screen][i])
                end
            end),
        awful.key({ modkey, "Control" }, "#" .. i + 9,
            function ()
                local screen = mouse.screen
                if tags[screen][i] then
                    awful.tag.viewtoggle(tags[screen][i])
                end
            end),
        awful.key({ modkey, "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus and tags[client.focus.screen][i] then
                          awful.client.movetotag(tags[client.focus.screen][i])
                      end
                  end),
        awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus and tags[client.focus.screen][i] then
                          awful.client.toggletag(tags[client.focus.screen][i])
                      end
                  end))
end

clientbuttons = awful.util.table.join(
    awful.button({ }, 1, 
        function (c) 
            client.focus = c 
            c:raise() 
        end),
    awful.button({ modkey }, 1, awful.mouse.client.move),
    awful.button({ modkey }, 3, awful.mouse.client.resize))

-- Set keys
root.keys(globalkeys)
-- }}}

function notify_window_open ()
    naughty.notify({ text="notification content", timeout=50 })
end

-- {{{ Rules
-- NOTE: This section tends to be distro specific. Use the xprop utility to find the WM_CLASS
awful.rules.rules = {
    -- All clients will match this rule.
    { rule = { },
      properties = { border_width = beautiful.border_width,
                     border_color = beautiful.border_normal,
                     focus = true,
                     keys = clientkeys,
                     buttons = clientbuttons } },
    { rule = { class = "MPlayer" },
        properties = { floating = true, tag = tags[1][4]} },
    { rule = { class = "Vlc" },
        properties = { floating = true, tag = tags[1][4]} },
    { rule = { class = "Tk" },
        properties = { floating = true, tag = tags[1][4], switchtotag=true } },
    { rule = { class = "Chromium" },
        properties = { tag = tags[1][2] } },
    { rule = { class = "Exe" }, 
        properties = { floating = true } },
    { rule = { class = "Evince" },
        properties = { tag = tags[1][3] } },
    { rule = { name = "Dia v0.97.2" },
        properties = { tag = tags[1][4], width = 100, height = 850, x = 0, y = 20 } },
    { rule = { name = "brainstorm" },
        properties = { tag = tags[1][4], x = 0, y = 20 } },
}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.add_signal("manage", function (c, startup)
    -- Add a titlebar
   -- awful.titlebar.add(c, { modkey = modkey })

    -- Enable sloppy focus
    c:add_signal("mouse::enter", function(c)
        client.focus = c
        c:raise()
    end)
    c:add_signal("mouse::press", function(c)
        client.focus = c
        c:raise()
    end)

    if not startup then
        -- Set the windows at the slave,
        -- i.e. put it at the end of others instead of setting it master.
         awful.client.setslave(c)

        -- Put windows in a smart way, only if they does not set an initial position.
        if not c.size_hints.user_position and not c.size_hints.program_position then
            awful.placement.no_overlap(c)
            awful.placement.no_offscreen(c)
        end
    end
end)

client.add_signal("focus", function(c) 
                                c.border_color = beautiful.border_focus 
                                c.opacity = 1
                                --naughty.notify({ text = string.format("name :: %s :: focused", c.name), timeout = 1, hover_timeout = 0.5, })
                                --if not tostring(dbcon):match'closed' then dbcon:execute(string.format('insert into focus values("%s", "%s", "%s", %d, "%s");', c.name, c.class, "focus", os.time(), os.date())) end
                                --io.write(string.format('insert into focus values("%s", "%s", "%s", %d, "%s");\n', c.name, c.class, "focus", os.time(), os.date()))
                                --naughty.notify({ text = string.format("class :: %s :: focused", c.class), timeout = 1, hover_timeout = 0.5, })
                            end)
client.add_signal("unfocus", function(c) 
                                c.border_color = beautiful.border_normal 
                                c.opacity = 0.6
                                --io.write(string.format('insert into focus values("%s", "%s", "%s", %d, "%s");\n', c.name, c.class, "unfocus", os.time(), os.date()))
                                --naughty.notify({ text = string.format("class :: %s :: unfocused", c.class), timeout = 1, hover_timeout = 0.5, })
                            end)
-- }}}

-- CALENDAR
local calendar = nil

function remove_calendar()
    if calendar ~= nil then
        naughty.destroy(calendar)
        calendar = nil
    end
end

function add_calendar()
    remove_calendar()
    local day = os.date("%d")
    if day:find('^0') then
        day = day:sub(2)
    end

    local cal = awful.util.pread("cal")
    
    month_end = string.find(cal, 'Sa')
    month = string.format("<span color='%s'>" .. cal:sub(1,month_end+1) .. "</span><span color='%s'>", beautiful.colors.base00, beautiful.colors.blue)
    cal = cal:sub(month_end+2)
    i = tostring(cal:find(day))
    cal = string.gsub(cal, day, '%%s', 1)
    color  =  string.format("</span><span color='%s'>"..day.."</span>".."<span color='%s'>", beautiful.colors.orange, beautiful.colors.blue)
    cal = string.format('<span font_desc="%s">%s</span>', 'terminus', month ..cal)
    cal = cal .. "</span>"
    calendar = naughty.notify({
        text = string.format(cal, color),
        timeout = 10, hover_timeout = 0.5,
--        width = 176,
--        height = 150,
    })
end

mytextclock:add_signal("mouse::enter", add_calendar)
mytextclock:add_signal("mouse::leave", remove_calendar)

-- ArchLinux Update
local updatelist = nil

function remove_updatelist()
    if updatelist ~= nil then
        naughty.destroy(updatelist)
        updatelist = nil
    end
end

function add_updatelist()
    remove_updatelist()
    local io = { popen = io.popen }
    local s = io.popen("pacman -Qu")
    local str = ''

    for line in s:lines() do
        str = str .. line .. "\n"
    end
    if string.len(str) == 0 then
        str = "No Updates"
    end
    s:close()
    updatelist = naughty.notify({
        text = str,
        timeout = 10, hover_timeout = 0.5,
    })
end

pkgwidget:add_signal("mouse::enter", add_updatelist)
pkgwidget:add_signal("mouse::leave", remove_updatelist)

