function gantry_rf_getinfomaxweightsfov %(arenafn,whroute,fov,imw)
if nargin < 4
    imw = 120;
end

flist = dir(fullfile(routes_fovsnapdir,'snaps_*_fov*.mat'));

for i = 1:length(flist)
    cfn = flist(i).name;
    
    fprintf('Loading %s...\n',cfn)
    
    datafn = fullfile(routes_fovsnapdir,cfn);
    outfn = fullfile(routes_infomaxweightsdir,sprintf('infomax_%s_w%03d.mat',matfileremext(cfn),imw));
    
    if exist(outfn,'file')
        warning('%s exists. skipping.',outfn)
    else
        load(datafn);
        
        cfov = str2double(cfn(end-6:end-4));
        
        sz = size(fovsnaps);
        imsz = round((cfov/360)*[sz(1)*imw/sz(2),imw]);
        D = NaN([prod(imsz), sz(3)]);
        for j = 1:sz(3)
            cim = imresize(im2double(fovsnaps(:,:,j)),imsz,'bilinear');
            D(:,j) = cim(:);
            
%             figure(1);clf
%             imshow(cim)
%             ginput(1);
        end
        
        disp('Training network...')
        tic
        W=infomax_train(size(D,1),D);
        traint=toc;
        fprintf('%gs taken to train network',traint)
        
        savemeta(outfn,'W','imsz','traint');
    end
end