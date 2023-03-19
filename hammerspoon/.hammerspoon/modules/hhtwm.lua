hhtwm = require('hhtwm')
hhtwm.screenMargin = { top = 50, bottom = 50, left = 250, right = 250 }
hhtwm.margin = 15

hhtwm.defaultLayout = 'main-left'

hhtwm.start()

-- TODO - remove w/ defaults
hhtwm.setLayout('tabbed-left')
hhtwm.tile()

-- TODO - test sending to Desktop #2


hs.window.animationDuration = 0
-- https://github.com/szymonkaliski/dotfiles/blob/08779bff9fa71c35464922123a4a3a4b564e3dd2/Dotfiles/hammerspoon/bindings/tiling.lua#L99

local bind = function(key, fn)
    hs.hotkey.bind({ 'ctrl', 'shift' }, key, fn, nil, fn)
end

local log = hs.logger.new('init', 'debug');

local swap = function(dir)
    local win = hs.window.frontmostWindow()
    log.d('swap', win)
    hhtwm.swapInDirection(win, dir)
end

-- swap window
hs.fnutils.each({
    { key = 'h', dir = "west" },
    { key = 'j', dir = "south" },
    { key = 'k', dir = "north" },
    { key = 'l', dir = "east" },
}, function(obj)
    bind(obj.key, function() swap(obj.dir) end)
end)

local throw = function(dir)
    local win = hs.window.frontmostWindow()
    hhtwm.throwToScreenUsingSpaces(win, dir)
    -- hhtwm.throwToSpace(win, 1)
end

hs.fnutils.each({
    { key = ']', dir = 'prev' },
    { key = '[', dir = 'next' },
}, function(obj)
    bind(obj.key, function() throw(obj.dir) end)
end)

local resize = function(resize)
    hhtwm.resizeLayout(resize)
end

hs.fnutils.each({
    { key = ',', dir = 'thinner' },
    { key = '.', dir = 'wider' },
    { key = '-', dir = 'shorter' },
    { key = '=', dir = 'taller' }
}, function(obj)
    bind(obj.key, function() resize(obj.dir) end)
end)



-- [c]ycle layouts
-- bind('c', function () hhtwm.setLayout('main-left') end)
--
-- hhtwm.getLayouts()

bind('c', function() hhtwm.setLayout('tabbed-left') end)

-- [r]eset
bind('r', hhtwm.reset)

-- re[t]ile
bind('t', hhtwm.tile)

-- [e]qualize
bind('e', hhtwm.equalizeLayout)

-- [s]tart
bind('s', hhtwm.start)

-- sto[p]
bind('p', hhtwm.stop)

-- [g]et layout
bind('g', function()
    hs.alert(hhtwm.getLayout())
end)

-- toggle [f]loat
bind('f', function()
    local win = hs.window.frontmostWindow()

    if not win then return end

    hhtwm.toggleFloat(win)

    if hhtwm.isFloating(win) then
        hs.alert('[FLOAT] ' .. win:title())
    else
        hs.alert('[TILE] ' .. win:title())
    end
end)

