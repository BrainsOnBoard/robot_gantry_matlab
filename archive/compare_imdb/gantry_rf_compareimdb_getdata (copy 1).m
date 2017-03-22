function [heads,minval,whsn,rd]=g_live_compareimdb_getdata(arenafn,whroute,imdirshort,zi,snwstr,nth,fov,p)
imdir = fullfile(mfiledir,imdirshort);
if nargin < 8
    load(fullfile(imdir,'im_params.mat'));
end

if nargin < 7
    fov = 360;
end

snapweighting = parseweightstr(snwstr);

rdatafn = sprintf('route_%s_%03d',arenafn,whroute);
rdataffn = fullfile(mfiledir,'routedat',rdatafn);
if fov==360
    rd = load(rdataffn);
    snths = atan2(diff(rd.cly),diff(rd.clx));
    snths(end+1) = snths(end);
else
    rd = load(rdataffn,'p','clx','cly','cli','whclick','rclx','rcly','ptr');
    load(fullfile(mfiledir,'routedat',sprintf('snaps_%s_fov%03d.mat',rdatafn,fov)));
    rd.snaps = fovsnaps;
    clear fovsnaps
    snths = [];
end

rfigdatadir = fullfile(mfiledir,'routedat',[rdatafn '_' imdirshort]);
if ~exist(rfigdatadir,'dir')
    mkdir(rfigdatadir);
end

rfigdatafn = fullfile(rfigdatadir,sprintf('diffs_z%03d_wt_%s_fov%03d.mat',zi,snwstr,fov));
if exist(rfigdatafn,'file')
    load(rfigdatafn)
else
    heads = NaN(length(p.xs),length(p.ys));
    [minval,whsn] = deal(cell(size(heads)));
    startprogbar(1,numel(heads))
    for xi = 1:length(p.xs)
        for yi = 1:length(p.ys)
            cfn = fullfile(imdir,sprintf('im_%03d_%03d_%03d.mat',xi,yi,zi));
            if ~exist(cfn,'file')
                warning('file %s does not exist',cfn)
            else
                load(cfn);
                [heads(xi,yi),minval{xi,yi},whsn{xi,yi}] = ridfheadmulti(fr,rd.snaps,snapweighting,[],nth,snths);
            end
            if progbar
                [heads,minval,whsn,rd]=deal([]);
                return
            end
        end
    end
    savemeta(rfigdatafn,'heads','minval','whsn','nth');
end
