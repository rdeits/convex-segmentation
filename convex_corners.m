function mask = convex_corners(grid)

grid = logical(grid);

initial_offset = [0.5, 0.5, -0.5, -0.5;
                 -0.5, 0.5, 0.5, -0.5];
ndx = find(grid);
i0 = ndx(randi([1,length(ndx)]));
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
      hash = num2str(new_corners(:,1:end-1)');
      if ~isKey(explored_set, hash)
%       plot(new_corners(1,:), new_corners(2,:))
%       xlim([0, size(grid,1)+1])
%       ylim([0, size(grid,2)+1])
%       drawnow()
        if any(inpolygon(black_squares(1,:), black_squares(2,:), new_corners(1,:), new_corners(2,:)))
          continue
        end
        explored_set(hash) = true;
        new_active_set(hash) = new_corners(:,1:end-1); % sigh :(
      end
    end
  end
  if isempty(new_active_set)
    break
  end
  active_set = new_active_set.values();
end

areas = zeros(1,length(active_set));
for j = 1:length(active_set)
  corners = active_set{j};
  xv = [corners(1,:), corners(1,1)];
  yv = [corners(2,:), corners(2,1)];
  IN = inpolygon(white_squares(1,:), white_squares(2,:), xv, yv);
  areas(j) = sum(IN);
end

[~, ndx] = max(areas);
corners = active_set{ndx};
xv = [corners(1,:), corners(1,1)];
yv = [corners(2,:), corners(2,1)];
[R, C] = meshgrid(1:size(grid,1), 1:size(grid,2));
mask = inpolygon(R, C, xv, yv)';






