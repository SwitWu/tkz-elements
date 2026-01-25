-- -- File: tkz_elements_utils.lua
-- -- Copyright (c) 2026 Alain Matthes
-- -- SPDX-License-Identifier: LPPL-1.3c
-- -- Maintainer: Alain Matthes
--
-- utils = {}
--
-- -- Parse a string of the form "(x,y)" into two numbers.
-- function utils.parse_point(str)
	-- local x, y = str:match("^%s*%(?%s*([%+%-%.%deE]+)%s*,%s*([%+%-%.%deE]+)%s*%)%s*$")
	-- if not x or not y then
	-- 	tex.error("Invalid point string: " .. tostring(str))
	-- end
	-- return tonumber(x), tonumber(y)
-- end
--
-- -- Format a number with a specified number of decimal places.
-- function utils.format_number(x, decimals)
	-- decimals = decimals or 5
	-- local n = tonumber(x)
	-- if n then
	-- 	return string.format("%." .. decimals .. "f", n)
	-- else
	-- 	tex.error("Invalid input to format_number: " .. tostring(x))
	-- end
-- end
--
-- function utils.format_coord(x, decimals)
	-- decimals = decimals or 5
	-- return string.format("%." .. decimals .. "f", x)
-- end
--
-- function utils.checknumber(x, decimals)
	-- decimals = decimals or 5
	-- local n = tonumber(x)
	-- if n then
	-- 	return string.format("%." .. decimals .. "f", n)
	-- else
	-- 	tex.error("Invalid number: " .. tostring(x))
	-- end
-- end
--
-- -- Format a complex number (table with .re and .im) as a coordinate string.
-- function utils.format_point(z, decimals)
	-- if type(z) ~= "table" or type(z.re) ~= "number" or type(z.im) ~= "number" then
	-- 	tex.error("format_point expects a table with fields 're' and 'im'")
	-- end
	-- decimals = decimals or 5
	-- local x = utils.format_number(z.re, decimals)
	-- local y = utils.format_number(z.im, decimals)
	-- return "(" .. x .. "," .. y .. ")"
-- end
--
-- -- Compare two numbers with tolerance.
-- function utils.almost_equal(a, b)
	-- return math.abs(a - b) < tkz.epsilon
-- end
--
-- -- Print formatted message to terminal and log.
-- function utils.w(...)
	-- texio.write_nl("term and log", "[tkz-elements] " .. string.format(...))
-- end
--
-- -- Print formatted message to log only.
-- function utils.wlog(...)
	-- texio.write_nl("log", "[tkz-elements] " .. string.format(...))
-- end
--
-- -- Optional: Clamp a number between min and max.
-- function utils.clamp(x, min_val, max_val)
	-- return math.max(min_val, math.min(max_val, x))
-- end
--
-- -- Optional: Return the sign of a number.
-- function utils.sign(x)
	-- return (x > 0 and 1) or (x < 0 and -1) or 0
-- end
--
-- -- Optional: Convert a number or string to a fixed-point string.
-- function utils.to_decimal_string(x, decimals)
	-- decimals = decimals or 5
	-- local n = tonumber(x)
	-- if n then
	-- 	return string.format("%." .. decimals .. "f", n)
	-- else
	-- 	tex.error("Invalid input to to_decimal_string: " .. tostring(x))
	-- end
-- end
--
-- function utils.table_getn(t)
	-- if type(t) ~= "table" then
	-- 	tex.error("bad argument #1 to 'getn' (table expected)", 2)
	-- end
	-- local i = 0
	-- while t[i + 1] ~= nil do
	-- 	i = i + 1
	-- end
	-- return i
-- end
--
-- return utils
-- File: tkz_elements_utils.lua
-- Copyright (c) 2026 Alain Matthes
-- SPDX-License-Identifier: LPPL-1.3c
-- Maintainer: Alain Matthes

utils = {}

-- ----------------------------
-- Parsing / formatting helpers
-- ----------------------------

-- Parse a string of the form "(x,y)" into two numbers.
function utils.parse_point(str)
	local x, y = tostring(str):match("^%s*%(?%s*([%+%-%.%deE]+)%s*,%s*([%+%-%.%deE]+)%s*%)%s*$")
	if not x or not y then
		tex.error("Invalid point string: " .. tostring(str))
	end
	return tonumber(x), tonumber(y)
end

-- Internal: format a number to fixed decimals (with checks)
local function _fmt_number(x, decimals, ctx)
	decimals = decimals or 5
	local n = tonumber(x)
	if not n then
		tex.error((ctx or "Invalid number") .. ": " .. tostring(x))
	end
	return string.format("%." .. decimals .. "f", n)
end

-- Public: format a number with a specified number of decimal places.
function utils.format_number(x, decimals)
	return _fmt_number(x, decimals, "Invalid input to format_number")
end

-- Public: alias (kept for backward compatibility)
utils.checknumber       = utils.format_number
utils.to_decimal_string = utils.format_number

-- Coordinates formatting (single component)
function utils.format_coord(x, decimals)
	return _fmt_number(x, decimals, "Invalid coordinate")
end

-- Format a complex number (table with .re and .im) as a coordinate string.
function utils.format_point(z, decimals)
	if type(z) ~= "table" or type(z.re) ~= "number" or type(z.im) ~= "number" then
		tex.error("format_point expects a table with fields 're' and 'im'")
	end
	decimals = decimals or 5
	local x = _fmt_number(z.re, decimals, "Invalid x in format_point")
	local y = _fmt_number(z.im, decimals, "Invalid y in format_point")
	return "(" .. x .. "," .. y .. ")"
end

-- ----------------------------
-- Numeric helpers
-- ----------------------------

-- Compare two numbers with tolerance (robust default).
function utils.almost_equal(a, b, EPS)
	EPS = EPS or (tkz and tkz.epsilon) or 1e-9
	local na, nb = tonumber(a), tonumber(b)
	if not na or not nb then
		tex.error("almost_equal expects numbers: " .. tostring(a) .. ", " .. tostring(b))
	end
	return math.abs(na - nb) <= EPS
end

-- Optional: Clamp a number between min and max.
function utils.clamp(x, min_val, max_val)
	return math.max(min_val, math.min(max_val, x))
end

-- Optional: Return the sign of a number.
function utils.sign(x)
	return (x > 0 and 1) or (x < 0 and -1) or 0
end

-- ----------------------------
-- Logging helpers
-- ----------------------------

-- Print formatted message to terminal and log.
function utils.w(...)
	texio.write_nl("term and log", "[tkz-elements] " .. string.format(...))
end

-- Print formatted message to log only.
function utils.wlog(...)
	texio.write_nl("log", "[tkz-elements] " .. string.format(...))
end

-- ----------------------------
-- Table helpers
-- ----------------------------

-- Length of contiguous array part 1..n (stops at first nil).
-- (Name explicit to avoid confusion with #t on sparse tables.)
function utils.table_len_contiguous(t)
	if type(t) ~= "table" then
		tex.error("bad argument #1 (table expected)", 2)
	end
	local i = 0
	while t[i + 1] ~= nil do
		i = i + 1
	end
	return i
end

-- Backward compatibility
utils.table_getn = utils.table_len_contiguous

return utils
