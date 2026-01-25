-- File: tkz_elements_list_point.lua
-- Copyright (c) 2026 Alain Matthes
-- SPDX-License-Identifier: LPPL-1.3c
-- Maintainer: Alain Matthes
-- -------------------------------------------------------------------------
--                           List of points
-- ------------------------------------------------------------------------

list_point = {}
list_point.__index = list_point

-- -------------------------------------------------------------------------
-- Constructor
-- -------------------------------------------------------------------------
function list_point:new(...)
  return setmetatable({ ... }, self)
end

setmetatable(list_point, {
  __call = function(cls, ...)
    return cls:new(...)
  end,
})

-- -------------------------------------------------------------------------
-- Basic accessors
-- -------------------------------------------------------------------------

-- number of stored points
function list_point:len()
  return #self
end

-- get i-th point
function list_point:get(i)
  return self[i]
end

-- unpack points (useful for Lua / TikZ bridges)
function list_point:unpack()
  return table.unpack(self)
end

-- -------------------------------------------------------------------------
-- Mutators
-- -------------------------------------------------------------------------

-- add one point
function list_point:add(p)
  self[#self + 1] = p
  return self
end

-- append another points list
function list_point:extend(pl)
  for _, p in ipairs(pl) do
    self[#self + 1] = p
  end
  return self
end

-- remove all points
function list_point:clear()
  for i = #self, 1, -1 do
    self[i] = nil
  end
  return self
end

-- -------------------------------------------------------------------------
-- Iteration helpers
-- -------------------------------------------------------------------------

-- apply a function to each point
function list_point:foreach(f)
  for i, p in ipairs(self) do
    f(p, i)
  end
  return self
end

-- map → returns a new points object
function list_point:map(f)
  local res = list_point()
  for i, p in ipairs(self) do
    res:add(f(p, i))
  end
  return res
end

-- -------------------------------------------------------------------------
-- Geometric helpers (lightweight)
-- -------------------------------------------------------------------------

-- barycenter of the list
function list_point:barycenter()
  local n = #self
  if n == 0 then return nil end
  local z = self[1]
  for i = 2, n do
    z = z + self[i]
  end
  return z / n
end

-- bounding box (min/max)
function list_point:bbox()
  local n = #self
  if n == 0 then return nil end
  local xmin, xmax = self[1].re, self[1].re
  local ymin, ymax = self[1].im, self[1].im
  for i = 2, n do
    local p = self[i]
    xmin = math.min(xmin, p.re)
    xmax = math.max(xmax, p.re)
    ymin = math.min(ymin, p.im)
    ymax = math.max(ymax, p.im)
  end
  return xmin, ymin, xmax, ymax
end

-- -------------------------------------------------------------------------
-- Output helpers (for tkz / TikZ)
-- -------------------------------------------------------------------------

-- export as path (x1,y1) -- (x2,y2) ...
function list_point:to_path()
  local t = {}
  for _, p in ipairs(self) do
    t[#t + 1] = p:to_tikz()
  end
  return table.concat(t, " -- ")
end

return list_point
