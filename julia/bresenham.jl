module Bresenham
export Line

# Ported from Aaron Wetzler's algorithm from matlabcentral

function diff(x::Array)
	return [x[i+1] - x[i] for i in [1:(length(x)-1)]]
end

function Line(x1::Int64, y1::Int64, x2::Int64, y2::Int64)
	dx = abs(x2-x1)
	dy = abs(y2-y1)
	steep = abs(dy) > abs(dx)
	if steep
		dx, dy = dy, dx
	end

	if dy == 0
		q = falses(dx+1)
	else
		q = vcat([false], map(x -> x >= 0, diff(mod([int(floor(dx/2)):-dy:-dy*dx+int(floor(dx/2))], dx))))
	end

	if steep
		if y1 <= y2
			y = [y1:y2]
		else
			y = [y1:-1:y2]
		end
		if x1 <= x2
			x = x1 + cumsum(q)
		else
			x = x1 - cumsum(q)
		end
	else
		if x1 <= x2
			x = [x1:x2]
		else
			x = [x1:-1:x2]
		end
		if y1 <= y2
			y = y1 + cumsum(q)
		else
			y = y1 - cumsum(q)
		end
	end
	x, y
end

function Line(x1, y1, x2, y2)
	Line([int(round(z)) for z in [x1, y1, x2, y2]]...)
end

end


