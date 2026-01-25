-- File: tkz_elements_occs.lua
-- Copyright (c) 2026 Alain Matthes
-- SPDX-License-Identifier: LPPL-1.3c
-- Maintainer: Alain Matthes

occs = {}
occs.__index = occs
function occs:new(L, zO)
	local type = "occs"
	local origin = zO
	local y = report_(L.pa, L.pb, 1, zO)
	local x = rotation_(zO, -math.pi / 2, y)
	local abscissa = line:new(zO, x)
	local ordinate = line:new(zO, y)
	local o = { origin = origin, x = x, y = y, abscissa = abscissa, ordinate = ordinate, type = type }
	setmetatable(o, self)
	return o
end

setmetatable(occs, {
	__call = function(cls, ...)
		return cls:new(...)
	end,
})
-----------------------
function occs:coordinates(pt)
	local O = self.origin

	local dx = pt.re - O.re
	local dy = pt.im - O.im

	-- axes directeurs
	local ux = self.x - O
	local vx = self.y - O

	-- normes (évite division par 0)
	local nu = point.abs(ux)
	local nv = point.abs(vx)
	local eps = tkz.epsilon or 1e-9

	if nu <= eps or nv <= eps then
		tex.error("Degenerate occs: axis length too small.")
		return
	end

	-- coordonnées projetées, corrigées par l'échelle des axes
	local u = (ux.re * dx + ux.im * dy) / nu
	local v = (vx.re * dx + vx.im * dy) / nv

	return u, v
end


return occs
