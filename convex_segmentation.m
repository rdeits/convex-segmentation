function x = convex_segmentation(grid)
%% Convex Segmentation
% Given a binary image stored in [grid], return a binary image
% corresponding to the largest convex region of true values
% in the input image. 

% For example, running on this input:
% grid = [1, 0, 0, 0;
%         1, 0, 1, 0;
%         1, 1, 1, 0;
%         1, 1, 1, 1];
% 
% produces the following mask:
% x = [0, 0, 0, 0;
%      0, 0, 0, 0;
%      1, 1, 1, 0;
%      1, 1, 1, 1]

grid
grid_flat = reshape(grid, [], 1);
assert(size(grid,1) == size(grid,2))
n = size(grid,1);

tic
% profile on
x0 = zeros(n^2, 1);
A = sparse(zeros(length(x0)^3, length(x0)));
b = zeros(size(A, 1), 1);
con_ndx = 1;


R = rotmat(pi/2);
eps = 1/sqrt(2) + 1e-3;
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
        for j = 2:(length(r3s)-1)
          r3 = r3s(j);
          c3 = c3s(j);
          x3_ndx = (c3-1)*n + r3;
          A(con_ndx, [x1_ndx, x2_ndx, x3_ndx]) = [1, 1, -1];
          b(con_ndx) = 1.5;
          con_ndx = con_ndx + 1;
          fprintf(1, '%d and %d constrain %d\n', x1_ndx, x2_ndx, x3_ndx);
        end
        
%         a = R * [r2-r1; c2-c1];
%         a = a / norm(a);
%         b12 = a' * [r1;c1];
%         for r3 = min([r1,r2]):max([r1,r2])
%           for c3 = min([c1,c2]):max([c1,c2])
%             x3_ndx = (c3-1)*n + r3;
%             if r3 == r1 && c3 == c1
%               continue
%             elseif r3 == r2 && c3 == c2
%               continue
%             end
%             b3 = a' * [r3;c3];
%             if abs(b3 - b12) < eps
%               A(con_ndx, [x1_ndx, x2_ndx, x3_ndx]) = [1, 1, -1];
%               b(con_ndx) = 1.5;
%               con_ndx = con_ndx + 1;
% %               fprintf(1, '%d and %d constrain %d\n', x1_ndx, x2_ndx, x3_ndx);
%             end
%           end
%         end
      end
    end
  end
end
A = double(A(1:(con_ndx-1), :));
b = b(1:(con_ndx-1));
fprintf(1, 'Setup time: %f  s\n', toc);

% Aeq = sparse(zeros(length(x0), length(x0)));
% beq = zeros(size(Aeq, 1), 1);
hulls = {};

while true
  lb = zeros(length(x0), 1);
  ub = ones(length(x0), 1);
  for j = 1:length(x0)
    if ~grid_flat(j)
      ub(j) = 0;
  %     Aeq(j, j) = 1;
    end
  end


  c = -ones(size(x0));

  % tic
  % x = bintprog(c, A, b, Aeq, beq, x0);
  % fprintf(1, 'bintprog solve time: %f s\n', toc);

  clear model params
  model.obj = c;
  model.A = A;
  model.rhs = b;
  model.ub = ub;
  model.lb = lb;
  model.sense = '<';
  model.vtype = 'B';
  model.start = x0;
  params.outputflag = 0;

  tic
  result = gurobi(model, params);
  fprintf(1, 'gurobi solve time: %f s\n', toc);


  x = reshape(result.x, size(grid))
  hulls{end+1} = x;
  grid_flat(logical(x)) = 0;
  if all(grid_flat == 0)
    break
  end
end
% 
% figure();
% cmap = colormap('jet');
% for j = 1:length(hulls)
%   h = imshow(hulls{j}+1, [0,0,0; cmap(round((j-1) * (size(cmap, 1) / length(hulls))+1),:)]);
%   alphadata = hulls{j};
%   set(h, 'AlphaData', alphadata);
%   hold on
% end


% profile viewer
        