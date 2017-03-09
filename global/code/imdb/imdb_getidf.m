
whd = imdb_choosedb_unwrap;
load(fullfile(whd,'im_params.mat'));

refxi = round(1+(length(p.xs)-1)/2);
refyi = round(1+(length(p.ys)-1)/2);

load('gantry_cropparams.mat')

preprocess = @deal;

load(fullfile(whd,sprintf('im_%03d_%03d.mat',refyi,refxi)),'fr');
reffr = preprocess(im2gray(fr(y1:y2,:)));

[idf,hc] = deal(NaN(length(p.ys),length(p.xs)));
for yi = 1:size(idf,1)
    for xi = 1:size(idf,2)
        fname = fullfile(whd,sprintf('im_%03d_%03d.mat',yi,xi));
        if exist(fname,'file')
            load(fname,'fr');
            idf(yi,xi) = 255\getRMSdiff(preprocess(im2gray(fr(y1:y2,:))),reffr);
        end
    end
end

%%
[mx,my] = meshgrid(1:length(p.xs),1:length(p.ys));
truehead = atan2(refyi-my,refxi-mx);

[dx,dy] = gradient(idf);
[esthead,len] = cart2pol(-dx,-dy);

errmap = len.*cos(circ_dist(truehead,esthead));

figure(10);clf
imagesc(p.xs,p.ys,errmap)
colorbar

%%
figure(1);clf
surf(p.xs/1000,p.ys/1000,idf)
xlabel('x (m)')
ylabel('y (m)')
zlabel('R.m.s. image difference')