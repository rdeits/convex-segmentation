function mask = find_edges(grid)

grid = logical(grid);
right = imfilter(grid, [1,-1]);
left = imfilter(grid, [-1,1]);
left = [false(size(grid,1),1), left(:,1:end-1)];
top = imfilter(grid, [1;-1]);
bottom = imfilter(grid, [-1;1]);
bottom = [false(1,size(grid,2)); bottom(1:end-1,:)];

borders = false(size(grid));
borders(1:end,[1,end]) = true;
borders([1,end],1:end) = true;


mask = right | left | top | bottom | (borders & grid);

assert(all(grid(mask)));