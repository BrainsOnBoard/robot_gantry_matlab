function g_bb_getworst(fprefix,snapsonly)
[~,shortwhd] = g_imdb_choosedb;
if nargin && ~isempty(fprefix)
    shortwhd = [fprefix shortwhd];
end
if nargin < 2
    snapsonly = false;
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

merrs = mean(errs,2);
[mworst,mI] = sort(merrs,'descend');
mI = mI(1:ncoords);
mworst = mworst(1:ncoords);

maxerrs = max(errs,[],2);
[maxworst,maxI] = sort(maxerrs,'descend');
maxI = maxI(1:ncoords);
maxworst = maxworst(1:ncoords);

disp('Worst mean errors:')
fprintf('%g, ',mworst)
fprintf('\n')

disp('Worst max errors:')
fprintf('%g, ',maxworst)
fprintf('\n')

mbadcoords = [p.xs(imxi(xyi(mI)))' p.ys(imyi(xyi(mI)))'];
fprintf('\n%% worst-matching positions - mean error')
if snapsonly
    fprintf(', snaps only')
end
fprintf('\nbadcoords = [%d %d', mbadcoords(1,:))
for i = 2:length(mI)
    fprintf('; %d %d',mbadcoords(i,:))
end
fprintf('];\n');

maxbadcoords = [p.xs(imxi(xyi(maxI)))' p.ys(imyi(xyi(maxI)))'];
fprintf('\n%% worst-matching positions - max error')
if snapsonly
    fprintf(', snaps only')
end
fprintf('\nbadcoords = [%d %d', maxbadcoords(1,:))
for i = 2:length(maxI)
    fprintf('; %d %d',maxbadcoords(i,:))
end
fprintf('];\n\n');
