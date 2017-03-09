function [outx,outy]=bresenham_xy(xs,ys)

dx = diff(xs);
dy = diff(ys);
right = dx > 0;
down = dy > 0;
dx(~right) = -dx(~right);
dy(down) = -dy(down);

outx = [];
outy = [];
for i = 1:length(dx)
    
    err = dx(i)+dy(i);
    x = xs(i);
    y = ys(i);
    while true        
        if x==xs(i+1) && y==ys(i+1)
            break;
        end
        outx = [outx;x];
        outy = [outy;y];
        
        e2 = err * 2;
        if e2 > dy(i)
            err = err+dy(i);
            if right(i)
                x = x+1;
            else
                x = x-1;
            end
        end
        if e2 < dx(i)
            err = err+dx(i);
            if down(i)
                y = y+1;
            else
                y = y-1;
            end
        end
    end
end
outx(end+1) = xs(end);
outy(end+1) = ys(end);