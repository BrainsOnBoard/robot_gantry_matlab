function g_bb_ridf_getmostdiff_printbest
improc = '';
snapszht = 200;
[minima,imxi,imyi,p] = g_bb_ridf_getmostdiff('imdb_2017-02-09_001',1,[],snapszht,false,improc);

%% get biggest diffs for given snapszht
[~,I] = sort(minima(:,end)-minima(:,1),'descend');
coords = [p.xs(imxi(I))' p.ys(imyi(I))'];

%% print results
fprintf('\ncoords = [%d %d',coords(1,:))
for i = 2:10
    fprintf('; %d %d',coords(i,:))
end
fprintf('];\n');
