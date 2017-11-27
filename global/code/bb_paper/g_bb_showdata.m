function g_bb_showdata(shortwhd,routenums,zht,snapszht,userealsnaps,useinfomax,improc,plotquiver,plotwhsn,dosave,doseparateplots)
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
if nargin < 8 || isempty(plotquiver)
    plotquiver = true;
end
if nargin < 9 || isempty(plotwhsn)
    plotwhsn = false;
end
if nargin < 10 || isempty(dosave)
    dosave = false;
end
if nargin < 11 || isempty(doseparateplots)
    doseparateplots = true;
end

newonly = false;
forcegen = false;
dosavefigdata = ~forcegen;

res = 90;

spcols = ceil(length(zht)/2);

if isempty(improc)
    improcstr = '';
else
    improcstr = [improc,'_'];
end

for i = 1:length(useinfomax)
    if useinfomax(i)
        algorithmstr = 'infomax';
    else
        algorithmstr = 'pm';
    end
    for cres = res
        for j = 1:length(shortwhd)
            whd = fullfile(g_dir_imdb,shortwhd{j});
            flabel = g_imdb_getlabel(whd);
            for routenum = routenums
                if dosave
                    g_fig_series_start
                end
                for k = 1:length(snapszht)
                    for m = 1:length(zht)
                        [imxi,imyi,heads,whsn,~,~,~,snx,sny,~,errsel,p, ...
                            isnew,~,~,snapszht(k)] = g_imdb_route_getdata( ...
                                shortwhd{j},routenum,cres,zht(m), ...
                                useinfomax(i),improc,forcegen,[], ...
                                userealsnaps,snapszht(k),dosavefigdata);
                        
                        if newonly && ~isnew
                            continue
                        end
                        
                        if useinfomax(i)
                            methodstr = 'infomax';
                        else
                            methodstr = 'ridf';
                        end
                        if doseparateplots
                            tstr = sprintf('(route %d, res %d, ht %d, snapht %d, %s)', ...
                                routenum, cres, zht(m), snapszht(k), methodstr);
                        else
                            tstr = sprintf('Height: %d mm',zht(m)+50);
                        end
                        
                        if plotquiver
                            if doseparateplots
                                figure(1);clf
                            else
                                figure(sub2ind([length(useinfomax),length(snapszht),max(routenums)],i,k,routenum))
                                subplot(min(2,length(zht)),spcols,m)
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
                            
                            if dosave && doseparateplots
                                if useinfomax(i)
                                    algorithmstr = 'infomax';
                                else
                                    algorithmstr = 'pm';
                                end
                                g_fig_save(sprintf('%s%s_%s_route%d_res%03d_z%d_quiver%s',improcstr,algorithmstr,flabel,routenum,cres,zht(m)),[10 10]);
                            end
                        end
                        
                        if ~useinfomax(i) && plotwhsn
                            if doseparateplots
                                figure(2);clf
                            else
                                figure(100+sub2ind([length(useinfomax),length(snapszht),max(routenums)],i,k,routenum))
                                subplot(min(2,length(zht)),spcols,m)
                            end
                            
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
                            axis equal tight
                            
                            if zht(m)==snapszht(k)
                                title(tstr,'Color','r')
                            else
                                title(tstr)
                            end
                            g_fig_setfont
                            
                            colorbar
                            
                            if dosave && doseparateplots
                                if isempty(improc)
                                    improcstr = '';
                                else
                                    improcstr = [improc,'_'];
                                end
                                g_fig_save(sprintf('%s%s_%s_route%d_res%03d_z%d_quiver%s',improcstr,algorithmstr,flabel,routenum,cres,zht(m)),[10 10]);
                            end
                        end
                    end
                end
                if dosave
                    plotstr = '';
                    if plotquiver
                        plotstr = [plotstr 'quiver']; %#ok<AGROW>
                    end
                    if plotwhsn
                        plotstr = [plotstr 'whsn']; %#ok<AGROW>
                    end
                    
                    fname = sprintf('%s_%s_route%d_%s%s_res%03d.pdf',plotstr,flabel,routenum,improcstr,algorithmstr,cres);
                    if ~doseparateplots
                        g_fig_save(fname);
                    end
                    g_fig_series_end(fname);
                end
            end
        end
    end
end
