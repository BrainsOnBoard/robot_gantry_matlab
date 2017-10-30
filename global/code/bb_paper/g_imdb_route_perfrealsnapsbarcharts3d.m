function g_imdb_route_perfrealsnapsbarcharts3d(dosave,improc)
if nargin < 2
    improc = '';
end
if nargin < 1
    dosave = false;
end

useinfomax = [false true];
res = [90 180 360];
shortwhd={
    'imdb_2017-02-09_001'      % open, new boxes
    %'imdb_2016-03-23_001', ... % open, empty
    };
zht = 0:100:500;
routenums = 3;

[stderrs,means] = deal(NaN(length(useinfomax),length(res),length(shortwhd),length(routenums),length(zht)));

for i = 1:length(useinfomax)
    for j = 1:length(res)
        for k = 1:length(shortwhd)
            for l = 1:length(routenums)
                for m = 1:length(zht)
%                     g_imdb_route_getdata(shortwhd{i},'arena2_pile',routenum,cres,czht,useinfomax,false);
                    [imxi,imyi,heads,whsn,err,nearest,dist,snx,sny,snth,errsel,p,isnew] = g_imdb_route_getdata(shortwhd{k},'arena2_pile',routenums(l),res(j),zht(m),useinfomax(i),improc,false);
                    
                    means(i,j,k,l,m) = mean(err(errsel));
                    stderrs(i,j,k,l,m) = stderr(err(errsel));
                end
            end
        end
    end
end

%%
close all

titles = {'Algorithm','Resolution','Environment','Route','Height (mm)'};
labels = cell(1,ndims(means));

labels{1} = {'Perfect memory','Infomax'};

labels{2} = cell(size(res));
for i = 1:length(res)
    labels{2}{i} = num2str(res(i));
end

labels{3} = cell(size(shortwhd));
for i = 1:length(labels{3})
    labels{3}{i} = g_imdb_getlabel(fullfile(g_dir_imdb, shortwhd{i}));
end

labels{4} = {'route label'};

labels{5} = cell(size(zht));
for i = 1:length(zht)
    labels{5}{i} = num2str(zht(i));
end

cattitles = {'Both','Perfect memory','Infomax'};
if isempty(improc)
    improcstr = '';
else
    improcstr = [improc,'_'];
end

showstats(1)
showstats(2)
%showstats(3)
%showstats(4)
showstats(5)

pm_means = means(~useinfomax,:,:,:,:);
pm_stds = means(~useinfomax,:,:,:,:);
showstats(2,pm_means,pm_stds,2)
%showstats(3,pm_means,pm_stds,2)
%showstats(4,pm_means,pm_stds,2)
showstats(5,pm_means,pm_stds,2)

inf_means = means(useinfomax,:,:,:,:);
inf_stds = stderrs(useinfomax,:,:,:,:);
showstats(2,inf_means,inf_stds,3)
%showstats(3,inf_means,inf_stds,3)
%showstats(4,inf_means,inf_stds,3)
showstats(5,inf_means,inf_stds,3)

% for i = 1:length(labels)
%     fprintf('%s ONLY\n', upper(labels{i}))
%     cmeans = means(:,:,i);
%     cstds = stds(:,:,i);
%     showstats('useinfomax', useinfomax, cmeans, cstds, 1);
%     showstats('res', res, cmeans, cstds, 2);
% end

    function showstats(dim,cmeans,cstderrs,whcat)
        if nargin < 4
            whcat = 1;
        end
        if nargin < 2
            cmeans = means;
            cstderrs = stderrs;
        end
        
        cmeans = shiftdim(cmeans,dim-1);
        cstderrs = shiftdim(cstderrs,dim-1);
        cmeans = mean(cmeans(:,:),2);
        cstderrs = mean(cstderrs(:,:),2);
        
        if dosave
            figure(1);clf
        else
            figure
        end
        barerr(cmeans,[])
        
        ylabel('Error')
        ylim([0 90])
        
        set(gca,'XTick',1:length(cmeans),'XTickLabel',labels{dim})
        xlabel(titles{dim})
        
        title(cattitles{whcat})
        
        g_fig_setfont
        
        if dosave
            g_fig_save(sprintf('%s%s_%s',improcstr,cattitles{whcat},titles{dim}),[20 10]);
        end
    end
end