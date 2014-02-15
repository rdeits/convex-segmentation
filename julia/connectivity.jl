module Connectivity
import Bresenham
export convex_connections

function check_convex_addition(mask_ndx::Array{Int64}, dims::(Int64, Int64), new_ndx::Int64)
	mask_ndx_set = Set(mask_ndx...)
	ri, ci = ind2sub(dims, mask_ndx)
	r, c = ind2sub(dims, new_ndx)
	for j in [1:length(ri)]
		rb, cb = Bresenham.Line(r, c, ri[j], ci[j])
		for k in [2:length(rb)-1]
			n = sub2ind(dims, rb[k], cb[k])
			if !(n in mask_ndx_set)
				return false
			end
		end
	end
	return true
end

function neighbors(dims::(Int64, Int64), x::Int64)
	m, n = dims
	r, c = ind2sub(dims, x)
	ri = max(1, r-1):min(m, r+1)
	ci = max(1, c-1):min(n, c+1)
	ndx = vcat([rn + [(cn - 1) * m for cn in ci] for rn in ri]...)
	filter!( y -> y != x, ndx)
	return ndx
end

function convex_connections(grid::Array{Bool})
    active_set = [[n] for n in find(grid)]
    
    while true
        new_active_set = Array{Int64}[]
        for j = 1:length(active_set)
            h = active_set[j]
            x = h[end]
            n = neighbors(size(grid), x)
            for i = 1:length(n)
                ni = n[i];
                if ni <= x
                    continue
                end
                if !grid[ni]
                    continue
                end
                if ni in h
                    continue
                end
                ok = check_convex_addition(h, size(grid), ni)
                if !ok
                    continue
                end
                push!(new_active_set, vcat(h, ni))
            end
        end
        if length(new_active_set) == 0
            break
        end
        active_set = copy(new_active_set)
    end
    sort!(active_set, by=length)
    largest_set = active_set[end]
    mask = falses(size(grid))
    mask[largest_set] = true
    return mask
end

end