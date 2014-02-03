function [mask, A, b] = rectangle_segmentation(grid)

tic
n = size(grid, 1);
np = n^2;
ns = 4 * n^2;
nc = 5 * np + 2;
nv = 4;

A = sparse(nc, nv+ns);
b = zeros(nc, 1);
con_ndx = 1;

for r = 1:n
  for c = 1:n
    p_ndx = n*(r-1)+c;
    s_ndx = 4*(p_ndx-1) + (1:4) + nv;
    A(con_ndx, [s_ndx(1), 1]) = [-1, -1/n^2];
    b(con_ndx) = 1/n^2 * (-c - 1);
    con_ndx = con_ndx + 1;

    A(con_ndx, [s_ndx(2), 2]) = [-1, -1/n^2];
    b(con_ndx) = 1/n^2 * (-r - 1);
    con_ndx = con_ndx + 1;

    A(con_ndx, [s_ndx(3), 1, 3]) = [-1, 1/n^2, 1/n^2];
    b(con_ndx) = 1/n^2 * c;
    con_ndx = con_ndx + 1;

    A(con_ndx, [s_ndx(4), 2, 4]) = [-1, 1/n^2, 1/n^2];
    b(con_ndx) = 1/n^2 * r;
    con_ndx = con_ndx + 1;

    A(con_ndx, s_ndx) = [1, 1, 1, 1];
    b(con_ndx) = grid(r, c) + 3.5;
    con_ndx = con_ndx + 1;
  end
end
A(con_ndx, [1, 3]) = [1, 1];
b(con_ndx) = n+1;
con_ndx = con_ndx + 1;

A(con_ndx, [2, 4]) = [1, 1];
b(con_ndx) = n+1;
con_ndx = con_ndx + 1;

clear model params
model.A = A;
% model.obj = zeros(nv+ns, 1);
model.obj = [0;0;1;1; zeros(ns, 1)];
model.rhs = b;
model.sense = '<';
model.lb = [ones(nv, 1); zeros(ns, 1)];
model.ub = [n * ones(nv, 1); ones(ns, 1)];
model.vtype = 'I';
model.modelsense = 'max';
params.outputflag = 0;
% model.Q = Q;
% model.start = [x0; s0];

fprintf(1, 'setup time: %f s\n', toc);
tic
result = gurobi(model, params);
fprintf(1, 'solve time: %f s\n', toc);
x = result.x(1:4)

mask = zeros(size(grid));
mask(x(2):(x(2)+x(4)-1), x(1):(x(1)+x(3)-1)) = 1;
end