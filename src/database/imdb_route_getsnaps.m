function [snaps,snx,sny,snth,crop]=imdb_route_getsnaps(shortwhd,routenum,res)

snapsdir = fullfile(imdb_routedir,sprintf('route_%03d_snaps',routenum));
if ~exist(snapsdir,'dir')
    mkdir(snapsdir);
end

snapsfn = fullfile(snapsdir,sprintf('snaps_res%03d.mat',res));
if exist(snapsfn,'file')
    load(snapsfn);
else
    imw = 720;
    
    crop = load('gantry_cropparams.mat');
    load(fullfile(imdb_routedir,sprintf('route_%03d.mat',routenum)),'snx','sny','snth');
    
    newimsz = [round((crop.y2 - crop.y1 + 1)*res/imw) res];
    snaps = zeros([newimsz,length(snx)],'uint8');
    whd = fullfile(imdbdir,shortwhd);
    
    %     figure(1);clf
    for i = 1:length(snx)
        csnap = imdb_getim(whd,sny(i),snx(i),crop);
        snaps(:,:,i) = circshift(imresize(csnap,newimsz,'bilinear'),round(snth(i) * imw / (2*pi)),2);
        
        %         ind = 2*(i-1)+1;
        %         subplot(length(snx),2,ind);
        %         imshow(csnap)
        %         subplot(length(snx),2,ind+1);
        %         imshow(snaps(:,:,i));
        %         title(sprintf('angle: %f',snth(i)*180/pi));
    end
    %     keyboard
    
    fprintf('Saving snapshots to %s...\n',snapsfn);
    save(snapsfn,'snaps','snx','sny','snth','crop');
end