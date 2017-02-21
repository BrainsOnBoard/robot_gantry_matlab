

clear
close all

forcegen = false;

res = 360;
shortwhd='unwrap_imdb3d_2017-02-09_001';      % open, new boxes
whd = fullfile(imdbdir,shortwhd);
zht = 200; %:100:500; % +50mm
routenum = 3;

arenafn = 'arena2_pile';

crop = load('gantry_cropparams.mat');

[imxi,imyi,heads,whsn,err,nearest,dist,snx,sny,snth,errsel,p,fileexists,allwhsn,ridfs] = imdb_route_getrealsnapserrs3d_debug(shortwhd,arenafn,routenum,res,zht,false,forcegen);

[whsnim,nearim] = deal(NaN(length(p.ys),length(p.xs)));
whsnim(sub2ind(size(whsnim),imyi,imxi)) = whsn;
nearim(sub2ind(size(nearim),imyi,imxi)) = nearest;

snaps = imdb_route_getrealsnaps3d(arenafn,routenum,res);
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
    subplot(4,1,4)
    hold on
    callwhsn = allwhsn(imyi==y & imxi==x, :);
    bm = callwhsn(1:3);
    near = nearim(y,x);
    title(sprintf('(%g, %g), s(%g, %g) [nearest: %d (r%d)]', p.xs(x), p.ys(y), p.imsep*(snxi(near)-1), p.imsep*(snyi(near)-1), near, find(callwhsn==near)))
    toplot = [bm, near];
    plot(0:359, shiftdim(maxval \ ridfs(y,x,:,toplot)));
    legend(num2str(toplot(:)))
    xlim([0 359])
%     ylim([0 1])

    subplot(4,1,1)
    im = imdb_getim3d(whd,x,y,z,crop);
    imshow(imresize(im,imsz))
    title('image')
    
    subplot(4,1,2)
    imshow(snaps(:,:,near));
    title('nearest')
    
    subplot(4,1,3)
    imshow(snaps(:,:,bm(1)));
    title('best matching')
end
