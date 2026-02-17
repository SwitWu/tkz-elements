-- File: tkz_elements_angle.lua
-- Copyright (c) 2026 Alain Matthes
-- SPDX-License-Identifier: LPPL-1.3c
-- Maintainer: Alain Matthes

angle = {}
angle.__index = angle

function angle:new(ps, pa, pb)
  local raw  = get_angle_(ps, pa, pb)       -- angle orienté, peut être négatif
  local norm = angle_normalize_(raw)        -- angle orienté normalisé [0, 2π)
  local value = math.abs(raw)
  local deg = math.deg(value)

  local obj = {
    ps   = ps,      -- sommet
    pa   = pa,      -- premier point
    pb   = pb,      -- second point
    raw  = raw,     -- angle orienté brut
    norm = norm,    -- angle normalisé
    value = value,
    deg = deg
  }
  return setmetatable(obj, self)
end

setmetatable(angle, {
  __call = function(cls, ...)
    return cls:new(...)
  end
})

-- Récupérer les points de définition
function angle:get()
  return self.ps, self.pa, self.pb
end

-- L’angle est direct si raw > 0
function angle:is_direct()
  return self.raw > 0
end




return angle
