function g_bb_boxplot(shortwhd,routenums,zht,snapszht,userealsnaps,useinfomax,improc,dosave,doseparateplots)
close all

if nargin < 1 || isempty(shortwhd)
    shortwhd={
        'imdb_2017-02-09_001'  % open, pile
%         'imdb_2016-03-29_001' % open, boxes
%         'imdb_2016-02-08_003' % closed, boxes (z=250mm)
%         'imdb_2017-06-06_001' % closed, plants
        };
elseif ~iscell(shortwhd)
    shortwhd = {shortwhd};
end
if nargin < 2 || isempty(routenums)
    routenums = 1;
end
if nargin < 3 || isempty(zht)
    zht = 0:100:500;
end
if nargin < 4 || isempty(snapszht)
    snapszht = 0:100:500;
end
if nargin < 5 || isempty(userealsnaps)
    userealsnaps = false;
end
if nargin < 6 || isempty(useinfomax)
    useinfomax = false;
end
if nargin < 7 || isempty(improc)
    improc = '';
end
if nargin < 8 || isempty(dosave)
    dosave = false;
end
if nargin < 9 || isempty(doseparateplots)
    doseparateplots = true;
end

improcforinfomax = false;
res = 90;
forcegen = false;
spcols = ceil(length(snapszht)/2);

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
end

if any(~useinfomax)
    disp('Plotting perfect memory results...')
    
    % plot perfect memory results
    for m = 1:length(routenums)
        if dosave && doseparateplots
            g_fig_series_start
        end
        for l = 1:length(snapszht)
            if doseparateplots
                figure(1);clf
            else
                figure(m)
                subplot(min(2,length(snapszht)),spcols,l)
            end
            
            doboxplot(errs(~useinfomax,:,:,l,m,:),zht,mod(l-1,ceil(length(snapszht)/2)));
            title(sprintf('Train height: %d mm',snapszht(l)+50));
            g_fig_setfont
            
            if dosave && doseparateplots
                g_fig_save(sprintf('boxplot_%s_%s%sres%03d_route%03d_snapszht%03d',flabel,improc,'pm_',res,routenums(m),snapszht(l)),[20 10]);
            end
        end
    end
    if dosave
        if doseparateplots
            g_fig_series_end(sprintf('boxplot_%s_pm_%sres%03d.pdf',flabel,improc,res))
        else
            g_fig_save(sprintf('boxplot_%s_pm_%sres%03d.pdf',flabel,improc,res),[20 15])
        end
    end
end

if any(useinfomax)
    disp('Plotting infomax results...')
    
    % plot infomax results
    for m = 1:length(routenums)
        if dosave && doseparateplots
            g_fig_series_start
        end
        for l = 1:length(snapszht)
            if doseparateplots
                figure(2);clf
            else
                figure(100+m)
                subplot(min(2,length(snapszht)),spcols,l)
            end
            
            doboxplot(errs(useinfomax,:,:,l,m,:),zht,mod(l-1,ceil(length(snapszht)/2)));
            title(sprintf('Train height: %d mm',snapszht(l)+50))
            g_fig_setfont
            
            if dosave && doseparateplots
                g_fig_save(sprintf('boxplot_%s_%s%sres%03d_route%03d_snapszht%03d',flabel,improc,'infomax_',res,routenums(m),snapszht(l)),[20 10]);
            end
        end
        if dosave
            if doseparateplots
                g_fig_series_end(sprintf('boxplot_%s_infomax_%sres%03d.pdf',flabel,improc,res))
            else
                g_fig_save(sprintf('boxplot_%s_infomax_%sres%03d.pdf',flabel,improc,res),[20 15])
            end
        end
    end
end

function doboxplot(errs,zht,hidey)
hold on
for i = 1:numel(errs)
    boxplot(errs{i},'Positions',i);
end

xlim([0 i+1])
set(gca,'XTick',1:i,'XTickLabel',zht+50)
xlabel('Test height (mm)')

ylim([0 90])
if hidey
    set(gca,'YTick',[])
else
    set(gca,'YTick',0:15:90)
    ylabel('Error (deg)')
end
