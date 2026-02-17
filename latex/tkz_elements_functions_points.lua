-- File: tkz_elements_functions_points.lua
-- Copyright (c) 2026 Alain Matthes
-- SPDX-License-Identifier: LPPL-1.3c
-- Maintainer: Alain Matthes


function polar_(radius, phi)
	return point(radius * math.cos(phi), radius * math.sin(phi))
end

function polar(radius, phi)
	return polar_(radius, phi)
end

function polar_deg(radius, phi)
	return polar_(radius, phi * math.pi / 180)
end

function barycenter_(...)
	local cp = table.pack(...)
	local sum = 0
	local weight = 0
	for i = 1, cp.n do
		sum = sum + cp[i][1] * cp[i][2]
		weight = weight + cp[i][2]
	end
	if weight == 0 then
		tex.error("barycenter_: sum of weights is zero")
	end
	return sum / weight
end

function rotation_(c, a, pt)
	local r = point(math.cos(a), math.sin(a))
	return r * (pt - c) + c
end

-- Define the set_rotation_ function
function set_rotation_(c, angle, ...)
	local tp = table.pack(...)
	local t = {}
	for i = 1, tp.n do
		table.insert(t, rotation_(c, angle, tp[i]))
	end
	return table.unpack(t)
end

function symmetry_(c, pt)
	return 2 * c - pt
end

function set_symmetry_(c, ...)
	local tp = table.pack(...)
	local t = {}
	for i = 1, tp.n do
		table.insert(t, symmetry_(c, tp[i]))
	end
	return table.unpack(t)
end

function homothety_(c, t, p)
	return c + t * (p - c)
end

function set_homothety_(c, coeff, ...)
	local tp = table.pack(...)
	local t = {}
	for i = 1, tp.n do
		table.insert(t, homothety_(c, coeff, tp[i]))
	end
	return table.unpack(t)
end

function translation_(u, p)
	return u + p
end

function set_translation_(u, ...)
	local tp = table.pack(...)
	local t = {}
	for i = 1, tp.n do
		table.insert(t, (u + tp[i]))
	end
	return table.unpack(t)
end

function random_point_(lower, upper)
	if not tkz._seeded then
		math.randomseed(os.time())
		tkz._seeded = true
	end
	local x = math.random(lower, upper)
	local y = math.random(lower, upper)
	return point(x, y)
end

-- midpoints_chain_(...)
-- midpoints_cycle_(...)
function midpoints_(...)
	local arg = table.pack(...)
	local n = arg.n
	local t = {}
	for i = 1, n - 1 do
		table.insert(t, (arg[i] + arg[i + 1]) / 2)
	end
	table.insert(t, (arg[n] + arg[1]) / 2)
	return table.unpack(t)
end

function midpoint_(a, b)
	return (a + b) / 2
end

function midpoints_chain_(...)
	local arg = table.pack(...)
	local n = arg.n
	local t = {}

	if n < 2 then
		return nil
	end

	for i = 1, n - 1 do
		t[#t + 1] = (arg[i] + arg[i + 1]) / 2
	end

	return table.unpack(t)
end

function midpoints_cycle_(...)
	local arg = table.pack(...)
	local n = arg.n
	local t = {}

	if n < 2 then
		return nil
	end

	for i = 1, n - 1 do
		t[#t + 1] = (arg[i] + arg[i + 1]) / 2
	end

	-- fermeture du cycle
	t[#t + 1] = (arg[n] + arg[1]) / 2

	return table.unpack(t)
end


-- Deprecated remove ellipse
function get_points(obj)
	-- Map of object types to their respective point keys
	local point_map = {
		line = { "pa", "pb" }, -- Line has two points
		triangle = { "pa", "pb", "pc" }, -- Triangle has three points
		circle = { "center", "through" }, -- Circle has center and a point through its circumference
		square = { "pa", "pb", "pc", "pd" }, -- Square has four vertices
		rectangle = { "pa", "pb", "pc", "pd" }, -- Rectangle has four vertices
		quadrilateral = { "pa", "pb", "pc", "pd" }, -- Quadrilateral has four vertices
		parallelogram = { "pa", "pb", "pc", "pd" }, -- Parallelogram has four vertices
	}

	-- Check if the object's type is recognized
	if point_map[obj.type] then
		local points = {}
		-- Iterate over the keys for the given type and extract the corresponding values
		for _, key in ipairs(point_map[obj.type]) do
			table.insert(points, obj[key])
		end
		-- Return all points as multiple return values
		return table.unpack(points)
	end
end


