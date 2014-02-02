function hulls = convex_segmentation(grid)
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
grid_flat = reshape(grid, [], 1);
assert(size(grid,1) == size(grid,2))
n = size(grid,1);

tic
x0 = zeros(n^2, 1);
nv = length(x0);
s0 = zeros(nv^2, 1);
ns = length(s0);
A = sparse(nv^2 + ns, nv + ns);
b = zeros(size(A, 1), 1);

con_ndx = 1;
for r1 = 1:n
  for c1 = 1:n
    x1_ndx = (c1-1)*n + r1;
    if ~grid_flat(x1_ndx)
      continue
    end
    for r2 = 1:n
      for c2 = 1:n
        x2_ndx = (c2-1)*n + r2;
        if x2_ndx <= x1_ndx
          continue
        end
        if ~grid_flat(x2_ndx)
          continue
        end
        [r3s, c3s] = bresenham(r1, c1, r2, c2);
        if length(r3s) > 2
          s_ndx = nv*(x1_ndx-1) + x2_ndx;
          A(con_ndx, [x1_ndx, x2_ndx, nv+s_ndx]) = [1, 1, -1];
          b(con_ndx) = 1.5;
          con_ndx = con_ndx + 1;
          
          x3_ndxs = (c3s-1)*n + r3s;
          x3_ndxs = x3_ndxs(2:end-1);
          N = length(x3_ndxs);
          A(con_ndx, [nv+s_ndx, x3_ndxs']) = [N, -ones(size(x3_ndxs'))];
          b(con_ndx) = 0;
          con_ndx = con_ndx + 1;
%           fprintf(1, '%d and %d constrain %d\n', x1_ndx, x2_ndx, x3_ndxs);
        end
      end
    end
  end
end
con_ndx / size(A, 1)
fprintf(1, 'Setup time: %f  s\n', toc);
hulls = {};
lb = zeros(nv + ns, 1);
while true
  ub = [double(logical(grid_flat)); ones(ns, 1)];
  
  c = [-ones(nv, 1); zeros(ns, 1)];

  clear model params
  model.obj = c;
  model.A = A;
  model.rhs = b;
  model.ub = ub;
  model.lb = lb;
  model.sense = '<';
  model.vtype = 'B';
  model.start = [x0; s0];
  params.outputflag = 0;

  tic
  result = gurobi(model, params);
  fprintf(1, 'gurobi solve time: %f s\n', toc);

  
  x = reshape(result.x(1:nv), size(grid));
  hulls{end+1} = x;
  grid_flat(logical(x)) = 0;
  if all(grid_flat == 0)
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
h1 = imshow(imresize(grid, 10, 'nearest'));
subplot(212)
h2 = imshow(imresize(img, 10, 'nearest'));


% profile viewer
        