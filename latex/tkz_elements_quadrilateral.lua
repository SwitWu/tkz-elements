-- File: tkz_elements_quadrilateral.lua
-- Copyright (c) 2026 Alain Matthes
-- SPDX-License-Identifier: LPPL-1.3c
-- Maintainer: Alain Matthes

quadrilateral = {}
quadrilateral.__index = quadrilateral
function quadrilateral:new(pa, pb, pc, pd)
	local type = "quadrilateral"
	local a = point.abs(pb - pa)
	local b = point.abs(pc - pb)
	local c = point.abs(pd - pc)
	local d = point.abs(pa - pd)
	local ab = line:new(pa, pb)
	local bc = line:new(pb, pc)
	local cd = line:new(pc, pd)
	local da = line:new(pd, pa)
	local ac = line:new(pa, pc)
	local bd = line:new(pb, pd)
	local center = intersection_ll_(pa, pc, pb, pd)
	local g = barycenter_({ pa, 1 }, { pb, 1 }, { pc, 1 }, { pd, 1 })
	local o = {
		pa = pa,
		pb = pb,
		pc = pc,
		pd = pd,
		a = a,
		b = b,
		c = c,
		d = d,
		ab = ab,
		bc = bc,
		cd = cd,
		da = da,
		ac = ac,
		bd = bd,
		center = center,
		g = g,
		type = type,
	}
	setmetatable(o, self)
	return o
end

setmetatable(quadrilateral, {
	__call = function(cls, ...)
		return cls:new(...)
	end,
})
-----------------------
function quadrilateral:get()
	return self.pa, self.pb, self.pc, self.pd
end

function quadrilateral:is_cyclic()
	if not self:is_convex() then
		tex.error("Quadrilateral is not convex.")
		return
	end
	local alpha = inner_angle_(self.pa, self.pb, self.pd) -- ∠BAD ou ∠DAB selon ordre, mais interne
	local beta  = inner_angle_(self.pc, self.pb, self.pd) -- angle au sommet C: entre CB et CD
	return math.abs(alpha + beta - math.pi) < tkz.epsilon
end

function quadrilateral:poncelet_point()
	if not self:is_convex() then
		tex.error("Quadrilateral is not convex.")
		return
	end

	local A, B, C, D = self.pa, self.pb, self.pc, self.pd
	local e1 = euler_center_(A, B, C)
	local e2 = euler_center_(A, C, D)
	local m = midpoint_(A, C)
	local x, y = intersection_cc_(e1, m, e2, m)

	if not x or not y then
		tex.error("Poncelet construction failed: no intersection.")
	end

	if point.abs(x - m) < tkz.epsilon then
		return y
	else
		return x
	end
end

function quadrilateral:is_convex(EPS)
	EPS = EPS or tkz.epsilon

	local A, B, C, D = self.pa, self.pb, self.pc, self.pd

	local function cross(u, v)
		return (point.conj(u) * v).im
	end

	local z1 = cross(B - A, C - B)
	local z2 = cross(C - B, D - C)
	local z3 = cross(D - C, A - D)
	local z4 = cross(A - D, B - A)

	-- alignement → dégénéré
	if math.abs(z1) < EPS or math.abs(z2) < EPS
		 or math.abs(z3) < EPS or math.abs(z4) < EPS then
		return false
	end

	local s1 = z1 > 0
	return (z2 > 0) == s1
		 and (z3 > 0) == s1
		 and (z4 > 0) == s1
end

function quadrilateral:area()
	if not self:is_convex() then
		tex.error("Area undefined: quadrilateral is not convex.")
		return
	end

	local A,B,C,D = self.pa, self.pb, self.pc, self.pd

	local function cross(u, v)
		return (point.conj(u) * v).im
	end

	local s =
			cross(A, B)
		+ cross(B, C)
		+ cross(C, D)
		+ cross(D, A)

	return 0.5 * math.abs(s)
end


return quadrilateral
