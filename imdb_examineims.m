
clear

whd = imdb_choosedb_unwrap;
load(fullfile(whd,'im_params.mat'))

[x,y] = meshgrid(p.xs,p.ys);

fex = false(length(p.ys),length(p.xs));
for xi = 1:length(p.xs)
    for yi = 1:length(p.ys)
        fex(yi,xi) = exist(fullfile(whd,sprintf('im_%03d_%03d.mat',yi,xi)),'file');
    end
end

curx = 1;
cury = 1;
while true
    figure(5);clf
    subplot(2,1,2)
    if fex(cury,curx)
        load(fullfile(whd,sprintf('im_%03d_%03d.mat',cury,curx)));
        imshow(fr)
    end
    
    subplot(2,1,1)
    xlim([0 p.lim(1)])
    ylim([0 p.lim(2)]) 
    hold on
    
    plot(x(fex),y(fex),'g+')
    plot(x(~fex),y(~fex),'r+')
    plot(p.xs(curx),p.ys(cury),'bo','LineWidth',4,'MarkerSize',10)
    
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
                yadd = find(fex(cury+1:end,curx),1);
                if ~isempty(yadd)
                    cury = cury+yadd;
                end
            case 31 % down
                newy = find(fex(1:cury-1,curx),1,'last');
                if ~isempty(newy)
                    cury = newy;
                end
            case 28 % left
                newx = find(fex(cury,1:curx-1),1,'last');
                if ~isempty(newx)
                    curx = newx;
                end
            case 29 % right
                xadd = find(fex(cury,curx+1:end),1);
                if ~isempty(xadd)
                    curx = curx+xadd;
                end
        end
    end
end