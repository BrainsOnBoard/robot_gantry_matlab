function [snaps,clickis,snx,sny,snth,pxsnx,pxsny,pxsnth,crop,p]=imdb_route_getsnaps3d(shortwhd,routenum,zht,res)

imw = 720;

whd = fullfile(g_dir_imdb,shortwhd);

crop = load('gantry_cropparams.mat');
load(fullfile(g_dir_imdb_routes,sprintf('route_%03d.mat',routenum)),'snx','sny','snth');
load(fullfile(whd,'im_params.mat'),'p');
zi = find(p.zs==zht);

[pxsnx,pxsny] = bresenham_xy(snx,sny);

[clickis,~] = find(bsxfun(@eq,pxsnx,snx) & bsxfun(@eq,pxsny,sny));

pxsnth = NaN(size(pxsnx));
for i = 2:length(clickis)
    ind = clickis(i-1):clickis(i)-1;
    pxsnth(ind) = atan2(pxsny(clickis(i))-pxsny(ind),pxsnx(clickis(i))-pxsnx(ind));
end
pxsnth(end) = snth(end);

newimsz = [round((crop.y2 - crop.y1 + 1)*res/imw) res];
snaps = zeros([newimsz,length(pxsnx)],'uint8');

% figure(1);clf
% [gx,gy] = meshgrid(p.xs,p.ys);
% plot(gx,gy,'g.',p.xs(snx),p.ys(sny),p.xs(snx(clickis)),p.xs(sny(clickis)),'ro')

%     figure(1);clf
for i = 1:length(pxsnx)
    csnap = g_imdb_getim(whd,pxsnx(i),pxsny(i),zi,crop);
    snaps(:,:,i) = imresize(circshift(csnap,round(pxsnth(i) * imw / (2*pi)),2),newimsz,'bilinear');
    
    %         ind = 2*(i-1)+1;
    %         subplot(length(snx),2,ind);
    %         imshow(csnap)
    %         subplot(length(snx),2,ind+1);
    %         imshow(snaps(:,:,i));
    %         title(sprintf('angle: %f',snth(i)*180/pi));
end
%     keyboard

% % check headings are correct
% figure(10);clf
% endx = pxsnx + cos(pxsnth);
% endy = pxsny + sin(pxsnth);
% plot([pxsnx, endx]', [pxsny, endy]', 'b', snx, sny, 'ro')
% keyboard
