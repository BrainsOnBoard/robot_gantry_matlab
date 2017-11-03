function [im,mx,my]=makeim(x,y,c)
% function im=makeim(x,y,c)

[mx,my] = meshgrid(unique(x),unique(y));
im = NaN(size(mx));
for i = 1:numel(mx)
    sel = x==mx(i) & y==my(i);
    if any(sel)
        im(i) = c(sel);
    end
end
