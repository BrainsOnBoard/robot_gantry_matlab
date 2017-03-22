function g_imdb_2dto3d(dbdir)
% a function to convert the old 2D databases to new-style 3D ones

d = dir(fullfile(dbdir,'unwrap_imdb_*'));

for i = 1:length(d)
    fprintf('working on %s\n',d(i).name);
    
    cdbdirout = fullfile(g_dir_imdb,d(i).name(8:end));
    if exist(cdbdirout,'dir')
        error('directory %s already exists',cdbdirout);
    end
    mkdir(cdbdirout);
    
    cdbdirin = fullfile(dbdir,d(i).name);
    pfn = fullfile(cdbdirin,'im_params.mat');
    load(pfn)
    p.zs = p.zht;
    
    newlabel = sprintf('z=%dmm',p.zht);
    if varsinmatfile(pfn,'label')
        newlabel = [newlabel ': ' label];
    end
    label = newlabel;
    
    save(fullfile(cdbdirout,'im_params.mat'),'p','unwrapparams','label');
    
    imfiles = dir(fullfile(cdbdirin,'im_*_*.mat'));
    for j = 1:length(imfiles)
        cname = imfiles(j).name;
        cy = cname(4:6);
        cx = cname(8:10);
        copyfile(fullfile(cdbdirin,cname),fullfile(cdbdirout,sprintf('im_%s_%s_001.mat',cx,cy)));
    end
end