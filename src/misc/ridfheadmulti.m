function [head,minval,whsn,diffs] = ridfheadmulti(im,imref,snapweighting,angleunit,nth,snths,getallwhsn)
% function [head,minval,whsn,diffs] = ridfheadmulti(im,imref,snapweighting,angleunit,nth,snths,getallwhsn)
% TODO: make getallwhsn parameter also apply for weighting schemes other than WTA

if nargin < 7
    getallwhsn = false;
end
if nargin < 6 || isempty(snths)
    snths = zeros(1,size(imref,3));
else
    snths = snths(:)';
end
if nargin < 5 || isempty(nth)
    nth = size(im,2);
elseif nth > size(im,2)
    warning('nth cannot be > size(im,2); using nth=size(im,2)')
    nth = size(im,2);
end
if nargin < 4 || isempty(angleunit)
    angleunit = 2*pi;
end
if nargin < 3 || isempty(snapweighting)
    sweightstr = 'wta'; % default is winner-takes-all
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

if ~isa(im,'double') || ~isa(imref,'double')
    error('im and imref must both be doubles')
end

rots = linspace(0,size(im,2),nth+1);
rots = round(rots(1:end-1));

diffs = NaN(nth,size(imref,3));
for i = 1:nth
    diffs(i,:) = shiftdim(sumabsdiff(cshiftcut(im,size(imref,2),rots(i)),imref),1);
end

[minvalall,I] = min(diffs); % find minimum for each RIDF

if strcmpi(sweightstr,'wta') % winner take all weighting
    if getallwhsn
        [minval,whsn] = sort(minvalall);
    else
        [minval,whsn] = min(minvalall);
    end
    head = angleunit*(snths(whsn(1))/(2*pi)+(I(whsn(1))-1)/nth);
else
    switch sweightstr
        case 'equal' % weight all snapshots equally
            wt = ones(1,size(imref,3));
            whsn = 1:size(imref,3);
        case 'norm' % normalised weights
            if isempty(sweightparam)
                wt = min(minvalall)./minvalall;
                whsn = 1:size(imref,3);
            else
                [smin,whsn] = sort(minvalall);
                whsn = whsn(1:sweightparam);
                wt = min(minvalall)./smin(1:sweightparam);
            end
        case '' % fixed weights
            whsn = 1:length(wt);
    end
    mhead = circ_mean(snths(whsn)+(I(whsn)-1)*2*pi/nth,wt,2);
    head = mhead*angleunit/(2*pi);
    minval = minvalall;
end
