require "tabletools"
spaces = require("hs._asm.undocumented.spaces")

padding = 20

local wf=hs.window.filter.new():setDefaultFilter{}

local mash = {
    move    = {"ctrl", "alt", "cmd"},
    focus   = {"ctrl", "cmd"},
    hyper   = {"ctrl", "cmd", "alt", "shift"},
}

-------------------------------------------------------------------------------------

function sleep(n)
    os.execute("sleep " .. tonumber(n))
end

function makeWindowFullscreen(win)
    local f = win:frame()
    local screen = win:screen()
    local max = screen:frame()

    f.x = max.x + padding
    f.y = max.y + padding
    f.w = max.w - padding * 2
    f.h = max.h - padding * 2
    win:setFrame(f)
end

-- maximize window on open

--wf:subscribe(hs.window.filter.windowCreated, makeWindowFullscreen)

-- move window left
hs.hotkey.bind(mash.hyper, "H", function()
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
hs.hotkey.bind(mash.hyper, "L", function()
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
    makeWindowFullscreen(win)
end)

-- move window to the screen to the left
hs.hotkey.bind(mash.move, "H", function()
    local win = hs.window.focusedWindow()
    win:moveOneScreenWest()
    makeWindowFullscreen(win)
end)

-- move window to the screen to the right
hs.hotkey.bind(mash.move, "L", function()
    local win = hs.window.focusedWindow()
    win:moveOneScreenEast()
    makeWindowFullscreen(win)
end)

-------------------------------------------------------------------------------------

--switch windows on same screen
hs.hotkey.bind(mash.focus, "B", function()
    local win = hs.window.focusedWindow():sendToBack()
end)

-------------------------------------------------------------------------------------


-- lock screen
hs.hotkey.bind(mash.move, "D", function()
    hs.caffeinate.lockScreen()
end)

-- sleep screen
hs.hotkey.bind(mash.move, "S", function()
    hs.caffeinate.systemSleep()
end)

-------------------------------------------------------------------------------------
--Bring focus to next display/screen

function bindFocusDisplays()
    hs.hotkey.bind(mash.focus, "H", function ()
        focusScreen(hs.screen.mainScreen():toWest())
    end)

    --Bring focus to previous display/screen
    hs.hotkey.bind(mash.focus, "L", function() 
        focusScreen(hs.screen.mainScreen():toEast())
    end)
end

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

    for key, window in pairs(windows) do 
        --print(window)
        if isInScreen(screen, window) then
            if window:isStandard() then
                window:focus()
                break
            end
        end
    end
end

bindFocusDisplays()
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
    border:setStrokeWidth(4)
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

--fullscreen stuff

hs.hotkey.bind(mash.focus, "F", function()

    for key, spaceId in pairs(spaces.query(spaces.allSpaces)) do 
        if spaces.spaceType(spaceId) == spaces.types.tiled then
            spaces.changeToSpace(spaceId)
            break
        end
    end
end)

-------------------------------------------------------------------------------------

-- map up and down arrows

hs.hotkey.bind(mash.focus, "K", function()
    hs.eventtap.keyStroke({}, "up")
end)

hs.hotkey.bind(mash.focus, "J", function()
    hs.eventtap.keyStroke({}, "down")
end)

-------------------------------------------------------------------------------------

-- timer
function SecondsToClock(seconds)
    local seconds = tonumber(seconds)

    if seconds <= 0 then
        return "00:00:00";
    else
        hours = string.format("%02.f", math.floor(seconds/3600));
        mins = string.format("%02.f", math.floor(seconds/60 - (hours*60)));
        secs = string.format("%02.f", math.floor(seconds - hours*3600 - mins *60));
        return hours..":"..mins..":"..secs
    end
end

local stopwatchCount = 0

function stopwatchFunction()
    hs.notify.new(nil, {
        title = 'Timer',
        informativeText = SecondsToClock(stopwatchCount),
    }):send()

    stopwatchCount = stopwatchCount + 1

end

local stopwatch = hs.timer.new(1, stopwatchFunction)

hs.hotkey.bind(mash.move, "T", function()
    if stopwatch:running() then
        stopwatchCount = 0
        hs.notify.withdrawAll()
        stopwatch:stop()
    else
        stopwatchFunction()
        stopwatch:start()
    end
end)

-------------------------------------------------------------------------------------
--reset screen stuff

moveWinToSpace = function(win, screen, spaceId)
    local moveIt = true
        
    if screen == nil or screen == win:screen() then
        screenIt = false
    else
        screenIt = true
    end
    
    if spaceId ~= nil then
        for i, val in ipairs(win:spaces()) do
            if val == spaceId then
                moveIt = false
                break
            end
        end
    else
        moveIt = false
    end

    if screenIt then
        win:moveToScreen(screen)
    end
    
    if moveIt then
        spaces.changeToSpace(spaceId)
        win:spacesMoveTo(spaceId)
    end

    makeWindowFullscreen(win)
end

moveToSpace = function(app, screen, spaceId)
    for i, win in ipairs(app:allWindows()) do
        moveWinToSpace(win, screen, spaceId)
    end
end

resetScreens = function()
    local screens = {}
    local allScreens = hs.screen.allScreens()

    for i, screen in ipairs(allScreens) do
        screens[screen:position() + 1] = screen
    end

    local spacesDesc = spaces.query()
    local spacesAsc = {}

    for i = #spacesDesc, 1, -1 do
        table.insert(spacesAsc, spacesDesc[i])
    end

    local iterm = hs.application.get('iTerm2')
    local slack = hs.application.get('Slack')
    local outlook = hs.application.get('Microsoft Outlook')
    --local radiant = hs.application.get('Radiant Player')
    local chrome = hs.application.get('Google Chrome')
    local mvim = hs.application.get('MacVim')

    for i, name in ipairs({iterm, slack, outlook, '', ''}) do
        if name ~= '' then
            moveToSpace(name, screens[1], spacesAsc[i])
            sleep(0.001)
        end
    end
    local mvimScreen
    local chromeScreen
    local mvimSpace = nil
    local chromeSpace = nil

    if #screens < 3 then
        mvimScreen = screens[1]
        chromeScreen = screens[1]
        mvimSpace = spacesDesc[2]
        chromeSpace = spacesDesc[1]

    elseif #screens == 3 then
        mvimScreen = screens[2]
        chromeScreen = screens[3]
    end

    moveToSpace(chrome, chromeScreen, chromeSpace)
    moveWinToSpace(chrome:findWindow('Google Play Music'), screens[1], spacesAsc[4])

    moveToSpace(mvim, mvimScreen, mvimSpace)

end

--caffeinate

local watcher = hs.caffeinate.watcher

--do stuff when you wake from sleep
function handleCaffeine(event)
    if event == watcher.sessionDidBecomeActive or 
        event == watcher.screensDidWake or
        event == watcher.systemDidWake or
        event == watcher.screensDidUnlock then
        resetScreens()
    end
end

cf = watcher.new(handleCaffeine)
cf:start()

hs.hotkey.bind({"cmd", "ctrl"}, "C", function()
    print('resetting')
    resetScreens()
end)

-------------------------------------------------------------------------------------
--screenwatcher

local screenWatcher = hs.screen.watcher

sw = screenWatcher.new(resetScreens)
sw:start()

-------------------------------------------------------------------------------------

hs.hotkey.bind(mash.move, "C", function()
    local consoleWin = hs.console.hswindow()
    local screen = hs.window.focusedWindow():screen()

    consoleWin:moveToScreen(screen):focus()

end)

-------------------------------------------------------------------------------------

hs.hotkey.bind(mash.move, "N", function()
    local app
    app = hs.application.get('Notes')

    if not app then
        hs.application.open('Notes')
        app = hs.application.get('Notes')
    end

    local win = app:mainWindow()

    local screen = hs.window.focusedWindow():screen()

    win:moveToScreen(screen):focus()

end)

-------------------------------------------------------------------------------------
-- notify to sit up straight
hs.timer.doEvery(hs.timer.minutes(5), function ()
    hs.alert.show("Check Posture!")
    hs.sound.getByName("Glass"):play()
end)

-------------------------------------------------------------------------------------

--reload config
hs.hotkey.bind({"cmd", "ctrl"}, "R", function()
    hs.reload()
end)
hs.alert.show("Config loaded")
