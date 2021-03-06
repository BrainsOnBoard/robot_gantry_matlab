

clear
close all

improc = '';
forcegen = false;

res = 90;
shortwhd='imdb_2017-02-09_001';      % open, new boxes
whd = fullfile(g_dir_imdb,shortwhd);
zht = 200; %:100:500; % +50mm
routenum = 3;

crop = load('gantry_cropparams.mat');
[imxi,imyi,heads,whsn,err,nearest,dist,snx,sny,snth,errsel,p,fileexists,allwhsn,ridfs] = g_imdb_route_getdata(shortwhd,routenum,res,zht,false,improc,forcegen);

[whsnim,nearim] = deal(NaN(length(p.ys),length(p.xs)));
whsnim(sub2ind(size(whsnim),imyi,imxi)) = whsn;
nearim(sub2ind(size(nearim),imyi,imxi)) = nearest;

snaps = g_imdb_route_getrealsnaps(p.arenafn,routenum,res,improc);
imsz = [size(snaps,1), size(snaps,2)];
maxval = prod(imsz) * 255;

snxi = 1 + snx / 2;
snyi = 1 + sny / 2;

figure(1);clf
hold on
imagesc(whsnim);
plot(snxi, snyi, 'b+')
set(gca,'YDir','normal')
axis equal tight
colormap hot
colorbar
title(sprintf('ht: %d',zht))

z = find(p.zs==zht);
while true
    figure(1)
    try
        [x,y,but] = ginput(1);
    catch
        break
    end
    if isempty(x)
        break
    end
    
    x = round(x);
    y = round(y);
    if but ~= 1 || x < 1 || x > length(p.xs) || y < 1 || y > length(p.ys) || isnan(whsnim(y,x))
        continue
    end
    
    figure(2);clf
    alsubplot(4,2,4,[1 2])
    hold on
    sel = imyi==y & imxi==x;
    callwhsn = allwhsn(sel, :);
    bm = callwhsn(1:3);
    near = nearim(y,x);
    title(sprintf('(%g, %g), s(%g, %g) [nearest: %d (r%d)]', p.xs(x), p.ys(y), p.imsep*(snxi(near)-1), p.imsep*(snyi(near)-1), near, find(callwhsn==near)))
    ridfind = [bm, near];
    cridfs = shiftdim(maxval \ ridfs(sel,:,ridfind));
    plot(0:359, cridfs);
    legend(num2str(ridfind(:)))
    xlim([0 359])
%     ylim([0 1])

    [minvals,minima] = min(cridfs(:,[1 end]));

    alsubplot(1,[1 2])
    im = im2double(imresize(g_imdb_getim(whd,x,y,z),imsz));
    imshow(im)
    title('image')
    
    alsubplot(2,1)
    rsnap_near = circshift(snaps(:,:,near),minima(1),2);
    imshow(rsnap_near);
    title('nearest')
    
    alsubplot(2,2)
    imagesc(im - rsnap_near)
    axis off
    title(sprintf('diff: %g',minvals(1)));
    
    alsubplot(3,1)
    rsnap_bm = circshift(snaps(:,:,bm(1)),minima(2),2);
    imshow(rsnap_bm);
    title('best matching')
    
    alsubplot(3,2)
    imagesc(im - rsnap_bm)
    axis off
    title(sprintf('diff: %g',minvals(2)));
    
    colormap gray
end
