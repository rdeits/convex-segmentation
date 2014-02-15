function largest_set = convex_connections()

grid = [1, 0, 0, 0;
        1, 0, 1, 0;
        1, 1, 1, 0;
        1, 1, 1, 1];
      
active_set = mat2cell(find(grid), ones(size(find(grid))), 1);
% active_set = {[1]}


% TODO: I think we can sort h, and then only work on the neighbors of
% h(end) which are greater than h(end)?

while true
  new_active_set = {};
  for j = 1:length(active_set)
    h = active_set{j};
%     for k = 1:length(h)
      x = h(end);
      n = neighbors(grid,x);
      for i = 1:length(n)
        ni = n(i);
        if ni <= x
          continue
        end
        if ~grid(ni)
          continue
        end
        if any(ismember(h, ni))
          continue
        end
        mask = zeros(size(grid));
        mask(h) = 1;
        [r, c] = ind2sub(size(grid), ni);
        ok = check_convex_addition(mask, r, c);
        if ~ok
          continue
        end
        new_active_set{end+1} = [h; ni];
        cell2mat(new_active_set)
      end
%     end
  end
  if isempty(new_active_set)
    break
  end
  active_set = new_active_set;
end

ls = cellfun(@length, active_set);
[~, ndx] = max(ls);
largest_set = active_set{ndx};
      
end