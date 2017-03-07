clear

%%
shortwhd = 'unwrap_imdb3d_2017-02-09_001';
whd = fullfile(imdbdir,shortwhd);
% imsz = [29 360];

im = im2double(imdb_getim3d(whd,1,1,1,[]));
snap = im2double(imdb_getim3d(whd,27,7,1,[]));
% snap = im;
th = 0;

%%
pxerr = NaN(size(im));
for i = 1:size(im,2)
    pxdiffs = abs(bsxfun(@minus,im(:,i),snap));
    
    [minval,mini] = min(pxdiffs,[],2);
    pxerr(:,i) = 1 - pi \ abs(circ_dist(th,2*pi*(mini-1)./size(im,2)));
end

figure(1);clf
alsubplot(3,1,1,1)
imshow(im)

alsubplot(2,1)
imshow(snap)

alsubplot(3,1)
imagesc(pxerr);
axis equal
colorbar
