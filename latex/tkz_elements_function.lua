-- tkz_elements_function.lua
-- Copyright (c) 2026 Alain Matthes
-- SPDX-License-Identifier: LPPL-1.3c
-- Maintainer: Alain Matthes


-- Usage:
--   F.f = fct("sin(x)+x^2", math)
--   y   = F.f:eval(1.2)
--   PA.c = F.f:path(-2, 5, 200)


fct = {}
fct.__index = fct

-- Constructor
function fct:new(expr_or_fn)
  local o = setmetatable({}, self)
  o.expr = nil
  o.fn   = nil
  o.env  = math   -- environnement implicite
  if type(expr_or_fn) == "function" then
    o.fn = expr_or_fn
  else
    o.expr = tostring(expr_or_fn or "0")
  end
  return o
end

setmetatable(fct, { __call = function(_, ...) return fct:new(...) end })

-- Compile expression if needed
function fct:compile()
  if self.fn then return self.fn end

  local chunk = "return function(x) return (" .. self.expr .. ") end"
  local loader, err = load(chunk, "tkz.fct", "t", self.env)
  if not loader then
    if tex and tex.error then
      tex.error("Invalid function expression", { self.expr, err })
    end
    self.fn = function(_) return 0 end
    return self.fn
  end

  local ok, fn_or_err = pcall(loader)
  if not ok or type(fn_or_err) ~= "function" then
    if tex and tex.error then
      tex.error("Invalid function expression", { self.expr, fn_or_err })
    end
    self.fn = function(_) return 0 end
    return self.fn
  end

  self.fn = fn_or_err
  return self.fn
end

-- Evaluate f(x)
function fct:eval(x)
  x = tonumber(x)
  if not x then return 0 end
  local f = self:compile()
  local ok, y = pcall(f, x)
  if not ok then return 0 end
  y = tonumber(y)
  if not y or y ~= y or y == math.huge or y == -math.huge then
    return 0
  end
  return y
end

-- Build a path from f(x)
function fct:path(xmin, xmax, n)
  xmin = tonumber(xmin) or 0
  xmax = tonumber(xmax) or 1
  n    = tonumber(n) or 100
  if n <= 0 then n = 1 end

  local p = path()
  local f = self:compile()
  local step = (xmax - xmin) / n

  for i = 0, n do
    local x = xmin + i * step
    local ok, y = pcall(f, x)
    if ok then
      y = tonumber(y)
      if y and y == y and y ~= math.huge and y ~= -math.huge then
        p:add_point(point(x, y))
      end
    end
  end

  return p
end

-- ------------------------------------------------------------
-- scalar evaluations
-- ------------------------------------------------------------
function fct:point(x)
  return point(x, self:eval(x))
end

return fct

--
-- return fct