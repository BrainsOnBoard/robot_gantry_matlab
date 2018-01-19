function g_bb_boxplot(shortwhd,routenums,zht,snapszht,userealsnaps,useinfomax,improc,doseparateplots,dosave,figtype)
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
if nargin < 8 || isempty(doseparateplots)
    doseparateplots = true;
end
if nargin < 9 || isempty(dosave)
    dosave = false;
end
if nargin < 10 || isempty(figtype)
    figtype = 'pdf';
end

improcforinfomax = false;
res = 90;
forcegen = false;
sprows = ceil(length(snapszht)/2);
figsz = [18 15];

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

domultiboxplots('pm',shiftdim(errs(~useinfomax,:,:,:,:,:),1))
domultiboxplots('infomax',shiftdim(errs(useinfomax,:,:,:,:,:),1))

    function domultiboxplots(name,cerrs)
        fprintf('Plotting %s results...\n',name)
        spcols = min(2,length(snapszht));
        
        % plot infomax results
        for m = 1:length(routenums)
            ymax = 0;
            if dosave && doseparateplots
                g_fig_series_start
            end
            h = NaN(size(snapszht));
            for l = 1:length(snapszht)
                if doseparateplots
                    figure(2);clf
                else
                    figure(100+m)
                    h(l)=subplot(sprows,spcols,l);
                end
                
                ymax = max(ymax,doboxplot(cerrs(:,:,l,m,:),zht));
                title(sprintf('Training height: %d mm',snapszht(l)+50))
                g_fig_setfont
                
                if dosave && doseparateplots
                    g_fig_save(sprintf('boxplot_%s_%s%s_res%03d_route%03d_snapszht%03d', ...
                        flabel,improc,name,res,routenums(m),snapszht(l)), ...
                        [20 10],figtype);
                end
            end
            if dosave
                if doseparateplots
                    g_fig_series_end(sprintf('boxplot_%s_%s%s_res%03d.pdf',flabel,improc,name,res))
                else
                    ymax = 15*ceil(ymax/15); % round to nearest 15
                    set(h, 'YLim', [0 min(90,ymax)]);
                    g_fig_save(sprintf('boxplot_%s_%s%s_res%03d',flabel,improc,name,res),figsz,figtype,[],[],false)
                end
            end
        end
    end
end

function ymax=doboxplot(errs,zht)
ymax = 0;
hold on
for i = 1:numel(errs)
    h = boxplot(errs{i},'Positions',i);
    yupper = get(h(1),'YData'); % upper whisker
    ymax = max(yupper(2),ymax);
end

xlim([0 i+1])
set(gca,'XTick',1:i,'XTickLabel',zht+50)
xlabel('Test height (mm)')

ylim([0 ymax])
% ylim([0 30])
set(gca,'YTick',0:15:90)
ylabel('Error (deg)')

andy_setbox
end
