function mask = convex_ellipse(grid, seed_grid)

grid = logical(grid);

dists = obs_dist(seed_grid);
dists(1:end,[1,end]) = 0;
dists([1,end],1:end) = 0;
[~, i0] = max(reshape(dists, [], 1));
[r0, c0] = ind2sub(size(grid), i0);
x0 = [r0; c0]

[white_squares(1,:), white_squares(2,:)] = ind2sub(size(grid), find(grid));
[black_squares(1,:), black_squares(2,:)] = ind2sub(size(grid), find(~grid));
[black_edges(1,:), black_edges(2,:)] = ind2sub(size(grid), find(find_edges(~grid)));

% Initialize program
prog = spotsosprog;
dim = 2;

% Make sure pts are outside ellipse
[prog,rho] = prog.newFree(1);

[prog,S] = prog.newPSD(dim);


for k = 1:size(black_squares,2)
    prog = prog.withPos((black_squares(:,k)-x0)'*S*(black_squares(:,k)-x0) - rho);
end
xmin = 0;
xmax = size(grid,1)+1;
ymin = 0;
ymax = size(grid,2)+1;
% prog = prog.withPos(S(2,2)*S(1,1)-S(1,2)*S(2,1)*(xmin-x0(1))^2 - rho*S(2,2));
% prog = prog.withPos(S(2,2)*S(1,1)-S(1,2)*S(2,1)*(xmax-x0(1))^2 - rho*S(2,2));
% prog = prog.withPos(([xmin - x0(1);0])'*S*([xmin - x0(1);0]) - rho);
% prog = prog.withPos(([xmax - x0(1);0])'*S*([xmax - x0(1);0]) - rho);
% prog = prog.withPos(([0;ymin - x0(2)])'*S*([0;ymin - x0(2)]) - rho);
% prog = prog.withPos(([0;ymax - x0(2)])'*S*([0;ymax - x0(2)]) - rho);

prog = prog.withEqs(1 - trace(S));

options = spot_sdp_default_options;
options.verbose = 1;
sol = prog.minimize(-rho,@spot_sedumi,options);

S_opt = double(sol.eval(S));
rho_opt = double(sol.eval(rho));

% figure(2)
% clf
% plotEllipse(S_opt,rho_opt,x0,'r');
% hold on
% plot(black_squares(1,:),black_squares(2,:),'bo')
figure(1)

[R, C] = meshgrid(1:size(grid,1), 1:size(grid,2));
R = reshape(R', 1,[]);
C = reshape(C', 1,[]);
delta = bsxfun(@minus, [R;C], x0);
d = sum((delta' * S_opt)' .* delta);
mask = false(size(grid));
mask(d < rho_opt) = true;
