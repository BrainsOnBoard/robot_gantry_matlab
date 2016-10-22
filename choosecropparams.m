
load('unwrap_imdb_2016-02-05_001/im_001_001.mat')

figure(1);clf
imshow(fr)

[~,y1] = ginput(1);
[~,y2] = ginput(1);
y1 = round(y1);
y2 = round(y2);

clf
imshow(fr(y1:y2,:))

save('gantry_cropparams.mat','y1','y2')