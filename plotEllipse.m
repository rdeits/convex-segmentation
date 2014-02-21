function  p2 = plotEllipse(S,level_set,x0,col)

if (nargin < 4)
    col = 'r';
end

theta=linspace(0,2*pi,10000);
points=[cos(theta); sin(theta)];

p2 = sqrt(level_set)*points./[sqrt(diag(points'*S*points)');sqrt(diag(points'*S*points)')];

% hold on;
% grid on;

p2(1,:) = p2(1,:) + x0(1);
p2(2,:) = p2(2,:) + x0(2);

plot(p2(1,:),p2(2,:),col,'LineWidth',2);
%plot([p2(1,1),p2(1,end)],[p2(2,1),p2(2,end)], ...
 %    col,'LineWidth',2);
 
%fill(p2(1,:),p2(2,:),col);

end