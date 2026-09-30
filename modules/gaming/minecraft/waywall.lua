local waywall = require("waywall")
local helpers = require("waywall.helpers")

local Scene = require("waywork.scene")
local Modes = require("waywork.modes")
local Keys = require("waywork.keys")
local Processes = require("waywork.processes")

local thin_res = { w = math.max(340, math.floor(resolution.h * 0.28)), h = resolution.h }

local wide_res = { w = resolution.w, h = math.floor(resolution.h / 3.6) }
local tall_res = { w = 384, h = 16384 }

local ModeManager = Modes.ModeManager.new(waywall)
local scene = Scene.SceneManager.new(waywall)

local pie_colors = {
	{ input = "#e145c2", output = "#a000a0" },
	{ input = "#e96d4d", output = "#aa3310" },
	{ input = "#45cb65", output = "#00a000" },
	{ input = "#4de1ca", output = "#1a7286" },
	{ input = "#c46de1", output = "#ff55ff" },
}

-- https://arjuncgore.github.io/waywall-boat-eye-calc/
-- https://github.com/Esensats/mcsr-calcsens
local normal_sens = 13.117018998967824
local tall_sens = 0.88486625532087

-- utils {{{
function smart_enable_group(mode, status)
	scene:enable_group(mode, status)
	scene:enable_group("normal", not status)
end

function mode_guard()
	return waywall.state().screen == "inworld" and waywall.state().inworld == "unpaused"
end

function piechart_src(res)
	return { x = res.w - 93, y = res.h - 221, w = 33, h = 42 }
end

local left_middle = (resolution.w - thin_res.w) / 4
local pie_scale = math.max(1, math.floor(15 * resolution.h / 1920))

function piechart_dst(res)
	if res.w == resolution.w and res.h == resolution.h then
		return { x = res.w - 270, y = res.h - 390, w = 33 * 6, h = 42 * 6 }
	else
		-- Place the enlarged readout 20 pixels to the right of the thin view.
		-- return { x = (resolution.w + res.w) / 2 + 20, y = (resolution.h + res.h) / 2 - 390, w = 33 * 8, h = 42 * 8 }
		 return { x = left_middle - (49 * pie_scale / 2), y = resolution.h / 4, w = 33 * pie_scale, h = 42 * pie_scale }
	end
end

local ensure_ninjabrain = Processes.ensure_application(waywall, programs.ninjabrain_bot)("ninjabrain.*\\.jar")
-- }}}

-- thin {{{
local e_scale = resolution.w > 2560 and 20 or 10
-- Full pie image, centered below the E-counter and percentage readout.
local full_pie_width = 49 * e_scale
local full_pie_height = full_pie_width * 221 / 340
local thin_percent_dst = piechart_dst(thin_res)

scene:register("full_pie", {
	kind = "mirror",
	options = {
		src = { x = thin_res.w - 340, y = thin_res.h - 406, w = 340, h = 221 },
		dst = {
			x = left_middle - full_pie_width / 2,
			y = math.max(resolution.h / 10.8 + 9 * e_scale, thin_percent_dst.y + thin_percent_dst.h) + 20,
			w = full_pie_width,
			h = full_pie_height,
		},
		depth = 2,
	},
	groups = { "thin" },
})

scene:register("e_counter", {
	kind = "mirror",
	options = {
		src = { x = 1, y = 37, w = 49, h = 9 },
		dst = { x = left_middle - (49 * e_scale / 2), y = resolution.h / 10.8, w = 49 * e_scale, h = 9 * e_scale },
		depth = 0,
	},
	groups = { "thin" },
})

for _, ck in ipairs(pie_colors) do
	scene:register("prct_mirror_" .. ck.input, {
		kind = "mirror",
		options = {
			src = piechart_src(thin_res),
			dst = piechart_dst(thin_res),
			depth = 1,
			color_key = ck,
		},
		groups = { "thin" },
	})
end

ModeManager:define("thin", {
	width = thin_res.w,
	height = thin_res.h,
	on_enter = function()
		smart_enable_group("thin", true)
	end,
	on_exit = function()
		smart_enable_group("thin", false)
	end,
	toggle_guard = mode_guard,
})
-- }}}

-- wide {{{
ModeManager:define("wide", {
	width = wide_res.w,
	height = wide_res.h,
	on_enter = function()
		smart_enable_group("wide", true)
	end,
	on_exit = function()
		smart_enable_group("wide", false)
	end,
	toggle_guard = mode_guard,
})
-- }}}

-- tall {{{
local measure_w = (resolution.w - tall_res.w) / 2
local measure_h = (resolution.h * measure_w) / resolution.w
local measure_dst = { x = 0, y = (resolution.h - measure_h) / 2, w = measure_w, h = measure_h }

scene:register("eye_measure", {
	kind = "mirror",
	options = {
		src = { x = (tall_res.w - 60) / 2, y = (tall_res.h - 580) / 2, w = 60, h = 580 },
		dst = measure_dst,
		depth = 0,
	},
	groups = { "tall" },
})

scene:register("eye_overlay", {
	kind = "image",
	path = files.eye_overlay,
	options = { dst = measure_dst, depth = 1 },
	groups = { "tall" },
})

ModeManager:define("tall", {
	width = tall_res.w,
	height = tall_res.h,
	on_enter = function()
		smart_enable_group("tall", true)
		waywall.set_sensitivity(tall_sens)
	end,
	on_exit = function()
		smart_enable_group("tall", false)
		waywall.set_sensitivity(0)
	end,
	toggle_guard = mode_guard,
})
-- }}}

-- normal res mirrors {{{
for _, ck in ipairs(pie_colors) do
	scene:register("prct_mirror_normal_" .. ck.input, {
		kind = "mirror",
		options = {
			src = piechart_src(resolution),
			dst = piechart_dst(resolution),
			depth = 1,
			color_key = ck,
		},
		groups = { "normal" },
	})
end
-- }}}

-- startup actions
waywall.listen("load", function()
	-- wait for title screen
	repeat
		local error, state = pcall(waywall.state)
		waywall.sleep(1000)
	until error == true and state.screen == "title"

	-- actual actions
	ensure_ninjabrain()
	scene:enable_group("normal", true)
end)

-- go back to normal if we switch to the wall
waywall.listen("state", function()
    local state = waywall.state()
    if state.screen == "wall" then
        ModeManager:_transition_to(nil)
    end
end)

-- CONFIG

local config = {
	input = {
		repeat_rate = 40,
		repeat_delay = 300,

		sensitivity = normal_sens,
		confine_pointer = false,

		remaps = remaps,
	},

	theme = {
		background = "#303030ff",
		-- https://github.com/Smithay/smithay/issues/1894
		ninb_anchor = "right",
	},
	window = {
		fullscreen_width = resolution.w,
		fullscreen_height = resolution.h,
	},
	actions = Keys.actions({
		["*-" .. thin_key] = function()
			return ModeManager:toggle("thin")
		end,
		["*-" .. tall_key] = function()
			return ModeManager:toggle("tall")
		end,
		["*-" .. wide_key] = function()
			return ModeManager:toggle("wide")
		end,
		[fs_key] = waywall.toggle_fullscreen,
		[nb_key] = function()
			ensure_ninjabrain()
			helpers.toggle_floating()
		end,
	}),
}

return config
