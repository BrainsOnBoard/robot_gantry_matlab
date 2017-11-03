function [im,mx,my]=makeim(x,y,c,xmax,ymax)

[mx,my] = meshgrid(1:xmax,1:ymax);
im = NaN(size(mx));
for i = 1:numel(mx)
    sel = x==mx(i) & y==my(i);
    if any(sel)
        im(i) = c(sel);
    end
end
