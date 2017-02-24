function gantry_rf_getinfomaxweightsfov(imw,improc)
if nargin < 2
    improc = 'histeq_';
else
    improc = [improc, '_'];
end
if nargin < 1
    imw = 90;
end

for cimw = imw(:)'
    flist = dir(fullfile(routes_fovsnapdir,sprintf('%ssnaps_*_imw%03d.mat',improc,cimw)));
    for i = 1:length(flist)
        cfn = flist(i).name;
        
        fprintf('Loading %s...\n',cfn)
        
        datafn = fullfile(routes_fovsnapdir,cfn);
        outfn = fullfile(routes_infomaxweightsdir,sprintf('infomax_%s.mat',matfileremext(cfn)));
        
        if exist(outfn,'file')
            warning('%s exists. skipping.',outfn)
        else
            load(datafn);
            imsz = [size(fovsnaps,1), size(fovsnaps,2)];
            
            %         cfov = str2double(cfn(end-6:end-4));
            
            sz = size(fovsnaps);
            D = NaN([prod(imsz), sz(3)]);
            for j = 1:sz(3)
                cim = im2double(fovsnaps(:,:,j));
                D(:,j) = cim(:);
                
                %             figure(1);clf
                %             imshow(cim)
                %             ginput(1);
            end
            
            disp('Training network...')
            tic
            W=infomax_train(size(D,1),D);
            traint=toc;
            fprintf('%gs taken to train network\n',traint)
            
            savemeta(outfn,'W','imsz','traint');
        end
    end
end
