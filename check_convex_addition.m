function ok = check_convex_addition(mask, r, c)
  [ri, ci] = find(mask);
  for j = 1:length(ri)
    [rb, cb] = bresenham(r, c, ri(j), ci(j));
    for k = 2:(length(rb)-1)
      if ~mask(rb(k), cb(k))
        ok = false;
        return;
      end
    end
  end
  ok = true;
end