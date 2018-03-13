function g_bb_idf_trim(shortwhd,z,ycutoff,dosave)

if nargin < 4
    dosave = false;
end
if nargin < 3 || isempty(ycutoff)
    ycutoff = 58;
end
if nargin < 1 || isempty(shortwhd)
    whd = g_imdb_choosedb;
else
    whd = fullfile(g_dir_imdb,shortwhd);
end

load(fullfile(whd,'im_params.mat'),'p');
if nargin < 2 || isempty(z)
    z = p.zs(end);
end
zi = find(p.zs==z);
if isempty(zi)
    error('invalid height (%s)',num2str(p.zs))
end

fprintf('height: %dmm (%s)\n',z,num2str(p.zs));

figure(1);clf
if ycutoff==58
    plotidf(p,whd,zi,1:ycutoff);
else
    subplot(1,2,1)
    plotidf(p,whd,zi,1:ycutoff);
    title('top')

    subplot(1,2,2)
    plotidf(p,whd,zi,ycutoff+1:58);
    title('bottom')
end

if dosave
    g_fig_save(sprintf('%s_idf_z%03',flabel,z),[10 10]);
end

function plotidf(p,whd,zi,yrng)

refxi = round(1+(length(p.xs)-1)/2);
refyi = round(1+(length(p.ys)-1)/2);

preprocess = @deal;

reffrraw = g_imdb_getim(shortwhd,refxi,refyi,zi);
if isempty(reffrraw)
    error('no image found for reference location')
end
reffr = im2double(preprocess(reffrraw(yrng,:)));

idf = NaN(length(p.ys),length(p.xs));
for yi = 1:size(idf,1)
    for xi = 1:size(idf,2)
        fr = g_imdb_getim(whd,xi,yi,zi);
        if ~isempty(fr)
            idf(yi,xi) = getRMSdiff(im2double(preprocess(fr(yrng,:))),reffr);
        end
    end
end

%%
% [mx,my] = meshgrid(1:length(p.xs),1:length(p.ys));
% truehead = atan2(refyi-my,refxi-mx);

% [dx,dy] = gradient(idf);
% [esthead,len] = cart2pol(-dx,-dy);

% errmap = len.*cos(circ_dist(truehead,esthead));

% figure(10);clf
% imagesc(p.xs,p.ys,errmap)
% colorbar

%%
surf(p.xs/1000,p.ys/1000,idf)
xlabel('x (m)')
ylabel('y (m)')
zlabel('r.m.s. image difference')