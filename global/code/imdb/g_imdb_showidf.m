function g_imdb_showidf(whz)
if ~nargin
    whz = 1;
end

whd = g_imdb_choosedb;
load(fullfile(whd,'im_params.mat'));

refxi = round(1+(length(p.xs)-1)/2);
refyi = round(1+(length(p.ys)-1)/2);

preprocess = @deal;

reffr = im2double(preprocess(g_imdb_getim(whd,refxi,refyi,whz)));

idf = NaN(length(p.ys),length(p.xs));
for yi = 1:size(idf,1)
    for xi = 1:size(idf,2)
        fr = g_imdb_getim(whd,xi,yi,whz);
        if ~isempty(fr)
            idf(yi,xi) = getRMSdiff(im2double(preprocess(fr)),reffr);
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