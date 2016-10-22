function [fd,whd,refxi,refyi,p,label] = imdb_getfigdat_ridferrsbyrowchunked(dogen,whd)

if nargin < 2
    whd = imdb_choosedb_unwrap;
end

load(fullfile(whd,'im_params.mat'));
load('gantry_cropparams.mat');
label = imdb_getlabel(whd);

refxi = round(1+(length(p.xs)-1)/2);
refyi = round(1+(length(p.ys)-1)/2);

figdatdir = fullfile(whd,'figdat');
figdatfn = fullfile(figdatdir,sprintf('fig_ridferrsbyrowchunked_%03d_%03d.mat',refyi,refxi));
if ~dogen || exist(figdatfn,'file')
    disp('loading fig data')
    load(figdatfn)
else
    chunkht = 10;
    
    load(fullfile(whd,sprintf('im_%03d_%03d.mat',refyi,refxi)),'fr');
    reffr = im2gray(fr(y1:y2,:));
    imht = size(reffr,1);
    
    [fd.heads,fd.idf] = deal(NaN(length(p.ys),length(p.xs)));
    nchunk = ceil(imht/chunkht);
    fd.headsbychunk = NaN([nchunk,size(fd.heads)]);
    for yi = 1:size(fd.idf,1)
        for xi = 1:size(fd.idf,2)
            fname = fullfile(whd,sprintf('im_%03d_%03d.mat',yi,xi));
            if exist(fname,'file')
                load(fname,'fr');
                cfr = fr(y1:y2,:);
                [fd.heads(yi,xi),fd.idf(yi,xi)] = ridfhead(cfr,reffr);
                for i = 1:nchunk
                    whrow = 1+(i-1)*chunkht:min(imht,1+i*chunkht);
                    fd.headsbychunk(i,yi,xi) = ridfhead(cfr(whrow,:),reffr(whrow,:));
                end
            end
        end
    end
    fd.headsbychunk = rad2deg(pi2pi(fd.headsbychunk));
    
    if ~exist(figdatdir,'dir')
        mkdir(figdatdir)
    end
    save(figdatfn,'fd')
end