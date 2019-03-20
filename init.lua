-- Layout

local mash      = {"cmd", "alt"}

positions = {
  maximized = hs.layout.maximized,
  centered = {x=0.15, y=0.15, w=0.7, h=0.7},

  left25 = {x=0, y=0, w=0.25, h=1},
  left34 = {x=0, y=0, w=0.34, h=1},
  left40 = {x=0, y=0, w=0.40, h=1},
  left50 = hs.layout.left50,
  left60 = {x=0, y=0, w=0.60, h=1},
  left66 = {x=0, y=0, w=0.66, h=1},

  right34 = {x=0.66, y=0, w=0.34, h=1},
  right40 = {x=0.60, y=0, w=0.40, h=1},
  right50 = hs.layout.right50,
  right60 = {x=0.40, y=0, w=0.60, h=1},
  right66 = {x=0.34, y=0, w=0.66, h=1},
  right75 = {x=0.25, y=0, w=0.75, h=1},

  upper50 = {x=0, y=0, w=1, h=0.5},
  upper50Left50 = {x=0, y=0, w=0.5, h=0.5},
  upper50Right50 = {x=0.5, y=0, w=0.5, h=0.5},

  lower50 = {x=0, y=0.5, w=1, h=0.5},
  lower50Left50 = {x=0, y=0.5, w=0.5, h=0.5},
  lower50Right50 = {x=0.5, y=0.5, w=0.5, h=0.5}
}

function bindKey(key, fn)
  hs.hotkey.bind(mash, key, fn)
end

bindKey('1', function()
  hs.application.open("Agenda", 0, true)
  hs.application.open("Google Chrome", 0, true)
  hs.layout.apply({
    {"Agenda",        nil, screen, positions.left34,  nil, nil},
    {"Google Chrome", nil, screen, positions.right66, nil, nil},
  })
end)

bindKey('2', function()
hs.application.open("Books", 0, true)
hs.application.open("Xcode-beta", 0, true)
hs.layout.apply({
{"Books", nil, screen, positions.left40, nil, nil},
{"Xcode", nil, screen, positions.right60,  nil, nil},
})
end)

-- Eisu

local simpleCmd = false
local leftSet = false
local rightSet = false

local leftCmd = 0x37
local rightCmd = 0x36
local eisuu = 0x66
local kana = 0x68

local function keyStroke(modifiers, character)
    hs.eventtap.keyStroke(modifiers, character, 5000)
end

local function eikanaEvent(event)
    local c = event:getKeyCode()
    local f = event:getFlags()
    if event:getType() == hs.eventtap.event.types.keyDown then
        if f['cmd'] and c then
            simpleCmd = true
        end
    elseif event:getType() == hs.eventtap.event.types.flagsChanged then
        if f['cmd'] then
            if c  == leftCmd then
                leftSet = true
                rightSet = false
            elseif c == rightCmd then
                rightSet = true
                leftSet = false
            end
        else
            if simpleCmd == false then
                if leftSet then
                    keyStroke({}, eisuu)
                elseif rightSet then
                    keyStroke({}, kana)
                end
            end
                simpleCmd = false
                leftSet = false
                rightSet = false
        end
    end
end

eventtap = hs.eventtap.new({hs.eventtap.event.types.keyDown, hs.eventtap.event.types.flagsChanged}, eikanaEvent)

eventtap:start()

-- Press Cmd+Q twice to quit

local quitModal = hs.hotkey.modal.new('cmd','q')

function quitModal:entered()
    -- don't let Finder, Fantastical or Things quit
    local app = hs.application.frontmostApplication()
    if (app:title() ~= "Finder") and
       (app:title() ~= "Fantastical") and
       (app:title() ~= "Things")  then
        hs.alert.show("Press Cmd+Q again to quit", 1)
    end

    hs.timer.doAfter(1, function() quitModal:exit() end)
end

local function doQuit()
    -- don't let Finder, Fantastical or Things quit
    local app = hs.application.frontmostApplication()
    if (app:title() == "Finder") or
       (app:title() == "Fantastical") or
       (app:title() == "Things")  then
        hs.window.frontmostWindow():close()
    else
        app:kill()
    end
end

quitModal:bind('cmd', 'q', doQuit)

quitModal:bind('', 'escape', function() quitModal:exit() end)
