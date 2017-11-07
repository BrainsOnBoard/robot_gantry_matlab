function g_bb_bar(dosave,shortwhd,routenums,improc)
if nargin < 4 || isempty(improc)
    improc = '';
end
if nargin < 3 || isempty(routenums)
    routenums = 1;
end
if nargin < 2 || isempty(shortwhd)
    [~,shortwhd] = g_imdb_choosedb;
    shortwhd = {shortwhd};
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

[stderrs,means] = deal(NaN(length(useinfomax),length(res),length(shortwhd),length(routenums),length(zht)));

for i = 1:length(useinfomax)
    for j = 1:length(res)
        for k = 1:length(shortwhd)
            for l = 1:length(routenums)
                for m = 1:length(zht)
                    [~,~,~,~,err,~,~,~,~,~,errsel] = g_imdb_route_getdata( ...
                        shortwhd{k},routenums(l),res(j),zht(m), ...
                        useinfomax(i),improc,forcegen,improcforinfomax, ...
                        userealsnaps, snapszht);
                    
                    means(i,j,k,l,m) = mean(err(errsel));
                    stderrs(i,j,k,l,m) = stderr(err(errsel));
                end
            end
        end
    end
end

figure(1);clf
cmeans = squeeze(means)';
h = bar(zht+50, cmeans);
h(1).FaceColor = 'w';
h(2).FaceColor = 'k';
legend({'Perfect memory','Infomax'},'Location','northwest')
xlabel('Test height (mm)')
ylabel('Error (deg)')
g_fig_setfont

if dosave
    if ~empty(improc)
        improc(end+1) = '_';
    end
    g_fig_save([improc,'pm_inf_height'],[20 10]);
end