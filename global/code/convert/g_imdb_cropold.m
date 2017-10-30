function g_imdb_cropold

crop = load('gantry_cropparams.mat');

oldpwd = pwd;

cd(g_dir_imdb);
d = dir('imdb_*');
for i = 1:length(d)
    if d(i).isdir
        cd(d(i).name);
        imfns = dir(fullfile('im_*_*_*.png'));
        for j = 1:length(imfns)
            im = imread(imfns(j).name);
            switch size(im,1)
                case 120 % uncropped
                    im = im(crop.y1:crop.y2,:);
                    if j==1
                        fprintf('Cropping database %s...\n',d(i).name)
                    end
                    imwrite(im,imfns(j).name);
                case 58 % already cropped
                otherwise
                    warning('%s is an unexpected size',fullfile(d(i).name,imfns(j).name))
            end
        end
        cd('..');
    end
end

cd(oldpwd);