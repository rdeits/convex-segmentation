function hulls = segmentation(grid, method, show)
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
uncovered_grid = grid;
grid_copy = grid;
% assert(size(grid,1) == size(grid,2))
hulls = {};
A = [];
b = [];
profile on

while true
  if strcmp(method, 'convex')
    [x, A, b] = convex_segmentation(grid, A, b);
  elseif strcmp(method, 'rect')
    [x, A, b] = rectangle_segmentation(grid);
  elseif strcmp(method, 'neighbors')
    [x] = convex_connections(grid);
  elseif strcmp(method, 'corners')
    [x] = convex_corners(uncovered_grid, grid);
  elseif strcmp(method, 'edges')
    [x] = convex_edges(grid);
  elseif strcmp(method, 'rays')
    [x] = convex_rays(uncovered_grid, grid);
  elseif strcmp(method, 'ellipse')
    [x] = convex_ellipse(uncovered_grid, grid);
  end
  hulls{end+1} = x;
  grid(logical(x)) = 0;
  if all(all(grid == 0))
    break
  end
  if show
    img = zeros([size(grid), 3]);
    clf
    cmap = colormap('jet');
    for j = 1:length(hulls)
      for i = 1:size(hulls{j}, 1)
        for k = 1:size(hulls{j}, 2)
          if hulls{j}(i, k)
            img(i, k, :) = cmap(floor((j-1) * (size(cmap, 1) / length(hulls))+1), :);
          end
        end
      end
    end
    clf
    subplot(211)
    h1 = imshow(imresize(grid_copy, 10, 'nearest'));
    subplot(212)
    h2 = imshow(imresize(img, 10, 'nearest'));
    drawnow()
  end
end

if show
  img = zeros([size(grid), 3]);
  clf
  cmap = colormap('jet');
  for j = 1:length(hulls)
    for i = 1:size(hulls{j}, 1)
      for k = 1:size(hulls{j}, 2)
        if hulls{j}(i, k)
          img(i, k, :) = cmap(floor((j-1) * (size(cmap, 1) / length(hulls))+1), :);
        end
      end
    end
  end
  clf
  subplot(211)
  h1 = imshow(imresize(grid_copy, 10, 'nearest'));
  subplot(212)
  h2 = imshow(imresize(img, 10, 'nearest'));
end
profile viewer