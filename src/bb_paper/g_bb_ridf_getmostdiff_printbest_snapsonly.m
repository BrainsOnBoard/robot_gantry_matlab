function g_bb_ridf_getmostdiff_printbest_snapsonly
[~,shortwhd] = g_imdb_choosedb;

routenum = input('Enter route number [1]: ');
if isempty(routenum)
    routenum = 1;
end

improc = '';
snapszht = 200;
snapszhtall = 0:100:500;
[minima,imxi,imyi,p] = g_bb_ridf_getmostdiff_snapsonly(shortwhd,routenum,[],snapszhtall,false,improc);

%% get biggest diffs for given snapszht
ind = snapszhtall==snapszht;
[~,I] = sort(minima(:,end,ind)-minima(:,1,ind),'descend');

fprintf('\n%% biggest diffs for snapszht=%d (snaps only)\n',snapszht)
printcoords(I);

%% get biggest average diffs across snapszhts
[~,I] = sort(mean(minima(:,end,:)-minima(:,1,:),3));

disp('% biggest mean diffs across snapzhts (snaps only)')
printcoords(I);

    function printcoords(imind)
        coords = [p.xs(imxi(imind))' p.ys(imyi(imind))'];

        fprintf('coords = [%d %d',coords(1,:))
        for i = 2:10
            fprintf('; %d %d',coords(i,:))
        end
        fprintf('];\n\n');
    end

end
