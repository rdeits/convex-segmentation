function mask = convex_connections(grid)

  grid = logical(grid);

active_set = mat2cell(find(grid), ones(size(find(grid))), 1);
% ndx = find(grid);
% i0 = ndx(randi([1,length(ndx)]));
% active_set = {{i0, i0}};

while true
  new_active_set = {};
  for j = 1:length(active_set)
    points = active_set{j};

    neighborhood = zeros(size(grid));
    for k = 1:length(points)
      n = neighbors(grid, points(k));
      neighborhood(n) = 1;
    end
    neighborhood = neighborhood - ~grid;
    neighborhood(points) = 0;
    new_neighbors = find(neighborhood);
    % new_neighbors = new_neighbors(new_neighbors > points(end));

      for i = 1:length(new_neighbors)
        ni = new_neighbors(i);
        [ok, new_points] = check_convex_addition(grid, points, ni);

        if ~ok
          continue
        end
        if ~any(cellfun(@(p) all(p==new_points), new_active_set))
          new_active_set{end+1} = new_points;
        end
        % end
      end
    % end
  end
  if isempty(new_active_set)
    break
  end
  active_set = new_active_set;
end


ls = cellfun(@length, active_set);
[~, ndx] = max(ls);
largest_set = active_set{ndx};

mask = zeros(size(grid));
mask(largest_set) = 1;

end
