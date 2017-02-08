function imdb_route_showstats

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
                [imxi,imyi,heads,whsn,err,nearest,dist,snx,sny,snth,errsel,p] = imdb_route_geterrs(shortwhd{k},routenum,res(j),useinfomax(i),false);                
                
                means(i,j,k) = mean(err(errsel));
                stds(i,j,k) = std(err(errsel));
            end
        end
    end
end

showstats('useinfomax', useinfomax, means, 1);
showstats('res', res, means, 2);

labels = cell(size(shortwhd));
for i = 1:length(labels)
    labels{i} = imdb_getlabel(fullfile(imdbdir, shortwhd{i}));
end
showstats('arena', labels, means, 3);

fprintf('INFOMAX ONLY\n')
inf_means = means(useinfomax, :, :);
showstats('res', res, inf_means, 2);
showstats('arena', labels, inf_means, 3);

fprintf('PERFECT MEMORY ONLY\n')
pm_means = means(~useinfomax, :, :);
showstats('res', res, pm_means, 2);
showstats('arena', labels, pm_means, 3);

for i = 1:length(labels)
    fprintf('%s ONLY\n', upper(labels{i}))
    cmeans = means(:,:,i);
    showstats('useinfomax', useinfomax, cmeans, 1);
    showstats('res', res, pm_means, 2);
end

function showstats(str, labels, means, dim)
fprintf('by %s:\n', str);

avdims = 1:ndims(means);
avdims = avdims(avdims ~= dim);
for i = 1:length(avdims)
    means = mean(means,avdims(i));
end
means = shiftdim(means);

for i = 1:length(labels)
    if iscell(labels)
        lab = labels{i};
    else
        lab = num2str(labels(i));
    end
    fprintf('- %s: %g\n', lab, means(i));
end

fprintf('\n')
