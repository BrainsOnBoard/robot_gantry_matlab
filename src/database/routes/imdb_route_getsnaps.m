function [snaps,clickis,snx,sny,snth,crop,p]=imdb_route_getsnaps(shortwhd,routenum,res)

imw = 720;

whd = fullfile(imdbdir,shortwhd);

crop = load('gantry_cropparams.mat');
load(fullfile(imdb_routedir,sprintf('route_%03d.mat',routenum)),'snx','sny','snth');
oldsnx = snx;
oldsny = sny;
load(fullfile(whd,'im_params.mat'),'p');

[snx,sny] = bresenham_xy(oldsnx,oldsny);

[clickis,~] = find(bsxfun(@eq,snx,oldsnx) & bsxfun(@eq,sny,oldsny));

snth = atan2(diff(sny),diff(snx));
snth = mod(snth,2*pi);
snth(end+1) = snth(end);

newimsz = [round((crop.y2 - crop.y1 + 1)*res/imw) res];
snaps = zeros([newimsz,length(snx)],'uint8');

% figure(1);clf
% [gx,gy] = meshgrid(p.xs,p.ys);
% plot(gx,gy,'g.',p.xs(snx),p.ys(sny),p.xs(snx(clickis)),p.xs(sny(clickis)),'ro')

%     figure(1);clf
for i = 1:length(snx)
    csnap = imdb_getim(whd,sny(i),snx(i),crop);
    snaps(:,:,i) = imresize(circshift(csnap,round(snth(i) * imw / (2*pi)),2),newimsz,'bilinear');
    
    %         ind = 2*(i-1)+1;
    %         subplot(length(snx),2,ind);
    %         imshow(csnap)
    %         subplot(length(snx),2,ind+1);
    %         imshow(snaps(:,:,i));
    %         title(sprintf('angle: %f',snth(i)*180/pi));
end
%     keyboard

