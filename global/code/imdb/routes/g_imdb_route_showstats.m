function g_imdb_route_showstats

useinfomax = [false true];
res = [360 180 90];
shortwhd={
    'unwrap_imdb_2016-02-04_002', ... % empty, open
    'unwrap_imdb_2016-02-09_002', ... % empty, closed
    'unwrap_imdb_2016-02-09_001', ... % boxes, open
    'unwrap_imdb_2016-02-05_001'      % boxes, closed
    };
[stds,means] = deal(NaN(length(useinfomax),length(res),length(shortwhd)));

for i = 1:length(useinfomax)
    for j = 1:length(res)
        for k = 1:length(shortwhd)
            for routenum = 1:2
                [imxi,imyi,heads,whsn,err,nearest,dist,snx,sny,snth,errsel,p] = g_imdb_route_geterrs(shortwhd{k},routenum,res(j),useinfomax(i),false);                
                
                means(i,j,k) = mean(err(errsel));
                stds(i,j,k) = std(err(errsel));
            end
        end
    end
end

showstats('useinfomax', useinfomax, means, stds, 1);
showstats('res', res, means, stds, 2);

labels = cell(size(shortwhd));
for i = 1:length(labels)
    labels{i} = g_imdb_getlabel(fullfile(g_dir_imdb, shortwhd{i}));
end
showstats('arena', labels, means, stds, 3);

fprintf('INFOMAX ONLY\n')
inf_means = means(useinfomax,:,:);
inf_stds = stds(useinfomax,:,:);
showstats('res', res, inf_means, inf_stds, 2);
showstats('arena', labels, inf_means, inf_stds, 3);

fprintf('PERFECT MEMORY ONLY\n')
pm_means = means(~useinfomax,:,:);
pm_stds = means(~useinfomax,:,:);
showstats('res', res, pm_means, pm_stds, 2);
showstats('arena', labels, pm_means, pm_stds, 3);

for i = 1:length(labels)
    fprintf('%s ONLY\n', upper(labels{i}))
    cmeans = means(:,:,i);
    cstds = stds(:,:,i);
    showstats('useinfomax', useinfomax, cmeans, cstds, 1);
    showstats('res', res, cmeans, cstds, 2);
end

function showstats(str, labels, means, stds, dim)
fprintf('by %s:\n', str);

avdims = 1:ndims(means);
avdims = avdims(avdims ~= dim);
for i = 1:length(avdims)
    means = mean(means,avdims(i));
    stds = mean(stds,avdims(i));
end
means = shiftdim(means);
stds = shiftdim(stds);

for i = 1:length(labels)
    if iscell(labels)
        lab = labels{i};
    else
        lab = num2str(labels(i));
    end
    fprintf('- %s: %g (+-%g)\n', lab, means(i), stds(i));
end

fprintf('\n')
