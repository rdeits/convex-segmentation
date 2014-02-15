function hulls = segmentation(grid, method)
%% Convex Segmentation
% Given a binary image stored in [grid], return a cell array
% of binary images of convex regions of ones in the input, 
% sorted by descending area. 

% For example, running on this input:
% grid = [1, 0, 0, 0;
%         1, 0, 1, 0;
%         1, 1, 1, 0;
%         1, 1, 1, 1];
%
% produces the following masks:
% hulls{1} = [0, 0, 0, 0;
%             0, 0, 1, 0;
%             1, 1, 1, 0;
%             1, 1, 1, 1]
% hulls{2} = [1, 0, 0, 0;
%             1, 0, 0, 0;
%             0, 0, 0, 0;
%             0, 0, 0, 0]

grid 
grid_copy = grid;
assert(size(grid,1) == size(grid,2))
hulls = {};
A = [];
b = [];

while true
  if strcmp(method, 'convex')
    [x, A, b] = convex_segmentation(grid, A, b);
  elseif strcmp(method, 'rect')
    [x, A, b] = rectangle_segmentation(grid);
  elseif strcmp(method, 'neighbors')
    [x] = convex_connections(grid);
  end
  hulls{end+1} = x;
  grid(logical(x)) = 0;
  if all(all(grid == 0))
    break
  end
end

img = zeros([size(grid), 3]);
figure(1);
cmap = colormap('jet');
for j = 1:length(hulls)
  for i = 1:size(hulls{j}, 1)
    for k = 1:size(hulls{j}, 2)
      if hulls{j}(i, k)
        img(i, k, :) = cmap(round((j-1) * (size(cmap, 1) / length(hulls))+1), :);
      end
    end
  end
end
figure(1)
subplot(211)
h1 = imshow(imresize(grid_copy, 10, 'nearest'));
subplot(212)
h2 = imshow(imresize(img, 10, 'nearest'));