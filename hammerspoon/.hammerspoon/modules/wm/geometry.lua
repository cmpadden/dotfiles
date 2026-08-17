--- Predefined unit geometries for the window manager.
--
-- All values are unit rectangles (0.0-1.0) passed to hs.window:moveToUnit().

local padding = 0.02 -- outer margin used by padded layouts
local split_padding = 0.08 -- outer margin used by the padded split layout
local half_gap = 0.005 -- half of the gutter between split windows
local centered_width = 0.65
local skinny_width = 0.35
local pip_height = 0.35
local pip_width = 0.142

local M = {}

M.builtins = {
    full = hs.geometry({ h = 1, w = 1, x = 0, y = 0 }),

    padded_center = hs.geometry({
        h = 1 - (2 * padding),
        w = centered_width,
        x = (1 - centered_width) / 2,
        y = padding,
    }),

    padded_left = hs.geometry({
        h = 1 - (2 * padding),
        w = 0.5 - split_padding - half_gap,
        x = split_padding,
        y = padding,
    }),

    padded_right = hs.geometry({
        h = 1 - (2 * padding),
        w = 0.5 - split_padding - half_gap,
        x = 0.5 + half_gap,
        y = padding,
    }),

    full_left = hs.geometry({ h = 1, w = 0.5, x = 0, y = 0 }),

    full_right = hs.geometry({ h = 1, w = 0.5, x = 0.5, y = 0 }),

    skinny = hs.geometry({
        h = 1 - (2 * padding),
        w = skinny_width,
        x = (1 - skinny_width) / 2,
        y = padding,
    }),

    pip_bottom_right = hs.geometry({
        h = pip_height,
        w = pip_width,
        x = 1 - pip_width - padding,
        y = 1 - pip_height - padding,
    }),

    pip_top_right = hs.geometry({
        h = pip_height,
        w = pip_width,
        x = 1 - pip_width - padding,
        y = padding,
    }),
}

return M
