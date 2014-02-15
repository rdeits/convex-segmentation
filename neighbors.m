function  ndx = neighbors(mask, x)

[m, n] = size(mask);
% r = mod(x-1, m)+1;
% c = floor((x-1) / m) + 1;
[r, c] = ind2sub(size(mask), x);
ri = max([1,r-1]):min([m,r+1]);

ci = max([1,c-1]):min([n,c+1]);

[R, C] = meshgrid(ri, ci);
ndx = reshape(R,[],1) + (reshape(C,[],1)-1) .* m;
ndx(ndx==x) = [];

end

