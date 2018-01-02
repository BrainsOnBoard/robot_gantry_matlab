function [newx,newy] = rotatexy(x,y,th)
    cs = cos(th);
    sn = sin(th);
    newx = x.*cs - y.*sn;
    newy = x.*sn + y.*cs;
end