clear

whx = 1;
why = 9;

whd = g_imdb_choosedb;

load(fullfile(whd,'im_params.mat'));
refxi = round(1+(length(p.xs)-1)/2);
refyi = round(1+(length(p.ys)-1)/2);

load('gantry_cropparams.mat')

im = imdb_getim(whd,why,whx);
imref = imdb_getim(whd,refyi,refxi);

heads = NaN(y2-y1+1,1);
for i = 1:length(heads)
    heads(i) = th180(ridfhead(im(i+y1-1,:),imref(i+y1-1,:),360));
end