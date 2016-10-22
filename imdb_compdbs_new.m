clear

disp('CHOOSE DB1:')
whd1 = imdb_choosedb_unwrap;

disp('CHOOSE DB2:')
whd2 = imdb_choosedb_unwrap;

preprocess = @histeq;

load(fullfile(whd1,'im_params.mat'))

imdiffs = NaN(length(p.ys),length(p.xs));
for yi = 1:length(p.ys)
    for xi = 1:length(p.xs)
        fn = sprintf('im_%03d_%03d.mat',yi,xi);
        fn1 = fullfile(whd1,fn);
        fn2 = fullfile(whd2,fn);
        fex1 = exist(fn1,'file');
        if fex1 ~= exist(fn2,'file')
            error('file (y: %d, x: %d) exists for one db but not another',yi,xi)
        end
        
        if fex1
            load(fn1)
            fr1 = preprocess(fr);
            load(fn2)
            fr2 = preprocess(fr);
            
            imdiffs(yi,xi) = 255\getRMSdiff(fr1,fr2);
        end
    end
end

%%
figure(1);clf
surf(p.xs,p.ys,imdiffs)