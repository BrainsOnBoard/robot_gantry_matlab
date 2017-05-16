function g_route_getinfomaxweights(imw,improc)
if nargin < 2
    improc = '';
end
if nargin < 1
    imw = 90;
end

imfun = gantry_getimfun(improc);
if ~isempty(improc)
    improc(end+1) = '_';
end

for cimw = imw(:)'
    flist = dir(fullfile(g_dir_routes_snaps,sprintf('snaps_*_imw%03d.mat',cimw)));
    for i = 1:length(flist)
        cfn = flist(i).name;
        
        fprintf('Loading %s...\n',cfn)
        
        datafn = fullfile(g_dir_routes_snaps,cfn);
        outfn = fullfile(g_dir_routes_infomaxweights,sprintf('infomax_%s%s.mat',improc,matfileremext(cfn)));
        
        if exist(outfn,'file')
            warning('%s exists. skipping.',outfn)
        else
            load(datafn);
            imsz = [size(fovsnaps,1), size(fovsnaps,2)];
            
            %         cfov = str2double(cfn(end-6:end-4));
            
            sz = size(fovsnaps);
            D = NaN([prod(imsz), sz(3)]);
            for j = 1:sz(3)
                cim = im2double(imfun(fovsnaps(:,:,j)));
                D(:,j) = cim(:);
                
                %             figure(1);clf
                %             imshow(cim)
                %             ginput(1);
            end
            
            disp('Training network...')
            tic
            [W,learning_rate]=infomax_train(size(D,1),D);
            traint=toc;
            fprintf('%gs taken to train network\n',traint)
            
            savemeta(outfn,'W','learning_rate','imsz','traint');
        end
    end
end
