function imdb_route_perfbarcharts

useinfomax = [false true];
res = [90 180 360];
shortwhd={
    'unwrap_imdb_2016-02-04_002', ... % empty, open
    'unwrap_imdb_2016-02-09_002', ... % empty, closed
    'unwrap_imdb_2016-02-09_001', ... % boxes, open
    'unwrap_imdb_2016-02-05_001'      % boxes, closed
    };
[stds,means] = deal(NaN(length(useinfomax),length(res),length(shortwhd),2));

for i = 1:length(useinfomax)
    for j = 1:length(res)
        for k = 1:length(shortwhd)
            for routenum = 1:2
                [imxi,imyi,heads,whsn,err,nearest,dist,snx,sny,snth,errsel,p] = imdb_route_geterrs(shortwhd{k},routenum,res(j),useinfomax(i),false);
                
                means(i,j,k,routenum) = mean(err(errsel));
                stds(i,j,k,routenum) = std(err(errsel));
            end
        end
    end
end

%%
close all

titles = {'Algorithm','Resolution','Environment','Route'};
labels = cell(1,3);

labels{1} = {'Perfect memory', 'Infomax'};

labels{2} = cell(size(res));
for i = 1:length(res)
    labels{2}{i} = num2str(res(i));
end

labels{3} = cell(size(shortwhd));
for i = 1:length(labels{3})
    labels{3}{i} = imdb_getlabel(fullfile(imdbdir, shortwhd{i}));
end

labels{4} = {'1', '2'};

showstats(1)
showstats(2)
showstats(3)
showstats(4)

pm_title = 'Perfect memory only';
pm_means = means(~useinfomax,:,:,:);
pm_stds = means(~useinfomax,:,:,:);
showstats(2,pm_means,pm_stds,pm_title)
showstats(3,pm_means,pm_stds,pm_title)
showstats(4,pm_means,pm_stds,pm_title)

inf_title = 'Infomax only';
inf_means = means(useinfomax,:,:,:);
inf_stds = stds(useinfomax,:,:,:);
showstats(2,inf_means,inf_stds,inf_title)
showstats(3,inf_means,inf_stds,inf_title)
showstats(4,inf_means,inf_stds,inf_title)

% for i = 1:length(labels)
%     fprintf('%s ONLY\n', upper(labels{i}))
%     cmeans = means(:,:,i);
%     cstds = stds(:,:,i);
%     showstats('useinfomax', useinfomax, cmeans, cstds, 1);
%     showstats('res', res, cmeans, cstds, 2);
% end

    function showstats(dim,cmeans,cstds,ctitle)
        if nargin < 2
            cmeans = means;
            cstds = stds;
        end
        
        avdims = 1:ndims(cmeans);
        avdims = avdims(avdims ~= dim);
        for avdimsi = 1:length(avdims)
            cmeans = mean(cmeans,avdims(avdimsi));
            cstds = mean(cstds,avdims(avdimsi));
        end
        cmeans = shiftdim(cmeans);
        cstds = shiftdim(cstds);
        
        figure
        barerr(cmeans,cstds)
        
        ylabel('Error')
        ylim([0 100])
        
        set(gca,'XTick',1:length(cmeans),'XTickLabel',labels{dim})
        xlabel(titles{dim})
        
        if nargin >=4
            title(ctitle)
        end
        
        gantry_setfigfont
    end
end