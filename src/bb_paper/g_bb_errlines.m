function g_bb_errlines(shortwhd,routenums,zht,snapszht,userealsnaps, ...
    useinfomax,improc,dosave,figtype,useiqr,ymax)
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
if nargin < 9 || isempty(figtype)
    figtype = 'pdf';
end
if nargin < 10 || isempty(useiqr)
    useiqr = false;
end
if nargin < 11 || isempty(ymax)
    ymax = 90*ones(size(useinfomax));
end

improcforinfomax = false;
res = 90;
forcegen = false;
figsz = [15 5];

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
    flabel = g_imdb_getlabel(shortwhd{1});
end

figure(2);clf
if any(~useinfomax)
    if length(useinfomax) > 1
        subplot(2,1,1)
    end
    errlines('pm','Perfect memory',shiftdim(errs(~useinfomax,:,:,:,:,:),1), ...
        ymax(~useinfomax))
end

if any(useinfomax)
    if length(useinfomax) > 1
        subplot(2,1,2)
    end
    errlines('infomax','Infomax',shiftdim(errs(useinfomax,:,:,:,:,:),1), ...
        ymax(useinfomax))
end

iqrstr = '';
if useiqr
    iqrstr = 'iqr_';
end

g_fig_save(sprintf('errlines_%s_%s%sres%03d',flabel,iqrstr,improc,res), ...
    [1 length(useinfomax)] .* figsz,figtype);

    function errlines(name,ttl,cerrs,cymax)
        fprintf('Plotting %s results...\n',name)
        for routenumi = 1:length(routenums)
            for csnapszhti = 1:length(snapszht)
                doerrlines(cerrs(:,:,csnapszhti,routenumi,:),zht, ...
                    useiqr,cymax);
                hold on
                g_fig_setfont
            end
            hleg = legend(num2str((snapszht+50)'), ...
                'Location','bestoutside');
            title(hleg,'Height (mm)')
            title(ttl)
        end
    end
end

function doerrlines(errs,zht,useiqr,ymax)
errs = shiftdim(errs)';
zht = zht+50;

if useiqr
    med = cellfun(@median,errs);
    lower = cellfun(@(x)prctile(x,25),errs)-med;
    upper = cellfun(@(x)prctile(x,75),errs)-med;
    errorbar(zht,med,lower,upper);
else
    means = cellfun(@mean,errs);
    stderrs = cellfun(@stderr,errs);
    errorbar(zht,means,stderrs);
end

set(gca,'XTick',zht)
xlabel('Test height (mm)')
if ~isnan(ymax)
    ylim([0 ymax])
end
set(gca,'YTick',0:15:90)
ylabel('Error (deg)')

andy_setbox
end
