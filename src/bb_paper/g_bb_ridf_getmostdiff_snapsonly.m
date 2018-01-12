function [minima,snxi,snyi,p]=g_bb_ridf_getmostdiff_snapsonly(shortwhd,routenum,zht,snapszht,userealsnaps,improc)
if nargin < 1 || isempty(shortwhd)
    shortwhd='imdb_2017-02-09_001';  % open, pile
%     shortwhd='imdb_2016-03-29_001'; % open, boxes
%     shortwhd='imdb_2016-02-08_003'; % closed, boxes (z=250mm)
%     shortwhd='imdb_2017-06-06_001'; % closed, plants
end
if nargin < 2 || isempty(routenum)
    routenum = 1;
end
if nargin < 3 || isempty(zht)
    zht = 0:100:500; % +50mm
else
    zht = sort(zht);
end
if nargin < 4 || isempty(snapszht)
    snapszht = 200; % +50mm
else
    snapszht = sort(snapszht);
end
if nargin < 5 || isempty(userealsnaps)
    userealsnaps = false;
end
if nargin < 6 || isempty(improc)
    improc = '';
end

if userealsnaps && length(snapszht) > 1
    % this may change...
    error('cannot have real snapshots and multiple snapszht')
end

forcegen = false;

imsz = [7 90];
% whd = fullfile(g_dir_imdb,shortwhd);

%% load RIDFs
% extract best-matching snaps and RIDFs and put into cell array (because
% the dimensions differ)
[bestsnap,bestridfs,imxyi] = deal(cell(length(zht),length(snapszht)));
for i = 1:length(zht)
    for j = 1:length(snapszht)
        [imxi,imyi,~,whsn,~,~,~,~,~,~,~,p,~,~,ridfs,~,snxi,snyi] = g_imdb_route_getdata( ...
            shortwhd,routenum,imsz(2),zht(i),false,improc,forcegen,[], ...
            userealsnaps,snapszht(j));
        
        xmatch = bsxfun(@eq,imxi,snxi');
        ymatch = bsxfun(@eq,imyi,snyi');
        sel = any(xmatch & ymatch,2);
        ridfs = ridfs(sel,:,:);
        clear imxi imyi

        imxyi{i,j} = [snxi snyi];
        bestsnap{i,j} = whsn;
        bestridfs{i,j} = NaN(length(snxi),imsz(2));
        for k = 1:size(ridfs,1)
            bestridfs{i,j}(k,:) = ridfs(k,:,whsn(k)) / prod(imsz);
        end
    end
end

% TODO: fix this for when number of snapshots differs with height
minima = NaN([size(bestridfs{1},1) size(bestridfs)]);
for i = 1:size(minima,2)
    for j = 1:size(minima,3)
        minima(:,i,j) = min(bestridfs{i,j},[],2);
    end
end
