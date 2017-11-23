function g_bb_idf_trim(whdshort,whz,yrng,dosave)

if nargin < 4
    dosave = false;
end
if nargin < 3 || isempty(yrng)
    yrng = 1:58; % whole image
%     yrng = 31:58;
end
if nargin < 1 || isempty(whdshort)
    whd = g_imdb_choosedb;
else
    whd = fullfile(g_dir_imdb,whdshort);
end

load(fullfile(whd,'im_params.mat'),'p');
if nargin < 2 || isempty(whz)
    whz = length(p.zs);
end

refxi = round(1+(length(p.xs)-1)/2);
refyi = round(1+(length(p.ys)-1)/2);

preprocess = @deal;

reffrraw = g_imdb_getim(whd,refxi,refyi,whz);
if isempty(reffrraw)
    error('no image found for reference location')
end
reffr = im2double(preprocess(reffrraw(yrng,:)));

idf = NaN(length(p.ys),length(p.xs));
for yi = 1:size(idf,1)
    for xi = 1:size(idf,2)
        fr = g_imdb_getim(whd,xi,yi,whz);
        if ~isempty(fr)
            idf(yi,xi) = getRMSdiff(im2double(preprocess(fr(yrng,:))),reffr);
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
zlabel('r.m.s. image difference')
if dosave
    g_fig_save(sprintf('%s_idf_z%03',flabel,whz),[10 10]);
end