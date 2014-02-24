function mask = convex_corners(grid, seed_grid)

max_num_sides = 25;

initial_offset = [0.5, 0.5, -0.5, -0.5;
                 -0.5, 0.5, 0.5, -0.5];

grid = logical(grid);

dists = obs_dist(seed_grid);
[~, i0] = max(reshape(dists, [], 1));

[r, c] = ind2sub(size(grid), i0);
active_set = {bsxfun(@plus, [r;c], initial_offset)};
explored_set = containers.Map();

displacements = [1, 1, 1, 0, -1, -1, -1, 0;
                 -1, 0, 1, 1, 1, 0, -1, -1];

[white_squares(1,:), white_squares(2,:)] = ind2sub(size(grid), find(grid));
[black_squares(1,:), black_squares(2,:)] = ind2sub(size(grid), find(~grid));

while true
  new_active_set = containers.Map();
  for j = 1:length(active_set)
    corners = active_set{j};

    neighbors = zeros(2, 8*size(corners, 2));
    n_ndx = 1;
    for k = 1:size(corners, 2)
      for d = 1:size(displacements, 2)
        neighbors(:,n_ndx) = corners(:,k) + displacements(:,d);
        n_ndx = n_ndx + 1;
      end
    end
    xv = [corners(1,:), corners(1,1)];
    yv = [corners(2,:), corners(2,1)];
%     [IN] = inpolygon(neighbors(1,:), neighbors(2,:), xv, yv);
%     neighbors(:,IN) = [];
    neighbors(:,neighbors(1,:) < 0 | neighbors(1,:) > (size(grid,1)+1)) = [];
    neighbors(:,neighbors(2,:) < 0 | neighbors(2,:) > (size(grid,2)+1)) = [];
    neighbors = unique(neighbors', 'rows')';

    for i = 1:size(neighbors, 2)
      new_corners = [corners, neighbors(:,i)];
      new_corners = new_corners(:,convhull(new_corners(1,:), new_corners(2,:)));
      if size(new_corners, 2) >= max_num_sides + 1
        continue
      end
      hash = sprintf('%f', new_corners(:,1:end-1));
      if ~isKey(explored_set, hash)
        [A, b] = poly2lincon(new_corners(1,:), new_corners(2,:),true);
        if any(all(bsxfun(@minus, A * black_squares, b) <= 0))
          continue
        end
        explored_set(hash) = true;
        new_active_set(hash) = new_corners(:,1:end-1);
      end
    end
  end
  if isempty(new_active_set)
    break
  end
  active_set = new_active_set.values();
  areas = zeros(1,length(active_set));
  for j = 1:length(active_set)
    corners = active_set{j};
    corners = [corners, corners(:,1)];
    [A, b] = poly2lincon(new_corners(1,:), new_corners(2,:),true);
    areas(j) = sum(all(bsxfun(@minus, A * white_squares, b) <= 0));
  end
  [~, ndx] = max(areas);
  active_set = active_set(ndx);

end

% areas = zeros(1,length(active_set));
% for j = 1:length(active_set)
%   corners = active_set{j};
%   xv = [corners(1,:), corners(1,1)];
%   yv = [corners(2,:), corners(2,1)];
%   IN = inpolygon(white_squares(1,:), white_squares(2,:), xv, yv);
%   areas(j) = sum(IN);
% end
% 
% [~, ndx] = max(areas);
% corners = active_set{ndx};
corners = active_set{1};
xv = [corners(1,:), corners(1,1)];
yv = [corners(2,:), corners(2,1)];
[R, C] = meshgrid(1:size(grid,1), 1:size(grid,2));
mask = inpolygon(R, C, xv, yv)';






