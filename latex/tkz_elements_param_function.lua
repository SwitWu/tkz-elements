-- tkz_elements_param_function.lua
-- Copyright (c) 2026 Alain Matthes
-- SPDX-License-Identifier: LPPL-1.3c
-- Maintainer: Alain Matthes


-- Define a GLOBAL class: pfct
-- Parametric function: (x(t), y(t)) -> path() or file
-- Requires tkz-elements objects: path(), point(x,y)

pfct = pfct or {}
pfct.__index = pfct

-- ------------------------------------------------------------
-- helpers
-- ------------------------------------------------------------
local function is_finite_(v)
  return (v == v) and v ~= math.huge and v ~= -math.huge
end

local function compile_1var_(expr, env, varname)
  env = env or math
  varname = varname or "t"
  expr = tostring(expr or "0")

  local chunk, err = load(
    "return function(" .. varname .. ") return " .. expr .. " end",
    nil, "t", env
  )
  if not chunk then
    if tex and tex.error then
      tex.error("tkz-elements: invalid parametric expression", { err or "compile error", expr })
    end
    return function(_) return 0/0 end
  end
  return chunk()
end

-- ------------------------------------------------------------
-- constructor
-- ------------------------------------------------------------
function pfct:new(exprx, expry, env)
  local o = setmetatable({}, self)
  o.exprx = exprx
  o.expry = expry
  o.env   = env or math
  o.fx, o.fy = nil, nil
  return o
end

setmetatable(pfct, {
  __call = function(_, exprx, expry, env)
    return pfct:new(exprx, expry, env)
  end
})
-- ------------------------------------------------------------
-- compile (lazy)
-- ------------------------------------------------------------
function pfct:compile()
  if not self.fx then
    if type(self.exprx) == "function" then
      self.fx = self.exprx
    else
      self.fx = compile_1var_(self.exprx, self.env, "t")
    end
  end
  if not self.fy then
    if type(self.expry) == "function" then
      self.fy = self.expry
    else
      self.fy = compile_1var_(self.expry, self.env, "t")
    end
  end
  return self
end

-- ------------------------------------------------------------
-- evaluation
-- ------------------------------------------------------------
function pfct:eval(t)
  self:compile()
  local okx, x = pcall(self.fx, t)
  local oky, y = pcall(self.fy, t)
  if not okx then x = 0/0 end
  if not oky then y = 0/0 end
  return x, y
end

-- ------------------------------------------------------------
-- path
-- ------------------------------------------------------------
function pfct:path(tmin, tmax, n)
  tmin = tonumber(tmin)
  tmax = tonumber(tmax)
  n    = tonumber(n) or 200

  local p = path()
  local step = (tmax - tmin) / n

  for i = 0, n do
    local t = tmin + i * step
    local x, y = self:eval(t)
    if is_finite_(x) and is_finite_(y) then
      p:add_point(point(x, y))
    end
  end

  return p
end

-- ------------------------------------------------------------
-- file (TikZ plot file)
-- ------------------------------------------------------------
function pfct:file(tmin, tmax, n, filename)
  tmin = tonumber(tmin)
  tmax = tonumber(tmax)
  n    = tonumber(n) or 200

  local out = assert(io.open(filename, "w"))
  local step = (tmax - tmin) / n

  for i = 0, n do
    local t = tmin + i * step
    local x, y = self:eval(t)
    if x == x and y == y then
      out:write(x, " ", y, "\n")
    end
  end

  out:close()
  return filename
end

-- convenience: jobname-suffix.table
function pfct:jobfile(tmin, tmax, n, suffix)
  local job = (tex and tex.jobname) or "job"
  local fname = job .. "-" .. tostring(suffix or "param") .. ".table"
  return self:file(tmin, tmax, n, fname)
end

-- ------------------------------------------------------------
-- scalar evaluations
-- ------------------------------------------------------------
function pfct:x(t)
  self:compile()
  local ok, x = pcall(self.fx, t)
  if not ok then return 0/0 end
  return x
end

function pfct:y(t)
  self:compile()
  local ok, y = pcall(self.fy, t)
  if not ok then return 0/0 end
  return y
end

-- ------------------------------------------------------------
-- point on parametric curve
-- ------------------------------------------------------------
function pfct:point(t)
  return point(self:x(t), self:y(t))
end

-- alias naturel
pfct.at = pfct.point
return pfct