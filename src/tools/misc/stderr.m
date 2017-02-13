function err=stderr(x,dim)
if nargin < 2
    dim = 1+isrow(x);
end

err = sqrt(var(x,0,dim)./size(x,dim));