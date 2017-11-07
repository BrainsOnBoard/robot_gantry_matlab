function g_bb_boxplot(dosave,shortwhd,routenums,improc)
if nargin < 4 || isempty(improc)
    improc = '';
end
if nargin < 3 || isempty(routenums)
    routenums = 3;
end
if nargin < 2 || isempty(shortwhd)
%     [~,shortwhd] = g_imdb_choosedb;
%     shortwhd = {shortwhd};
    shortwhd = {'imdb_2017-06-06_001'};
elseif ~iscell(shortwhd)
    shortwhd = {shortwhd};
end
if nargin < 1 || isempty(dosave)
    dosave = false;
end

useinfomax = [false true];
improcforinfomax = false;
res = 90;
zht = 0:100:500;
forcegen = false;

errs = cell(length(useinfomax),length(res),length(shortwhd),length(routenums),length(zht));

for i = 1:length(useinfomax)
    for j = 1:length(res)
        for k = 1:length(shortwhd)
            for l = 1:length(routenums)
                for m = 1:length(zht)
                    [imxi,imyi,heads,whsn,err,nearest,dist,snx,sny,snth,errsel,p,isnew] = g_imdb_route_getdata(shortwhd{k},'arena2_pile',routenums(l),res(j),zht(m),useinfomax(i),improc,forcegen,improcforinfomax);
                    
                    errs{i,j,k,l,m} = err(errsel);
                end
            end
        end
    end
end

figure(1);clf
subplot(2,1,1)
doboxplot(errs(1,:,:,:,:),zht);
title('Perfect memory')

subplot(2,1,2)
doboxplot(errs(2,:,:,:,:),zht);
title('Infomax')

if dosave
    if ~empty(improc)
        improc(end+1) = '_';
    end
    g_fig_save(['boxplot_',improc,'pm_inf_height'],[20 10]);
end

function doboxplot(errs,zht)
hold on
for i = 1:numel(errs)
    boxplot(errs{i},'Positions',i);
end

xlim([0 i+1])
set(gca,'XTick',1:i,'XTickLabel',zht+50)
ylim([0 90])
set(gca,'YTick',0:15:90)

xlabel('Test height (mm)')
ylabel('Error (deg)')
g_fig_setfont
