-- File: tkz_elements_functions_parallelogram.lua
-- Copyright (c) 2026 Alain Matthes
-- SPDX-License-Identifier: LPPL-1.3c
-- Maintainer: Alain Matthes

function parallelogram_fourth_(za, zb, zc)
  local zd = zc + (za - zb)
  return parallelogram:new(za, zb, zc, zd)
end

parallelogram.fourth = parallelogram_fourth_

