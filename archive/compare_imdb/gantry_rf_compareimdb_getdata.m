function [heads,minval,whsn,rd]=gantry_rf_compareimdb_getdata(arenafn,whroute,imdirshort,zi,snwstr,nth,fov,p)
imdir = fullfile(mfiledir,imdirshort);
if nargin < 8
    load(fullfile(imdir,'im_params.mat'));
end

if nargin < 7
    fov = 360;
end

rdatafn = sprintf('route_%s_%03d',matfileremext(arenafn),whroute);
rdataffn = fullfile(mfiledir,'routedat',rdatafn);
snfn = sprintf('snaps_%s_fov%03d',rdatafn,fov);
% if fov==360
%     rd = load(rdataffn);
%     snths = atan2(diff(rd.cly),diff(rd.clx));
%     snths(end+1) = snths(end);
% else
rd = load(rdataffn,'p','clx','cly','cli','whclick','rclx','rcly','ptr');
snapweighting = parseweightstr(snwstr);
if startswith(snwstr,'infomax')
    load(fullfile(mfiledir,'routedat',sprintf('infomax_%s_w%03d.mat',snfn,snapweighting{2})),'imsz','W')
else
    load(fullfile(mfiledir,'routedat',snfn));
end
%     rd.snaps = fovsnaps;
%     clear fovsnaps
% snths = [];
% end

rfigdatadir = fullfile(mfiledir,'routedat',[rdatafn '_' imdirshort]);
if ~exist(rfigdatadir,'dir')
    mkdir(rfigdatadir);
end

% [~,nearx] = min(abs(bsxfun(@minus,p.xs(:),rd.clx*100)));
% [~,neary] = min(abs(bsxfun(@minus,p.ys(:),rd.cly*100)));

rfigdatafn = fullfile(rfigdatadir,sprintf('diffs_z%03d_wt_%s_fov%03d.mat',zi,snwstr,fov));
if exist(rfigdatafn,'file')
    load(rfigdatafn)
else
    heads = NaN(length(p.xs),length(p.ys));
    [minval,whsn] = deal(cell(size(heads)));
    startprogbar(1,numel(heads))
    for xi =  1:length(p.xs) % nearx(10)
        for yi = 1:length(p.ys) % neary(10)
            cfn = fullfile(imdir,sprintf('im_%03d_%03d_%03d.mat',xi,yi,zi));
            if ~exist(cfn,'file')
                warning('file %s does not exist',cfn)
            else
                load(cfn);
                if iscell(snapweighting) && strcmp(snapweighting{1},'infomax')
                    [heads(xi,yi),minval{xi,yi}] = infomax_gethead(fr,imsz,W,[],nth,fov);
                else
                    [heads(xi,yi),minval{xi,yi},whsn{xi,yi}] = ridfheadmulti(fr,fovsnaps,snapweighting,[],nth);
%                     keyboard
                end
            end
            if progbar
                [heads,minval,whsn,rd]=deal([]);
                return
            end
        end
    end
    savemeta(rfigdatafn,'heads','minval','whsn','nth');
end
