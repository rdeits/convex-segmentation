function mask = convex_edges(grid)

grid = logical(grid);

max_num_sides = 5;

initial_offset = [0.5, 0.5, -0.5, -0.5;
                 -0.5, 0.5, 0.5, -0.5];
ndx = find(grid);
i0 = ndx(randi([1,length(ndx)]));
[r, c] = ind2sub(size(grid), i0);
active_set = {bsxfun(@plus, [r;c], initial_offset)};
explored_set = containers.Map();

edge_mask = find_edges(grid);
[edge_squares(1,:), edge_squares(2,:)] = ind2sub(size(grid), find(edge_mask));

[white_squares(1,:), white_squares(2,:)] = ind2sub(size(grid), find(grid));
[black_squares(1,:), black_squares(2,:)] = ind2sub(size(grid), find(~grid));

while true
  new_active_set = containers.Map();
  for j = 1:length(active_set)
    corners = active_set{j};

    for i = 1:size(edge_squares, 2)
      new_corners = [corners, edge_squares(:,i)];
      new_corners = new_corners(:,convhull(new_corners(1,:), new_corners(2,:), 'simplify', true));
      if size(new_corners, 2) >= (max_num_sides+1)
        continue
      end
      hash = sprintf('%f', new_corners(:,1:end-1));
%       hash = num2str(new_corners(:,1:end-1)');
      if ~isKey(explored_set, hash)
%       clf
%       plot(new_corners(1,:), new_corners(2,:))
%       hold on
%       plot(black_squares(1,:), black_squares(2,:), 'ko')
%       xlim([0, size(grid,1)+1])
%       ylim([0, size(grid,2)+1])
%       drawnow()
        [A, b] = poly2lincon(new_corners(1,:), new_corners(2,:),true);
        if any(all(bsxfun(@minus, A * black_squares, b) <= 0))
%         if any(inpolygon(black_squares(1,:), black_squares(2,:), new_corners(1,:), new_corners(2,:)))
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






