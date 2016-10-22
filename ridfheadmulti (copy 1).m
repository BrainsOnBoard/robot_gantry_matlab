function [head,minval,whsn,diffs] = ridfheadmulti(im,imref,snapweighting,angleunit,nth,snths)
% weightings: 'wta', 'norm', {'norm', num},

% if nargin < 7
%     fov = 360;
% end
% fovpx = round(size(im,2)*fov/360);

if nargin < 6 || isempty(snths)
    snths = zeros(1,size(imref,3));
else
    snths = snths(:)';
end
if nargin < 5 || isempty(nth)
    nth = size(imref,2);
end
if nargin < 4 || isempty(angleunit)
    angleunit = 2*pi;
end
if nargin < 3 || isempty(snapweighting)
    sweightstr = 'wta';
elseif iscell(snapweighting)
    sweightstr = snapweighting{1};
    sweightparam = snapweighting{2};
elseif ischar(snapweighting)
    sweightstr = snapweighting;
    sweightparam = [];
else
    sweightstr = '';
    wt = snapweighting;
end

rots = linspace(0,size(im,2),nth+1);
rots = -round(rots(1:end-1));

diffs = NaN(nth,size(imref,3));
for i = 1:nth
    diffs(i,:) = shiftdim(sumabsdiff(cshiftcut(im,size(imref,2),rots(i)),imref),1);
end

[minvalall,I] = min(diffs);
if strcmpi(sweightstr,'wta')
    [minval,whsn] = min(minvalall);
    head = angleunit*(snths(whsn)/(2*pi)+(I(whsn)-1)/size(im,2));
else
    switch sweightstr
        case 'equal'
            wt = ones(1,size(imref,3));
            whsn = 1:size(imref,3);
        case 'norm'
            if isempty(sweightparam)
                wt = min(minvalall)./minvalall;
                whsn = 1:size(imref,3);
            else
                [smin,whsn] = sort(minvalall);
                whsn = whsn(1:sweightparam);
                wt = min(minvalall)./smin(1:sweightparam);
            end
        case ''
            whsn = 1:length(wt);
    end
    mhead = circ_mean(snths(whsn)+(I(whsn)-1)*2*pi/size(im,2),wt,2);
    head = mhead*angleunit/(2*pi);
    minval = minvalall;
end