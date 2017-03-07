function imdb_route_perpixelridf

%%
shortwhd = 'unwrap_imdb3d_2017-02-09_001';
whd = fullfile(imdbdir,shortwhd);
% imsz = [29 360];

im = im2double(imdb_getim3d(whd,1,1,1,[]));
snap = im;
im_histeq = histeq(im);
snap_histeq = histeq(snap);

th = 0;

%%
dump2base(true)

pxerr = pixelerr(im,snap,th);
pxerr_histeq = pixelerr(im_histeq,snap_histeq,th);

figure(1);clf
alsubplot(3,2,1,1)
imshow(im)

alsubplot(2,1)
imshow(snap)

alsubplot(3,1)
imagesc(pxerr)

alsubplot(1,2)
imshow(im_histeq)

alsubplot(2,2)
imshow(snap_histeq)

alsubplot(3,2)
imagesc(pxerr_histeq)

colorbar

function pxerr=pixelerr(im,snap,th)
pxerr = NaN(size(im));
for i = 1:size(im,2)
    pxdiffs = abs(bsxfun(@minus,im(:,i),snap));
    
    [minval,mini] = min(pxdiffs,[],2);
    pxerr(:,i) = abs(circ_dist(th,2*pi*(mini-1)./size(im,2)));
end