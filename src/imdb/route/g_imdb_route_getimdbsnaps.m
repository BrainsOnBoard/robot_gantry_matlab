function [snaps,snx,sny,snth]=g_imdb_route_getimdbsnaps(arenafn,routenum,res,imfun,shortwhd,zi,imsep)

whd = fullfile(g_dir_imdb,shortwhd);

load(fullfile(g_dir_routes,sprintf('route_%s_%03d.mat',matfileremext(arenafn),routenum)),'clx','cly','whclick','p')
truesnx = clx*1000/p.arenascale;
truesny = cly*1000/p.arenascale;
truesnth = atan2(diff(cly),diff(clx));
truesnth(end+1) = truesnth(end);

[pxsnx,pxsny] = bresenham_xy(1+round(truesnx/imsep),1+round(truesny/imsep));
pxsnxy = unique([pxsnx,pxsny],'rows');
pxsnx = pxsnxy(:,1);
pxsny = pxsnxy(:,2);

snx = (pxsnx-1)*imsep;
sny = (pxsny-1)*imsep;

[~,nearest] = min(hypot(bsxfun(@minus,snx,truesnx),bsxfun(@minus,sny,truesny)),[],2);
[~,I] = sort(nearest);
snx = snx(I);
sny = sny(I);
% snth = atan2(diff(sny),diff(snx));
% snth(end+1) = snth(end);
snth = truesnth(nearest(I));
pxsnx = pxsnx(I);
pxsny = pxsny(I);

% figure(10);clf
% plot(snx,sny,'bo',truesnx,truesny,'g');
% hold on
% anglequiver(snx,sny,snth,1,'r');
% keyboard

sz = round([res*58/720, res]);
snaps = NaN([sz, length(pxsnx)]);
sninds = round(snth*720/(2*pi));
snvalids = true(length(pxsnx),1);
for i = 1:length(pxsnx)
    csnap = g_imdb_getim(whd,pxsnx(i),pxsny(i),zi);
    if isempty(csnap)
        warning('im: %s (%d,%d,%d) does not exist',shortwhd,pxsnx(i),pxsny(i),zi);
        snvalids(i) = false;
        continue
    end
    
    snaps(:,:,i) = im2double(imfun(imresize(circshift(csnap,sninds(i),2),sz,'bilinear')));
    
%     im1 = im2double(csnap);
%     im2 = im2double(circshift(csnap,sninds(i),2));
%     [head,~,cwhsn,cridfs] = ridfheadmulti(im2double(imfun(imresize(csnap,sz,'bilinear'))),snaps(:,:,i),'wta',[],length(sninds),[],true);
%     [head,~,cwhsn,cridfs] = ridfheadmulti(im1,im2,'wta',[],size(im1,2),[],true);
%     keyboard
end

snaps = snaps(:,:,snvalids);
snx = snx(snvalids);
sny = sny(snvalids);
snth = snth(snvalids);

if length(snx) < length(pxsnx)
    if isempty(snx)
        error('no valid images for snapshots')
    end
    warning('only %d/%d valid snaps obtained',length(snx),length(pxsnx));
end

% for i = 1:size(snaps,3)
%     figure(12);clf
%     plot(pxsnx,pxsny,'bo',pxsnx(i),pxsny(i),'ro')
%     
%     figure(11);clf
%     imshow(snaps(:,:,i));
%     ginput(1);
% end
% keyboard
