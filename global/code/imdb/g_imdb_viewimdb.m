function g_imdb_viewimdb
% Allows the user to view an image database interactively. Views can be
% cycled through with keypresses.

[fex,p,whd] = g_imdb_imexist;

[x,y] = ndgrid(p.xs,p.ys);

curx = 1;
cury = 1;
curz = 1;
while true
    figure(5);clf
    subplot(2,1,2)
    if fex(curx,cury,curz)
        fr = imread(fullfile(whd,sprintf('im_%03d_%03d_%03d.png',curx,cury,curz)));
        imagesc(fr)
        colormap gray
        axis equal tight
        grid on
        title('press "w" to increase height and "s" to decrease')
    end
    
    subplot(2,1,1)
    xlim([0 p.lim(1)])
    ylim([0 p.lim(2)]) 
    hold on
    
    cfex = fex(:,:,curz);
    
    plot(x(cfex),y(cfex),'g+')
    plot(x(~cfex),y(~cfex),'r+')
    plot(p.xs(curx),p.ys(cury),'bo','LineWidth',4,'MarkerSize',10)
    
    title(sprintf('z = %g mm',p.zs(curz)))
    
    try
        [gx,gy,gbut] = ginput(1);
    catch
        return
    end
    if isempty(gbut)
        break;
    else
        switch gbut
            case 1 % mouseclick
                [~,curx] = min(abs(gx-p.xs));
                [~,cury] = min(abs(gy-p.ys));
            case 30 % up
                yadd = find(cfex(curx,cury+1:end),1);
                if ~isempty(yadd)
                    cury = cury+yadd;
                end
            case 31 % down
                newy = find(cfex(curx,1:cury-1),1,'last');
                if ~isempty(newy)
                    cury = newy;
                end
            case 28 % left
                newx = find(cfex(1:curx-1,cury),1,'last');
                if ~isempty(newx)
                    curx = newx;
                end
            case 29 % right
                xadd = find(cfex(curx+1:end,cury),1);
                if ~isempty(xadd)
                    curx = curx+xadd;
                end
            case 'w'+0
                curz = min(length(p.zs),curz+1);
            case 's'+0
                curz = max(1,curz-1);
        end
    end
end