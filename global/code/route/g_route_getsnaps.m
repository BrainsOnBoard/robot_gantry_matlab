function snaps = g_route_getsnaps(arenafn,routenum,imw,fov)
if nargin < 4
    fov = 360;
end
if nargin < 3
    imw = 90;
end

arenafn = matfileremext(arenafn);
snapdir = g_dir_routes_snaps;
outfn = fullfile(snapdir,sprintf('snaps_%s_fov%03d_imw%03d.mat',arenafn,fov,imw));

if exist(outfn,'file')
    load(outfn,'snaps');
else
    routefn = fullfile(g_dir_routes, sprintf('route_%s_%03d.mat', arenafn, routenum));
    load(routefn,'snaps','clx','cly');
    snths = atan2(diff(cly),diff(clx));
    sninds = round(snths*size(snaps,2)/(2*pi));
    sninds(end+1) = sninds(end);

    newsz = round(imw * [size(snaps,1)/size(snaps,2), fov/360]);

    sz = [newsz,size(snaps,3)];
    snaps2 = zeros(sz,'uint8');
    for j = 1:sz(3)
        % TODO: make this work for other FOVs
        shiftim = cshiftcut(snaps(:,:,j),size(snaps,2),sninds(j));
    %     figure(1);clf
    %     imshow(shiftim)
    %     ginput(1);

        snaps2(:,:,j) = imresize(shiftim,newsz,'bilinear');
    end
    snaps = snaps2;
    
    if ~exist(snapdir,'dir')
        mkdir(snapdir);
    end
    save(outfn,'snaps');
end