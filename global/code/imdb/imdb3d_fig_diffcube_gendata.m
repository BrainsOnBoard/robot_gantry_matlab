function diffs = imdb3d_fig_diffcube_gendata(imdirshort,xrefi,yrefi,zrefi)

imdir = fullfile(mfiledir,imdirshort);

load(fullfile(imdir,'im_params.mat'))

figdir = fullfile(mfiledir,'figdat','wrapped_imdb_fig_difcube',imdirshort);
if ~exist(figdir,'dir')
    mkdir(figdir)
end

datafn = fullfile(figdir,sprintf('diffs_%03d_%03d_%03d.mat',xrefi,yrefi,zrefi));
if exist(datafn,'file')
    load(datafn)
else
    load(fullfile(imdir,sprintf('im_%03d_%03d_%03d.mat',xrefi,yrefi,zrefi)))
    reffr = fr;
    diffs = NaN(length(p.xs),length(p.ys),length(p.zs));
    startprogbar(100,numel(diffs),'getting image differences')
    for xi = 1:size(diffs,1)
        for yi = 1:size(diffs,2)
            for zi = 1:size(diffs,3)
                cfn = fullfile(imdir,sprintf('im_%03d_%03d_%03d.mat',xi,yi,zi));
                if exist(cfn,'file')
                    load(cfn,'fr')
                    diffs(xi,yi,zi) = getRMSdiff(fr,reffr);
                else
                    warning('file "%s" does not exist',cfn)
                end
                if progbar
                    diffs = [];
                    return
                end
            end
        end
    end
    savemeta(datafn,'diffs')
end