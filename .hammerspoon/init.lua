padding = 20

local mash = {
  move    = {"ctrl", "alt", "cmd"},
  focus   = {"ctrl", "cmd"},
}

-- move window left
hs.hotkey.bind(mash.move, "H", function()
  local win = hs.window.focusedWindow()
  local f = win:frame()
  local screen = win:screen()
  local max = screen:frame()

  f.x = max.x + padding
  f.y = max.y + padding
  f.w = (max.w / 2) - padding
  f.h = max.h - padding * 2
  win:setFrame(f)
end)

-- move window right
hs.hotkey.bind(mash.move, "L", function()
  local win = hs.window.focusedWindow()
  local f = win:frame()
  local screen = win:screen()
  local max = screen:frame()

  f.x = max.x + (max.w / 2)
  f.y = max.y + padding
  f.w = (max.w / 2) - padding
  f.h = max.h - padding * 2
  win:setFrame(f)
end)

--fullscreen window
hs.hotkey.bind(mash.move, "M", function()
  local win = hs.window.focusedWindow()
  local f = win:frame()
  local screen = win:screen()
  local max = screen:frame()

  f.x = max.x + padding
  f.y = max.y + padding
  f.w = max.w - padding * 2
  f.h = max.h - padding * 2
  win:setFrame(f)
end)

-- Focus windows
--local function focus(direction)
  --local fn = "focusWindow" .. (direction:gsub("^%l", string.upper))

  --return function()
    --local win = hs.window:focusedWindow()
    --if not win then return end

    --win[fn]()
  --end
--end

--hs.hotkey.bind(mash.focus, "K", focus("north"))
--hs.hotkey.bind(mash.focus, "L", focus("east"))
--hs.hotkey.bind(mash.focus, "J", focus("south"))
--hs.hotkey.bind(mash.focus, "H", focus("west"))


-- lock screen
hs.hotkey.bind(mash.move, "U", function()
    os.execute("/System/Library/CoreServices/Menu\\ Extras/User.menu/Contents/Resources/CGSession -suspend")
end)

-------------------------------------------------------------------------------------
--Bring focus to next display/screen
hs.hotkey.bind(mash.focus, "H", function ()
  focusScreen(hs.window.focusedWindow():screen():next())
end)

--Bring focus to previous display/screen
hs.hotkey.bind(mash.focus, "L", function() 
  focusScreen(hs.window.focusedWindow():screen():previous())
end)

--Predicate that checks if a window belongs to a screen
function isInScreen(screen, win)
  return win:screen() == screen
end

-- Brings focus to the scren by setting focus on the front-most application in it.
-- Also move the mouse cursor to the center of the screen. This is because
-- Mission Control gestures & keyboard shortcuts are anchored, oddly, on where the
-- mouse is focused.
function focusScreen(screen)
  --Get windows within screen, ordered from front to back.
  --If no windows exist, bring focus to desktop. Otherwise, set focus on
  --front-most application window.
  local windows = hs.fnutils.filter(
      hs.window.orderedWindows(),
      hs.fnutils.partial(isInScreen, screen))
  local windowToFocus = #windows > 0 and windows[1] or hs.window.desktop()
  windowToFocus:focus()

  -- Move mouse to center of screen
  local pt = geometry.rectMidPoint(screen:fullFrame())
  mouse.setAbsolutePosition(pt)
end

-------------------------------------------------------------------------------------

-- border

border = nil

function drawBorder()
    if border then
        border:delete()
    end

    local win = hs.window.focusedWindow()
    if win == nil then return end

    local f = win:frame()
    local fx = f.x - 2
    local fy = f.y - 2
    local fw = f.w + 4
    local fh = f.h + 4

    border = hs.drawing.rectangle(hs.geometry.rect(fx, fy, fw, fh))
    border:setStrokeWidth(3)
    border:setStrokeColor({["red"]=0.75,["blue"]=0.14,["green"]=0.83,["alpha"]=0.80})
    border:setRoundedRectRadii(5.0, 5.0)
    border:setStroke(true):setFill(false)
    border:setLevel("floating")
    border:show()
end

drawBorder()

windows = hs.window.filter.new(nil)
windows:subscribe(hs.window.filter.windowFocused, function () drawBorder() end)
windows:subscribe(hs.window.filter.windowUnfocused, function () drawBorder() end)
windows:subscribe(hs.window.filter.windowMoved, function () drawBorder() end)

-------------------------------------------------------------------------------------
    
--reload config
hs.hotkey.bind({"cmd", "ctrl"}, "R", function()
  hs.reload()
end)
hs.alert.show("Config loaded")
