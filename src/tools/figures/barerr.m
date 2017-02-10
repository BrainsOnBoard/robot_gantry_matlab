function h=barerr(x,y,err,col)
% BARERR   Plots a bar graph with error bars for e.g. std.
%
% x: x coordinates
% y: y coordinates
% err: error values (should be same dimensions as x and y)
% col: colour of bars (default: white)
%
% Example:
%       barerr(1:4, rand(1,4), rand(1,4) / 2)

if nargin < 3 || ischar(err) % then x param has been omitted
    if nargin==3
        col = err;
    end
    err = y;
    y = x;
    clear x
else
    x = x(:)';
end
if ~exist('col','var')
    col = 'w';
end

y = y(:)';
err = err(:)';

ih = ishold;
if ~ih
    hold on
end

sgn = sign(y);
L = -(sgn==-1).*err;
U = (sgn==1).*err;

if exist('x','var')
    h=bar(x,y,'FaceColor',col);
    errorbar(x,y,L,U,'Color','k','LineStyle','none');
else
    h=bar(y,'FaceColor',col);
    errorbar(h.XData+h.XOffset,y,L,U,'Color','k','LineStyle','none');
end

if ~ih
    hold off
end

if ~nargout
    clear h
end