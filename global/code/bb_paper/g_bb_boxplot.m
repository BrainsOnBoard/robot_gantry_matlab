function g_bb_boxplot(dosave,shortwhd,routenums,improc)
if nargin < 4 || isempty(improc)
    improc = '';
end
if nargin < 3 || isempty(routenums)
    routenums = 1;
end
if nargin < 2 || isempty(shortwhd)
    shortwhd = {
        'imdb_2017-06-06_001' % closed, plants
        };
elseif ~iscell(shortwhd)
    shortwhd = {shortwhd};
end
if nargin < 1 || isempty(dosave)
    dosave = false;
end

useinfomax = [false true];
userealsnaps = false;
snapszht = 200;
improcforinfomax = false;
res = 90;
zht = 0:100:500;
forcegen = false;

errs = cell(length(useinfomax),length(res),length(shortwhd), ...
    length(snapszht),length(routenums),length(zht));

for i = 1:length(useinfomax)
    for j = 1:length(res)
        for k = 1:length(shortwhd)
            for l = 1:length(snapszht)
                for m = 1:length(routenums)
                    for n = 1:length(zht)
                        [~,~,~,~,err,~,~,~,~,~,errsel] = g_imdb_route_getdata( ...
                            shortwhd{k},routenums(m),res(j),zht(n), ...
                            useinfomax(i),improc,forcegen,improcforinfomax, ...
                            userealsnaps,snapszht(l));

                        errs{i,j,k,l,m,n} = err(errsel);
                    end
                end
            end
        end
    end
end

if dosave
    if ~isempty(improc)
        improc(end+1) = '_';
    end
    flabel = g_imdb_getlabel(fullfile(g_dir_imdb,shortwhd{1}));
    
    g_fig_series_start
end
for m = 1:length(routenums)
    for l = 1:length(snapszht)
        if dosave
            figure(1);clf
        else
            figure((l-1)*length(routenums) + m);clf
        end
        if length(useinfomax)==2
            subplot(2,1,1)
        end
        doboxplot(errs(1,:,:,l,m,:),zht);
        title(sprintf('Perfect memory (route %d, snapht %d)',routenums(m),snapszht(l)))
        
        if length(useinfomax)==2
            subplot(2,1,2)
            doboxplot(errs(2,:,:,l,m,:),zht);
            title('Infomax')
        end
        
        if dosave
            g_fig_save(sprintf('boxplot_%s_%sres%03d_route%03d_snapszht%03d',flabel,improc,res,routenums(m),snapszht(l)),[20 10]);
        end
    end
end
if dosave
    g_fig_series_end(sprintf('boxplot_%s_%sres%03d.pdf',flabel,improc,res))
end

function doboxplot(errs,zht)
hold on
for i = 1:numel(errs)
    boxplot(errs{i},'Positions',i);
end

xlim([0 i+1])
set(gca,'XTick',1:i,'XTickLabel',zht+50)
% ylim([0 90])
% set(gca,'YTick',0:15:90)

xlabel('Test height (mm)')
ylabel('Error (deg)')
g_fig_setfont
