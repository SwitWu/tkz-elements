-- File: tkz_elements_matrix.lua
-- Copyright (c) 2026 Alain Matthes
-- SPDX-License-Identifier: LPPL-1.3c
-- Maintainer: Alain Matthes

------------------------------------------------------------------------------
matrix = {}
matrix.__index = matrix
function matrix:new(value)
	local type = "matrix"
	local rows = #value
	local cols = #value[1]
	local set = value
	local det = determinant(value)
	local o = { set = set, rows = rows, cols = cols, det = det, type = type }
	setmetatable(o, self)
	return o
end

setmetatable(matrix, {
	__call = function(cls, ...)
		return cls:new(...)
	end,
})

function matrix.__mul(m1, m2)
	if getmetatable(m1) ~= matrix then
		return k_mul_matrix(m1, m2)
	end
	if getmetatable(m2) ~= matrix then
		return k_mul_matrix(m2, m1)
	end
	return mul_matrix(m1, m2)
end

function matrix.__add(m1, m2)
	return add_matrix(m1, m2)
end

function matrix.__sub(m1, m2)
	return add_matrix(m1, k_mul_matrix(-1, m2))
end


function matrix.__pow(m, exp)
	-- --- Transpose shortcut (A^"T")
	if exp == "T" then
		return transposeMatrix(m)
	end

	-- --- Only integer powers are supported
	if type(exp) ~= "number" or exp ~= math.floor(exp) then
		return nil, "matrix.__pow: exponent must be an integer (or 'T' for transpose)"
	end

	-- --- Power defined only for square matrices
	if getmetatable(m) ~= matrix then
		return nil, "matrix.__pow: left operand must be a matrix"
	end
	if not m:is_square() then
		return nil, "matrix.__pow: power is defined only for square matrices"
	end

	local n = m.rows

	-- --- A^0 = I
	if exp == 0 then
		return id_matrix(n)
	end

	-- --- If exp < 0, use inverse
	local base = m
	if exp < 0 then
		local inv, err = inv_matrix(m)  -- IMPORTANT: do not shadow the function name
		if not inv then
			return nil, err or "matrix.__pow: matrix is not invertible"
		end
		base = inv
		exp = -exp
	end

	-- --- Fast exponentiation (binary exponentiation)
	local result = id_matrix(n)
	local p = exp
	local b = base

	while p > 0 do
		if (p % 2) == 1 then
			result = mul_matrix(result, b)
		end
		p = math.floor(p / 2)
		if p > 0 then
			b = mul_matrix(b, b)
		end
	end

	return result
end


function matrix.__tostring(A)
	local mt = (A.type == "matrix" and A.set or A)
	local k = {}
	for i = 1, #mt do
		local n = {}
		for j = 1, #mt[1] do
			n[j] = tkz_display_(mt[i][j])
		end
		k[i] = table.concat(n, " ")
	end
	-- à la toute fin
	return table.concat(k, " ; ")
end

function matrix.__eq(A, B)
	local mt1 = (A.type == "matrix" and A.set or A)
	local mt2 = (B.type == "matrix" and B.set or B)
  if getmetatable(A) ~= matrix or getmetatable(B) ~= matrix then
		return false
	end


	if #mt1 ~= #mt2 or #mt1[1] ~= #mt2[1] then
		return false
	end

	for i = 1, #mt1 do
		for j = 1, #mt1[1] do
			if mt1[i][j] ~= mt2[i][j] then
				return false
			end
		end
	end
	return true
end

function matrix.square(n, ...)
	local m = {}
	local t = table.pack(...)
	if n * n == #t then
		for i = 1, n do
			m[i] = {}
			for j = 1, n do
				m[i][j] = t[n * (i - 1) + j]
			end
		end
		return matrix:new(m)
	else
		return nil
	end
end

function matrix.vector(...)
	local m = {}
	local t = table.pack(...)
	for i = 1, #t do
		m[i] = {}
		m[i][1] = t[i]
	end
	return matrix:new(m)
end

matrix.column = matrix.vector

