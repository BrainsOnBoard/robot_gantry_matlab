function g_bb_showquiver(dosave,useinfomax,improc,shortwhd,zht)
if nargin < 1
    dosave = false;
end
if nargin < 2
    useinfomax = [false true];
end
if nargin < 3
    improc = '';
end
if nargin < 4
    shortwhd={
        'imdb_2017-02-09_001' % open, pile
%         'imdb_2016-03-23_001' % open, empty
%         'imdb_2016-03-29_001' % open, boxes
    };
elseif ~iscell(shortwhd)
    shortwhd = {shortwhd};
end
if nargin < 5
    zht = 0:100:500;
end

newonly = false;
forcegen = false;

res = 90;
routenums = 3;
% routenums = 1;

arenafn = 'arena2_pile';
% arenafn = 'arena1_boxes';

if ~dosave
    figure(1);clf
    hold on
    spcols = ceil(length(zht)/2);
    subplot(2,spcols,1)
end

for i = 1:length(useinfomax)
    if ~dosave
        figure(i);clf
    end
    for cres = res
        for j = 1:length(shortwhd)
            for routenum = routenums
                for k = 1:length(zht)
                    [imxi,imyi,heads,whsn,err,nearest,dist,snx,sny,snth,errsel,p,isnew,~,~,snapszht] = g_imdb_route_getdata(shortwhd{j},arenafn,routenum,cres,zht(k),useinfomax(i),improc,forcegen);
                    
                    if newonly && ~isnew
                        continue
                    end
                    
                    whd = fullfile(g_dir_imdb,shortwhd{j});
                    flabel = g_imdb_getlabel(whd);
                    
                    if dosave
                        figure(1);clf
                    else
                        subplot(2,spcols,k)
                    end
                    hold on
                    
                    if ~isempty(p.arenafn)
                        objverts=g_arena_load(p.arenafn);
                        g_fig_drawobjverts(objverts,[],'k')
                    end

                    anglequiver(p.xs(imxi(~errsel)),p.ys(imyi(~errsel)),heads(~errsel));
                    anglequiver(p.xs(imxi(errsel)),p.ys(imyi(errsel)),heads(errsel),[],'g')
                    plot(snx*1000/20,sny*1000/20,'ro')
                    axis equal tight
                    xlabel('x (mm)')
                    ylabel('y (mm)')
                    if useinfomax(i)
                        methodstr = 'infomax';
                    else
                        methodstr = 'ridf';
                    end
                    tstr = sprintf('%s (route %d, res %d, ht %d, %s)', flabel, routenum, cres, zht(k), methodstr);
                    if zht(k)==snapszht
                        title(tstr,'Color','r')
                    else
                        title(tstr)
                    end
                    g_fig_setfont
                    
                    if dosave
                        if isempty(improc)
                            improcstr = '';
                        else
                            improcstr = [improc,'_'];
                        end
                        if useinfomax(i)
                            algorithmstr = 'infomax';
                        else
                            algorithmstr = 'pm';
                        end
                        g_fig_save(sprintf('%s%s_%s_route%d_res%03d_z%d_ridf_quiver%s',improcstr,algorithmstr,flabel,routenum,cres,zht(k)),[10 10]);
                    end
                end
            end
        end
    end
end