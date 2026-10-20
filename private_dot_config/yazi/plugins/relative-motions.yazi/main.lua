-- Locally maintained for Yazi 26.9.1; upstream still uses removed APIs.
--- @since 25.5.28
-- stylua: ignore
local MOTIONS_AND_OP_KEYS = {
	{ on = "0" }, { on = "1" }, { on = "2" }, { on = "3" }, { on = "4" },
	{ on = "5" }, { on = "6" }, { on = "7" }, { on = "8" }, { on = "9" },
	-- commands
	{ on = "d" }, { on = "v" }, { on = "y" }, { on = "x" },
	-- tab commands
	{ on = "t" }, { on = "L" }, { on = "H" }, { on = "w" },
	{ on = "W" }, { on = "<" }, { on = ">" }, { on = "~" },
	-- movement
	{ on = "g" }, { on = "j" }, { on = "k" }, { on = "h" }, { on = "l" }, { on = "<Down>" }, { on = "<Up>" }, { on = "<Left>" }, { on = "<Right>" }
}

-- stylua: ignore
local MOTION_KEYS = {
	{ on = "0" }, { on = "1" }, { on = "2" }, { on = "3" }, { on = "4" },
	{ on = "5" }, { on = "6" }, { on = "7" }, { on = "8" }, { on = "9" },
	-- movement
	{ on = "g" }, { on = "j" }, { on = "k" }, { on = "h" }, { on = "l" }, { on = "<Down>" }, { on = "<Up>" }, { on = "<Left>" }, { on = "<Right>" }
}

-- stylua: ignore
local DIRECTION_KEYS = {
	{ on = "j" }, { on = "k" }, { on = "<Down>" }, { on = "<Up>" },
	-- tab movement
	{ on = "t" }
}

local SHOW_NUMBERS_ABSOLUTE = 0
local SHOW_NUMBERS_RELATIVE = 1
local SHOW_NUMBERS_RELATIVE_ABSOLUTE = 2

local ENTER_MODE_FIRST = 0
local ENTER_MODE_CACHE = 1
local ENTER_MODE_CACHE_OR_FIRST = 2

-----------------------------------------------
----------------- R E N D E R -----------------
-----------------------------------------------

local render_motion_setup = ya.sync(function(_)
	Status.motion = function() return ui.Span("") end
	Status:children_add(function(self) return self:motion() end, 500, Status.RIGHT)
	ui.render()
end)

local render_motion = ya.sync(function(_, motion_num, motion_cmd)
	ui.render()

	Status.motion = function(self)
		if not motion_num then
			return ui.Span("")
		end

		local style = self:style()

		local motion_span
		if not motion_cmd then
			motion_span = ui.Span(string.format("  %3d ", motion_num))
		else
			motion_span = ui.Span(string.format(" %3d%s ", motion_num, motion_cmd))
		end

		local status_config = th.status
		local separator_open = status_config.sep_right.open
		local separator_close = status_config.sep_right.close

		local bg_style = style.main:bg()

		return ui.Line {
			ui.Span(separator_open):fg(bg_style),
			motion_span:style(style.main),
			ui.Span(separator_close):fg(bg_style),
			ui.Span(" "),
		}
	end
end)

local render_numbers = ya.sync(function(_, mode)
	-- Add a number column without replacing Yazi's rendering or drag/drop support.
	Entity:children_add(function(self)
		local file = self._file
		if not file.in_current then
			return ""
		end

		local current = cx.active.current
		local idx = file.idx
		if mode == SHOW_NUMBERS_RELATIVE or (mode == SHOW_NUMBERS_RELATIVE_ABSOLUTE and not file.is_hovered) then
			idx = math.abs(current.cursor + 1 - idx)
		end

		local width = #tostring(#current.files)
		return ui.Span(string.format("%" .. width .. "d ", idx))
	end, 500)
	ui.render()
end)

local function render_clear() render_motion() end

-----------------------------------------------
--------- C O M M A N D   P A R S E R ---------
-----------------------------------------------

local get_keys = ya.sync(function(state) return state._only_motions and MOTION_KEYS or MOTIONS_AND_OP_KEYS end)

local function normal_direction(dir)
	if dir == "<Down>" then
		return "j"
	elseif dir == "<Up>" then
		return "k"
	elseif dir == "<Left>" then
		return "h"
	elseif dir == "<Right>" then
		return "l"
	end
	return dir
end

local function get_cmd(first_char, keys)
	local last_key
	local lines = first_char or ""

	while true do
		render_motion(tonumber(lines))
		local key = ya.which { cands = keys, silent = true }
		if not key then
			return nil, nil, nil
		end

		last_key = keys[key].on
		if not tonumber(last_key) then
			last_key = normal_direction(last_key)
			break
		end

		lines = lines .. last_key
	end

	render_motion(tonumber(lines), last_key)

	-- command direction
	local direction
	if last_key == "g" or last_key == "v" or last_key == "d" or last_key == "y" or last_key == "x" then
		DIRECTION_KEYS[#DIRECTION_KEYS + 1] = {
			on = last_key,
		}
		local direction_key = ya.which { cands = DIRECTION_KEYS, silent = true }
		if not direction_key then
			return nil, nil, nil
		end

		direction = DIRECTION_KEYS[direction_key].on
		direction = normal_direction(direction)
	end

	return tonumber(lines), last_key, direction
