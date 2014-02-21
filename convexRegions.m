% Initialize program
prog = spotsosprog;

% Generate random points
N = 10;
dim = 2;
pts = 10*randn(dim,N);

% Make sure pts are outside ellipse
[prog,rho] = prog.newFree(1);

[prog,S] = prog.newPSD(dim);

x0 = [0;0];

for k = 1:N
    prog = prog.withPos((pts(:,k)-x0)'*S*(pts(:,k)-x0) - rho);
end

prog = prog.withEqs(1 - trace(S));

options = spot_sdp_default_options;
options.verbose = 1;
sol = prog.minimize(-rho,@spot_sedumi,options);

S_opt = double(sol.eval(S));
rho_opt = double(sol.eval(rho));

plotEllipse(S_opt,rho_opt,x0,'r');
hold on
plot(pts(1,:),pts(2,:),'bo')