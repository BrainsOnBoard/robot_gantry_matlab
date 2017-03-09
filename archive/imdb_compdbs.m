clear

disp('CHOOSE DB1:')
whd1 = imdb_choosedb_unwrap;

disp('CHOOSE DB2:')
whd2 = imdb_choosedb_unwrap;

preprocess = @histeq;

load(fullfile(whd1,'im_params.mat'))

imdiffs = NaN(length(p.ys),length(p.xs));
startprogbar(10,numel(imdiffs),'',true);
for xi = 1:length(p.xs)
    for yi = 1:length(p.ys)
        fn1 = fullfile(whd1,sprintf('im_%03d_%03d.mat',yi,xi));
        fn2 = fullfile(whd2,sprintf('im_%03d_%03d.mat',yi,xi));
        if exist(fn1,'file')~=exist(fn2,'file')
            error('file exists in one db but not another')
        end
        
        if exist(fn1,'file')
            load(fn1);
            fr1 = fr;
            load(fn2);
            imdiffs(yi,xi) = 255\getRMSdiff(preprocess(fr1),preprocess(fr));
        end
        if progbar
            return;
        end
    end
end

%%
figure(1);clf
surf(p.xs,p.ys,imdiffs)
xlabel('x')
ylabel('y')