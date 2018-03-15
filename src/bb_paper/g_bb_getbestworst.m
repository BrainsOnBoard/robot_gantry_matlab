function [meandat,extremedat,routenum,mindist]=g_bb_getbestworst( ...
    shortwhd,zht,snapszht,snapsonly,getbest,ncoords,routenum,mindist)

if nargin < 1 || isempty(shortwhd)
    [~,shortwhd] = g_imdb_choosedb;
end
if nargin < 2 || isempty(zht)
    zht = 0:100:500;
end
if nargin < 3 || isempty(snapszht)
    snapszht = 200;
end
if nargin < 4 || isempty(snapsonly)
    snapsonly = false;
end
if nargin < 5 || isempty(getbest)
    getbest = true;
end
if nargin < 6 || isempty(ncoords)
    ncoords = 10;
end
if nargin < 7 || isempty(routenum)
    routenum = inputval('Enter route number',1);
end
if nargin < 8
    mindist = 0;
elseif isempty(mindist)
    mindist = inputval('Enter minimum distance from point to snap',0);
end

improc = '';

[errs,headings,whsn] = deal(cell(1,length(zht)));
for i = 1:length(zht)
    [imxi,imyi,heads,allwhsn,allerrs,~,dist,~,~,~,errsel,p,~,~,~,snapszht,snxi,snyi] = g_imdb_route_getdata( ...
        shortwhd,routenum,90,zht(i),false,improc,false,[], ...
        false,snapszht);
    
    if snapsonly
        % only interested in snapshot positions
        [xyi,~] = find(bsxfun(@eq,snxi',imxi) & bsxfun(@eq,snyi',imyi));
    else
        % get errors from "error corridor"
        xyi = find(errsel);
%         xyi = 1:length(imxi); % all errors
    end
    % exclude positions where snap was within specified mindist
    xyi(dist(xyi) < mindist) = [];
    
    errs{i} = allerrs(xyi);
    headings{i} = heads(xyi);
    whsn{i} = allwhsn(xyi);
end
errs = cell2mat(errs);
headings = cell2mat(headings);
whsn = cell2mat(whsn);

if getbest
    sorttype = 'ascend';
else
    sorttype = 'descend';
end

maxncoords = length(xyi);
if ncoords > maxncoords
    warning('ncoords > number of available points; capping at %d', maxncoords)
    ncoords = maxncoords;
end

merrs = mean(errs,2);
[meandat.errs,mI] = sort(merrs,sorttype);
if isempty(mI)
    error('no points fit these criteria')
end
if length(mI) < ncoords
    warning('only %d points found (requested %d)',length(mI),ncoords)
    ncoords = length(mI);
else
    mI = mI(1:ncoords);
end
meandat.errs = meandat.errs(1:ncoords);
meandat.allerrs = errs(mI,:);
meandat.headings = headings(mI,:);
meandat.whsn = whsn(mI,:);

if getbest
    extreme_errs = min(errs,[],2);
else
    extreme_errs = max(errs,[],2);
end
[extremedat.errs,exI] = sort(extreme_errs,sorttype);
exI = exI(1:ncoords);
extremedat.errs = extremedat.errs(1:ncoords);
extremedat.allerrs = errs(exI,:);
extremedat.headings = headings(exI,:);
extremedat.whsn = whsn(exI);

if getbest
    disp('Best mean errors:')
else
    disp('Worst mean errors:')
end
fprintf('%g, ',meandat.errs)
fprintf('\n')

if getbest
    disp('Best min errors:')
else
    disp('Worst max errors:')
end
fprintf('%g, ',extremedat.errs)
fprintf('\n')

meandat.coords = [p.xs(imxi(xyi(mI)))' p.ys(imyi(xyi(mI)))'];
if getbest
    fprintf('\n%% best-matching positions - mean error')
else
    fprintf('\n%% worst-matching positions - mean error')
end
if snapsonly
    fprintf(', snaps only')
end
if getbest
    fprintf('\ngoodcoords = [%d %d', meandat.coords(1,:))
else
    fprintf('\nbadcoords = [%d %d', meandat.coords(1,:))
end
for i = 2:length(mI)
    fprintf('; %d %d',meandat.coords(i,:))
end
fprintf('];\n');

extremedat.coords = [p.xs(imxi(xyi(exI)))' p.ys(imyi(xyi(exI)))'];
if getbest
    fprintf('\n%% best-matching positions - min error')
else
    fprintf('\n%% worst-matching positions - max error')
end
if snapsonly
    fprintf(', snaps only')
end
if getbest
    fprintf('\ngoodcoords = [%d %d', extremedat.coords(1,:))
else
    fprintf('\nbadcoords = [%d %d', extremedat.coords(1,:))
end
for i = 2:length(exI)
    fprintf('; %d %d',extremedat.coords(i,:))
end
fprintf('];\n\n');

if ~nargout
    clear meandat extremedat
end
