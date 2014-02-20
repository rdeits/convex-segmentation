function [ok, points] = check_convex_addition(grid, points, ni)

mask = zeros(size(grid));
mask(points) = 1;
[r, c] = ind2sub(size(grid), ni);
[rh, ch] = ind2sub(size(grid), points);
for j = 1:length(rh)
  [rb, cb] = bresenham(r, c, rh(j), ch(j));
  for k = 2:(length(rb)-1)
    if ~mask(rb(k), cb(k))
      ok = false;
      return
    end
  end
end
points = sort([points; ni]);
ok = true;

end