function matrix.row_vector(...)
	local m = {}
	local t = table.pack(...)
	m[1] = {}
	for j = 1, #t do
		m[1][j] = t[j]
	end
	return matrix:new(m)
end

function matrix.create(rows, cols)
	local mat = {}
	for i = 1, rows do
		mat[i] = {}
		for j = 1, cols do
			mat[i][j] = 0
		end
	end
	return matrix:new(mat)
end

function matrix:homogenization()
	return homogenization_(self)
end

function matrix:htm_apply(...)
	local obj, nb, t
	local tp = table.pack(...)
	obj = tp[1]
	nb = tp.n
	if nb == 1 then
		if obj.type == "point" then
			return htm_apply_(self, obj)
		elseif obj.type == "line" then
			return htm_apply_L_(self, obj)
		elseif obj.type == "triangle" then
			return htm_apply_T_(self, obj)
		elseif obj.type == "circle" then
			return htm_apply_C(self, obj)
		elseif
			obj.type == "square"
			or obj.type == "rectangle"
			or obj.type == "quadrilateral"
			or obj.type == "parallelogram"
		then
			return htm_apply_Q(self, obj)
		end
	else
		t = {}
		for i = 1, tp.n do
			table.insert(t, htm_apply_(self, tp[i]))
		end
		return table.unpack(t)
	end
end

function matrix:k_mul(n)
	return k_mul_matrix(n, self)
end

function matrix:get(i, j)
	if i == nil and j == nil then
		return self.set -- retourne toute la matrice
	else
		return get_element_(self, i, j)
	end
end

function matrix:inverse()
	return inv_matrix(self)
end

function matrix:adjugate()
	return adjugate_(self)
end

function matrix:transpose()
	return transposeMatrix(self)
end

function matrix:is_square()
	return self.rows == self.cols
end

function matrix:is_diagonal()
	return isDiagonal_(self)
end

function matrix:is_orthogonal()
	return isOrthogonal_(self)
end

function matrix:diagonalize() -- return two matrices D and P
	return diagonalize_(self)
end

function matrix:print(style, fmt)
	style = style or "bmatrix"
	fmt   = fmt   or 0
	return print_matrix(self, style, fmt)
end



-------------------------
-- homogeneous transformation matrix
function matrix.htm(phi, a, b, c, d)
	local tx = (a or 0)
	local ty = (b or 0)
	local sx = (c or 1)
	local sy = (d or 1)
	local phi = (phi or 0)
	return matrix.square(3, sx * math.cos(phi), -math.sin(phi), tx, math.sin(phi), sy * math.cos(phi), ty, 0, 0, 1)
end
-------------------------


function matrix:swap_rows(i, j)
	local A = {}
	for r = 1, self.rows do
		A[r] = {}
		for c = 1, self.cols do
			A[r][c] = self.set[r][c]
		end
	end
	A[i], A[j] = A[j], A[i]
	return matrix:new(A)
end

function matrix:swap_rows_inplace(i, j)
	self.set[i], self.set[j] = self.set[j], self.set[i]
	self.det = nil
	return self
end


function matrix:k_mul_row(row, k)
	local A = {}
	for i = 1, self.rows do
		A[i] = {}
		for j = 1, self.cols do
			A[i][j] = self.set[i][j]
		end
	end

	for j = 1, self.cols do
		A[row][j] = A[row][j] * k
	end

	return matrix:new(A)
end


-- Ajoute à la ligne target_row la ligne source_row multipliée par k
function matrix:add_k_mul_row(target_row, source_row, k)
	local A = {}
	for i = 1, self.rows do
		A[i] = {}
		for j = 1, self.cols do
			A[i][j] = self.set[i][j]
		end
	end

	for j = 1, self.cols do
		A[target_row][j] = A[target_row][j] + A[source_row][j] * k
	end

	return matrix:new(A)
end

function matrix:k_mul_row_inplace(row, k)
	for j = 1, self.cols do
		self.set[row][j] = self.set[row][j] * k
	end
	self.det = nil
	return self
