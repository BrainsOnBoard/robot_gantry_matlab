clear

shortwhd = 'imdb_2017-02-09_001';
whd = fullfile(g_dir_imdb,shortwhd);
imsz = [29 360];
res = 90; % different from imsz because we want the images at a high enough res to see
zht = 200;
routenum = 3;

forcegen = false;

load(fullfile(whd,'im_params.mat'),'p')

[imxi,imyi,heads,whsn,err1,nearest,dist,snx,sny,snth,errsel,p,isnew,allwhsn] = g_imdb_route_getdata(shortwhd,'arena2_pile',routenum,res,zht,false,'',forcegen);
[imxi,imyi,heads,whsn,err2,nearest,dist,snx,sny,snth,errsel,p,isnew,allwhsn] = g_imdb_route_getdata(shortwhd,'arena2_pile',routenum,res,zht,false,'histeq',forcegen);

[~,diffsi] = sort(err1 - err2, 'descend');

zi = find(p.zs==zht);

figure(1)
for i = 1:length(diffsi)
    clf
    
    im = imresize(g_imdb_getim(shortwhd,imxi(diffsi(i)),imyi(diffsi(i)),zi),imsz,'bilinear');
    imhisteq = histeq(im);
    
    alsubplot(3,1,1,1)
    imshow(im)
    
    alsubplot(2,1)
    imshow(imhisteq)
    
    alsubplot(3,1)
    imagesc(im - imhisteq)
    
    colormap gray
    
    if isempty(ginput(1))
        break
    end
end
