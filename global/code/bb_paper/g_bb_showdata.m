function g_bb_showdata(dosave,useinfomax,improc,shortwhd,zht,userealsnaps,snapszht,plotquiver,plotwhsn)
close all

if nargin < 1 || isempty(dosave)
    dosave = false;
end
if nargin < 2 || isempty(useinfomax)
    useinfomax = false;
end
if nargin < 3 || isempty(improc)
    improc = '';
end
if nargin < 4 || isempty(shortwhd)
    shortwhd={
        'imdb_2017-02-09_001' % open, pile
%         'imdb_2016-03-23_001' % open, empty
%         'imdb_2016-03-29_001' % open, boxes
%         'imdb_2017-06-06_001' % closed, plants
        };
%     [~,shortwhd] = g_imdb_choosedb;
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
if nargin < 8 || isempty(plotquiver)
    plotquiver = true;
end
if nargin < 9 || isempty(plotwhsn)
    plotwhsn = false;
end

newonly = false;
forcegen = false;
dosavefigdata = ~forcegen;

res = 90;
routenums = 3;
% routenums = 1;

arenafn = 'arena2_pile';
% arenafn = 'arena1_boxes';
% arenafn = 'arena_plants';

spcols = ceil(length(zht)/2);

for i = 1:length(useinfomax)
    for cres = res
        for j = 1:length(shortwhd)
            for routenum = routenums
                for k = 1:length(snapszht)
                    for m = 1:length(zht)
                        [imxi,imyi,heads,whsn,err,nearest,dist,snx,sny,snth,errsel,p,isnew,~,~,snapszht(k)] = g_imdb_route_getdata(shortwhd{j},arenafn,routenum,cres,zht(m),useinfomax(i),improc,forcegen,[],userealsnaps,snapszht(k),dosavefigdata);
                        
                        if newonly && ~isnew
                            continue
                        end
                        
                        whd = fullfile(g_dir_imdb,shortwhd{j});
                        flabel = g_imdb_getlabel(whd);
                        if useinfomax(i)
                            methodstr = 'infomax';
                        else
                            methodstr = 'ridf';
                        end
                        tstr = sprintf('%s (route %d, res %d, ht %d, %s)', flabel, routenum, cres, zht(m), methodstr);
                        
                        if plotquiver
                            if dosave
                                figure(1);clf
                            else
                                figure((i-1)*length(snapszht)+k)
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
                        
                        if ~useinfomax(i) && plotwhsn
                            figure(10*length(snapszht)+k)
                            subplot(2,spcols,m)
                            
                            whsnim = makeim(imxi,imyi,whsn,length(p.xs),length(p.ys));
                            whsnim(isnan(whsnim)) = 0;
                            imagesc(whsnim)
                            hot2 = [0,0,1; hot];
                            colormap(hot2)
                            hold on
                            
                            snxi = round(1+(snx/p.imsep));
                            snyi = round(1+(sny/p.imsep));
                            plot(snxi,snyi,'g.')
                            
                            for n = 1:length(snxi)
                                matched = whsnim(snyi(n),snxi(n));
                                if matched~=n
                                    fprintf('expected: %d; matched: %d\n',n,matched)
                                    if snapszht(k)==zht(m)
                                        col = 'g';
                                    else
                                        col = 'b';
                                    end
                                    line(snxi(n)+[-.5 .5 .5 -.5 -.5],snyi(n)+[-.5 -.5 .5 .5 -.5],'Color',col)
                                end
                            end
                            
                            set(gca,'YDir','normal')
                            
                            if zht(m)==snapszht(k)
                                title(tstr,'Color','r')
                            else
                                title(tstr)
                            end
                            g_fig_setfont
                            
                            colorbar
                        end
                    end
                end
            end
        end
    end
end