end

function matrix:add_k_mul_row_inplace(target_row, source_row, k)
	for j = 1, self.cols do
		self.set[target_row][j] = self.set[target_row][j] + self.set[source_row][j] * k
	end
	self.det = nil
	return self
end



local function copy2d_(M)
	local C = {}
	for i = 1, #M do
		C[i] = {}
		for j = 1, #M[i] do
			C[i][j] = M[i][j]
		end
	end
	return C
end



function matrix:gauss_jordan()
	local A = {}
	for i = 1, self.rows do
		A[i] = {}
		for j = 1, self.cols do
			A[i][j] = self.set[i][j]
		end
	end

	local m, n = self.rows, self.cols
	local r, lead = 1, 1

	while r <= m and lead <= n do
		-- find pivot row i >= r with nonzero in column lead
		local i = r
		while i <= m and math.abs(A[i][lead]) <= tkz.epsilon do
			i = i + 1
		end

		if i > m then
			lead = lead + 1
		else
			-- swap i <-> r
			A[i], A[r] = A[r], A[i]

			-- normalize pivot row
			local pivot = A[r][lead]
			for j = lead, n do
				A[r][j] = A[r][j] / pivot
			end

			-- eliminate all other rows
			for k = 1, m do
				if k ~= r then
					local factor = A[k][lead]
					if math.abs(factor) > tkz.epsilon then
						for j = lead, n do
							A[k][j] = A[k][j] - factor * A[r][j]
						end
					end
				end
			end

			r = r + 1
			lead = lead + 1
		end
	end

	return matrix:new(A)
end


-- function matrix:rank()
	-- local A = (self.type == "matrix" and self.set or self)
	-- local m, n = self.rows, self.cols
	-- local rank = 0
--
	-- for col = 1, n do
	-- 	local pivot_row = rank + 1
--
	-- 	-- Finding the pivot
	-- 	while pivot_row <= m and A[pivot_row][col] == 0 do
	-- 		pivot_row = pivot_row + 1
	-- 	end
--
	-- 	if pivot_row <= m then
	-- 		-- Swap lines if necessary
	-- 		A[rank + 1], A[pivot_row] = A[pivot_row], A[rank + 1]
--
	-- 		-- Normaliser le pivot à 1
	-- 		local pivot = A[rank + 1][col]
	-- 		for j = 1, n do
	-- 			A[rank + 1][j] = A[rank + 1][j] / pivot
	-- 		end
--
	-- 		-- Eliminate the column
	-- 		for i = 1, m do
	-- 			if i ~= rank + 1 then
	-- 				local factor = A[i][col]
	-- 				for j = 1, n do
	-- 					A[i][j] = A[i][j] - factor * A[rank + 1][j]
	-- 				end
	-- 			end
	-- 		end
--
	-- 		rank = rank + 1
	-- 	end
	-- end
--
	-- return rank
-- end

function matrix:rank()
	-- --- work on a copy (NON destructive)
	local A = {}
	for i = 1, self.rows do
		A[i] = {}
		for j = 1, self.cols do
			A[i][j] = self.set[i][j]
		end
	end

	local m, n = self.rows, self.cols
	local rank = 0
	local row = 1

	for col = 1, n do
		-- --- search a pivot
		local pivot_row = nil
		for i = row, m do
			if math.abs(A[i][col]) > tkz.epsilon then
				pivot_row = i
				break
			end
		end

		if pivot_row then
			-- --- swap rows if needed
			A[row], A[pivot_row] = A[pivot_row], A[row]

			-- --- normalize pivot row
			local pivot = A[row][col]
			for j = col, n do
				A[row][j] = A[row][j] / pivot
			end

			-- --- eliminate below
			for i = row + 1, m do
				local factor = A[i][col]
				if math.abs(factor) > tkz.epsilon then
					for j = col, n do
						A[i][j] = A[i][j] - factor * A[row][j]
					end
				end
			end

			rank = rank + 1
			row  = row + 1

			if row > m then break end
		end
	end

	return rank
end


return matrix