end

local function is_tab_command(command)
	local tab_commands = { "t", "L", "H", "w", "W", "<", ">", "~" }
	for _, cmd in ipairs(tab_commands) do
		if command == cmd then
			return true
		end
	end
	return false
end

local get_active_tab = ya.sync(function(_) return cx.tabs.idx end)

local get_cache_or_first_dir = ya.sync(function(state)
	if state._enter_mode == ENTER_MODE_CACHE then
		return nil
	elseif state._enter_mode == ENTER_MODE_CACHE_OR_FIRST then
		local hovered_file = cx.active.current.hovered

		if hovered_file ~= nil and hovered_file.cha.is_dir then
			return cx.active.current.cursor
		end
	end

	local files = cx.active.current.files
	local index = 1

	for i = 1, #files do
		if files[i].cha.is_dir then
			index = i
			break
		end
	end

	return index - 1
end)
-----------------------------------------------
---------- E N T R Y   /   S E T U P ----------
-----------------------------------------------

return {
	entry = function(_, job)
		local initial_value

		local args = job.args
		-- this is checking if the argument is a valid number
		if #args > 0 then
			initial_value = tostring(tonumber(args[1]))
			if initial_value == "nil" then
				return
			end
		end

		local lines, cmd, direction = get_cmd(initial_value, get_keys())
		if not lines or not cmd then
			-- command was cancelled
			render_clear()
			return
		end

		if cmd == "g" then
			if direction == "g" then
				ya.emit("arrow", { "top" })
				ya.emit("arrow", { lines - 1 })
				render_clear()
				return
			elseif direction == "j" then
				cmd = "j"
			elseif direction == "k" then
				cmd = "k"
			elseif direction == "t" then
				ya.emit("tab_switch", { lines - 1 })
				render_clear()
				return
			else
				-- no valid direction
				render_clear()
				return
			end
		end

		if cmd == "j" then
			ya.emit("arrow", { lines })
		elseif cmd == "k" then
			ya.emit("arrow", { -lines })
		elseif cmd == "h" then
			for _ = 1, lines do
				ya.emit("leave", {})
			end
		elseif cmd == "l" then
			for _ = 1, lines do
				ya.emit("enter", {})
				local file_idx = get_cache_or_first_dir()
				if file_idx then
					ya.emit("arrow", { "top" })
					ya.emit("arrow", { file_idx })
				end
			end
		elseif is_tab_command(cmd) then
			if cmd == "t" then
				for _ = 1, lines do
					ya.emit("tab_create", {})
				end
			elseif cmd == "H" then
				ya.emit("tab_switch", { -lines, relative = true })
			elseif cmd == "L" then
				ya.emit("tab_switch", { lines, relative = true })
			elseif cmd == "w" then
				ya.emit("tab_close", { lines - 1 })
			elseif cmd == "W" then
				local curr_tab = get_active_tab()
				local del_tab = curr_tab + lines - 1
				for _ = curr_tab, del_tab do
					ya.emit("tab_close", { curr_tab - 1 })
				end
				ya.emit("tab_switch", { curr_tab - 1 })
			elseif cmd == "<" then
				ya.emit("tab_swap", { -lines })
			elseif cmd == ">" then
				ya.emit("tab_swap", { lines })
			elseif cmd == "~" then
				local jump = lines - get_active_tab()
				ya.emit("tab_swap", { jump })
			end
		else
			ya.emit("visual_mode", {})
			-- invert direction when user specifies it
			if direction == "k" then
				ya.emit("arrow", { -lines })
			elseif direction == "j" then
				ya.emit("arrow", { lines })
			else
				ya.emit("arrow", { lines - 1 })
			end
			ya.emit("escape", {})

			if cmd == "d" then
				ya.emit("remove", {})
			elseif cmd == "y" then
				ya.emit("yank", {})
			elseif cmd == "x" then
				ya.emit("yank", { cut = true })
			end
		end

		render_clear()
	end,
	setup = function(state, args)
		if not args then
			return
		end

		-- initialize state variables
		state._only_motions = args["only_motions"] or false

		if args["show_motion"] then
			render_motion_setup()
		end

		if args["enter_mode"] == "cache" then
			state._enter_mode = ENTER_MODE_CACHE
		elseif args["enter_mode"] == "first" then
			state._enter_mode = ENTER_MODE_FIRST
		elseif args["enter_mode"] == "cache_or_first" then
			state._enter_mode = ENTER_MODE_CACHE_OR_FIRST
		else
			state._enter_mode = ENTER_MODE_CACHE_OR_FIRST
		end

		if args["show_numbers"] == "absolute" then
			render_numbers(SHOW_NUMBERS_ABSOLUTE)
		elseif args["show_numbers"] == "relative" then
			render_numbers(SHOW_NUMBERS_RELATIVE)
		elseif args["show_numbers"] == "relative_absolute" then
			render_numbers(SHOW_NUMBERS_RELATIVE_ABSOLUTE)
		end
	end,
}
