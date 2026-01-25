-- File: tkz_elements_functions_square.lua
-- Copyright (c) 2026 Alain Matthes
-- SPDX-License-Identifier: LPPL-1.3c
-- Maintainer: Alain Matthes

function square_by_rotation_(zi, za)
  local zb = rotation_(zi, math.pi / 2, za)
  local zc = rotation_(zi, math.pi / 2, zb)
  local zd = rotation_(zi, math.pi / 2, zc)
  return square:new(za, zb, zc, zd)
end

function square_from_side_(pa, pb, swap)
  swap = (swap == "swap") or (swap == true)
  local pc, pd
  if swap then
    pc = rotation_(pb,  math.pi/2, pa)
    pd = rotation_(pa, -math.pi/2, pb)
  else
    pc = rotation_(pb, -math.pi/2, pa)
    pd = rotation_(pa,  math.pi/2, pb)
  end
  return square:new(pa, pb, pc, pd)
end

square.by_rotation = square_by_rotation_
square.from_side   = square_from_side_
