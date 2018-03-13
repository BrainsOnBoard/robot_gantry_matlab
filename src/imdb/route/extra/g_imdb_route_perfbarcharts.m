function g_imdb_route_perfbarcharts

useinfomax = [false true];
res = [90 180 360];
shortwhd={
    'imdb_2017-02-09_001'      % open, new boxes
    'imdb_2016-03-23_001', ... % open, empty
    };
zht = 0:100:500;
[stderrs,means] = deal(NaN(length(useinfomax),length(res),length(shortwhd),2,length(zht)));

for i = 1:length(useinfomax)
    for j = 1:length(res)
        for k = 1:length(shortwhd)
            for routenum = 1:2
                for l = 1:length(zht)
                    [imxi,imyi,heads,whsn,err,nearest,dist,snx,sny,snth,errsel,p] = g_imdb_route_geterrs(shortwhd{k},routenum,res(j),zht(l),useinfomax(i),false);
                    
                    means(i,j,k,routenum,l) = mean(err(errsel));
                    stderrs(i,j,k,routenum,l) = stderr(err(errsel));
                end
            end
        end
    end
end

%%
close all

titles = {'Algorithm','Resolution','Environment','Route','Height (mm)'};
labels = cell(1,3);

labels{1} = {'Perfect memory','Infomax'};

labels{2} = cell(size(res));
for i = 1:length(res)
    labels{2}{i} = num2str(res(i));
end

labels{3} = cell(size(shortwhd));
for i = 1:length(labels{3})
    labels{3}{i} = g_imdb_getlabel(shortwhd{i});
end

labels{4} = {'1', '2'};

labels{5} = cell(size(zht));
for i = 1:length(zht)
    labels{5}{i} = num2str(zht(i));
end

showstats(1)
showstats(2)
showstats(3)
showstats(4)
showstats(5)

pm_title = 'Perfect memory only';
pm_means = means(~useinfomax,:,:,:,:);
pm_stds = means(~useinfomax,:,:,:,:);
showstats(2,pm_means,pm_stds,pm_title)
showstats(3,pm_means,pm_stds,pm_title)
showstats(4,pm_means,pm_stds,pm_title)
showstats(5,pm_means,pm_stds,pm_title)

inf_title = 'Infomax only';
inf_means = means(useinfomax,:,:,:,:);
inf_stds = stderrs(useinfomax,:,:,:,:);
showstats(2,inf_means,inf_stds,inf_title)
showstats(3,inf_means,inf_stds,inf_title)
showstats(4,inf_means,inf_stds,inf_title)
showstats(5,inf_means,inf_stds,inf_title)

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
            cstds = stderrs;
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
        barerr(cmeans,[])
        
        ylabel('Error')
        ylim([0 90])
        
        set(gca,'XTick',1:length(cmeans),'XTickLabel',labels{dim})
        xlabel(titles{dim})
        
        if nargin >=4
            title(ctitle)
        end
        
        g_fig_setfont
    end
end