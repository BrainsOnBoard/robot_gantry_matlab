function h=anglequiver(x,y,th,len,color,autoscale,varargin)
% function h=anglequiver(x,y,th,len,color,autoscale)

if numel(y)==size(th,1) && numel(x)==size(th,2)
    [x,y] = meshgrid(x(:),y(:));
end

x = x(:); y = y(:); th = th(:);

if nargin < 7
    varargin = {};
end
if nargin < 6 || autoscale
    autoscale = 'on';
else
    autoscale = 'off';
end
if nargin < 5
    color = 'b';
end
if nargin < 4 || isempty(len)
    len = 1;
else
    len = len(:);
end
[xoff,yoff] = pol2cart(th,len);
h=quiver(x,y,xoff,yoff,'Color',color,'AutoScale',autoscale,varargin{:});

if ~nargout
    clear h
end