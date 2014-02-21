function mask = convex_rays(grid, seed_grid)

grid = logical(grid);

dists = obs_dist(seed_grid);
[~, i0] = max(reshape(dists, [], 1));

% ndx = find(seed_grid);
% i0 = ndx(randi([1,length(ndx)]));
[r0, c0] = ind2sub(size(grid), i0);
active_set = {[0.5,0.5,0.5,0.5]};
explored_set = containers.Map();

[white_squares(1,:), white_squares(2,:)] = ind2sub(size(grid), find(grid));
[black_squares(1,:), black_squares(2,:)] = ind2sub(size(grid), find(~grid));

while true
  new_active_set = containers.Map();
  for j = 1:length(active_set)
    ray_lengths = active_set{j};
    for ray_to_extend = 1:4
      new_ray_lengths = ray_lengths;
      new_ray_lengths(ray_to_extend) = new_ray_lengths(ray_to_extend) + 1;
      hash = sprintf('%f', new_ray_lengths);
      if isKey(explored_set, hash)
        continue
      end
      new_corners = bsxfun(@plus, [r0;c0], bsxfun(@times, new_ray_lengths, [[1;0], [0;1], [-1;0], [0;-1]]));
      if any(new_corners(1,:) < 0 | new_corners(1,:) > size(grid,1)+1 | new_corners(2,:) < 0 | new_corners(2,:) > size(grid,2)+1)
        continue
      end
      new_corners = [new_corners, new_corners(:,1)];
      [A, b] = poly2lincon(new_corners(1,:), new_corners(2,:),true);
      if any(all(bsxfun(@minus, A * black_squares, b) <= 0))
        continue
      end      
      explored_set(hash) = true;
      new_active_set(hash) = new_ray_lengths;
    end
  end
  if isempty(new_active_set)
    break
  end
  active_set = new_active_set.values();
  areas = zeros(1,length(active_set));
  for j = 1:length(active_set)
    ray_lengths = active_set{j};
    areas(j) = 0.5 * sum(ray_lengths .* ray_lengths([2,3,4,1]));
  end
  [~, ndx] = max(areas);
  active_set = active_set(ndx);
end
  
areas = zeros(1,length(active_set));
for j = 1:length(active_set)
  ray_lengths = active_set{j};
  corners = bsxfun(@plus, [r0;c0], repmat(ray_lengths,2,1) .* [[1;0], [0;1], [-1;0], [0;-1]]);
  xv = [corners(1,:), corners(1,1)];
  yv = [corners(2,:), corners(2,1)];
  IN = inpolygon(white_squares(1,:), white_squares(2,:), xv, yv);
  areas(j) = sum(IN);
end
[~, ndx] = max(areas);

ray_lengths = active_set{ndx};
corners = bsxfun(@plus, [r0;c0], repmat(ray_lengths,2,1) .* [[1;0], [0;1], [-1;0], [0;-1]]);
xv = [corners(1,:), corners(1,1)];
yv = [corners(2,:), corners(2,1)];
[R, C] = meshgrid(1:size(grid,1), 1:size(grid,2));
mask = inpolygon(R, C, xv, yv)';
      