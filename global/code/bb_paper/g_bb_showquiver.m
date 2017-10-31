function g_bb_showquiver(dosave,useinfomax,improc,shortwhd,zht,userealsnaps,snapszht)
close all

if nargin < 1 || isempty(dosave)
    dosave = false;
end
if nargin < 2 || isempty(useinfomax)
    useinfomax = [false true];
end
if nargin < 3 || isempty(improc)
    improc = '';
end
if nargin < 4 || isempty(shortwhd)
    shortwhd={
        'imdb_2017-02-09_001' % open, pile
%         'imdb_2016-03-23_001' % open, empty
%         'imdb_2016-03-29_001' % open, boxes
    };
elseif ~iscell(shortwhd)
    shortwhd = {shortwhd};
end
if nargin < 5 || isempty(zht)
    zht = 0:100:500;
end
if nargin < 6 || isempty(userealsnaps)
    userealsnaps = false;
end
if nargin < 7 || isempty(snapszht)
    snapszht = 200;
end

newonly = false;
forcegen = false;
dosavefigdata = ~forcegen;

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
    for cres = res
        for j = 1:length(shortwhd)
            for routenum = routenums
                for k = 1:length(snapszht)
                    if ~dosave
                        figure((i-1)*length(snapszht)+k);clf
                    end
                    for m = 1:length(zht)
                        [imxi,imyi,heads,whsn,err,nearest,dist,snx,sny,snth,errsel,p,isnew,~,~,snapszht(k)] = g_imdb_route_getdata(shortwhd{j},arenafn,routenum,cres,zht(m),useinfomax(i),improc,forcegen,[],userealsnaps,snapszht(k),dosavefigdata);
                        
                        if newonly && ~isnew
                            continue
                        end
                        
                        whd = fullfile(g_dir_imdb,shortwhd{j});
                        flabel = g_imdb_getlabel(whd);
                        
                        if dosave
                            figure(1);clf
                        else
                            subplot(2,spcols,m)
                        end
                        hold on
                        
                        if ~isempty(p.arenafn)
                            objverts=g_arena_load(p.arenafn);
                            g_fig_drawobjverts(objverts,[],'k')
                        end
                        
                        anglequiver(p.xs(imxi(~errsel)),p.ys(imyi(~errsel)),heads(~errsel));
                        anglequiver(p.xs(imxi(errsel)),p.ys(imyi(errsel)),heads(errsel),[],'g')
                        plot(snx,sny,'ro')
                        axis equal tight
                        xlabel('x (mm)')
                        ylabel('y (mm)')
                        if useinfomax(i)
                            methodstr = 'infomax';
                        else
                            methodstr = 'ridf';
                        end
                        tstr = sprintf('%s (route %d, res %d, ht %d, %s)', flabel, routenum, cres, zht(m), methodstr);
                        if zht(m)==snapszht(k)
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
                            g_fig_save(sprintf('%s%s_%s_route%d_res%03d_z%d_ridf_quiver%s',improcstr,algorithmstr,flabel,routenum,cres,zht(m)),[10 10]);
                        end
                    end
                end
            end
        end
    end
end