function g_bb_getbestworst(fprefix,snapsonly,getbest)
[~,shortwhd] = g_imdb_choosedb;
if nargin && ~isempty(fprefix)
    shortwhd = [fprefix shortwhd];
end
if nargin < 2
    snapsonly = false;
end
if nargin < 3
    getbest = true;
end

routenum = input('Enter route number [1]: ');
if isempty(routenum)
    routenum = 1;
end

improc = '';
snapszht = 200;
snapszhtall = 0:100:500;
ncoords = 10;

errs = cell(1,length(snapszhtall));
for i = 1:length(snapszhtall)
    [imxi,imyi,~,~,allerrs,~,~,~,~,~,errsel,p,~,~,~,snapszht,snxi,snyi] = g_imdb_route_getdata( ...
        shortwhd,routenum,90,snapszhtall(i),false,improc,false,[], ...
        false,snapszht);
    
    if snapsonly
        % only interested in snapshot positions
        [xyi,~] = find(bsxfun(@eq,snxi',imxi) & bsxfun(@eq,snyi',imyi));
        errs{i} = allerrs(xyi);
    else
        % get errors from "error corridor"
        xyi = find(errsel);
%         xyi = 1:length(imxi);
        errs{i} = allerrs(xyi);
    end
end
errs = cell2mat(errs);

if getbest
    sorttype = 'ascend';
else
    sorttype = 'descend';
end

merrs = mean(errs,2);
[mean_vals,mI] = sort(merrs,sorttype);
mI = mI(1:ncoords);
mean_vals = mean_vals(1:ncoords);

if getbest
    extreme_errs = min(errs,[],2);
else
    extreme_errs = max(errs,[],2);
end
[extreme_vals,maxI] = sort(extreme_errs,sorttype);
maxI = maxI(1:ncoords);
extreme_vals = extreme_vals(1:ncoords);

if getbest
    disp('Best mean errors:')
else
    disp('Worst mean errors:')
end
fprintf('%g, ',mean_vals)
fprintf('\n')

if getbest
    disp('Best min errors:')
else
    disp('Worst max errors:')
end
fprintf('%g, ',extreme_vals)
fprintf('\n')

mcoords = [p.xs(imxi(xyi(mI)))' p.ys(imyi(xyi(mI)))'];
if getbest
    fprintf('\n%% best-matching positions - mean error')
else
    fprintf('\n%% worst-matching positions - mean error')
end
if snapsonly
    fprintf(', snaps only')
end
if getbest
    fprintf('\ngoodcoords = [%d %d', mcoords(1,:))
else
    fprintf('\nbadcoords = [%d %d', mcoords(1,:))
end
for i = 2:length(mI)
    fprintf('; %d %d',mcoords(i,:))
end
fprintf('];\n');

extreme_coords = [p.xs(imxi(xyi(maxI)))' p.ys(imyi(xyi(maxI)))'];
if getbest
    fprintf('\n%% best-matching positions - min error')
else
    fprintf('\n%% worst-matching positions - max error')
end
if snapsonly
    fprintf(', snaps only')
end
if getbest
    fprintf('\ngoodcoords = [%d %d', extreme_coords(1,:))
else
    fprintf('\nbadcoords = [%d %d', extreme_coords(1,:))
end
for i = 2:length(maxI)
    fprintf('; %d %d',extreme_coords(i,:))
end
fprintf('];\n\n');
