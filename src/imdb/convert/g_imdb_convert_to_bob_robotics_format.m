function g_imdb_convert_to_bob_robotics_format

olddir = pwd;

cd(g_dir_imdb_raw);
d = dir('wrapped_*');

for i = 1:length(d)
    dname = d(i).name;
    fprintf('Processing %s...\n', dname)
    
    cd(dname)
    load('im_params.mat','p');
    
    % get date from path
    data.metadata.time = dname(length('wrapped_imdb_') + (1:10));
    assert(~varsinmatfile('im_params.mat','metadata'));
    
    % grid parameters
    data.metadata.type = 'grid';
    data.metadata.grid.beginAtMM = [p.xs(1) p.ys(1) p.zs(1)];
    data.metadata.grid.separationMM = p.imsep * ones(1,3);
    data.metadata.grid.size = [length(p.xs) length(p.ys) length(p.zs)];
    
    % camera properties
    data.metadata.camera.name = 'gantry';
    data.metadata.camera.resolution = p.imsz([2 1]);
    data.metadata.camera.isPanoramic = 1;
    
    % gantry-specific properties
    data.metadata.gantry.innerLimits = p.lim(:)';
    data.metadata.gantry.offset = p.offset(:)';
    data.metadata.gantry.zClearance = p.zclear;
    data.metadata.gantry.baseHeight = p.zoffs;
    data.metadata.gantry.objectGridSpacing = p.objgridac;
    data.metadata.gantry.headClearance = p.headclear;
    data.metadata.gantry.arenaName = char(p.arenafn);
    if isfield(p,'maxA')
        data.metadata.gantry.maximumAcceleration = p.maxA(:)';
    end
    if isfield(p,'maxV')
        data.metadata.gantry.maximumVelocity = p.maxV(:)';
    end
    
    % other properties
    data.metadata.needsUnwrapping = 1;
    data.metadata.isGreyscale = double(p.imsz(3) > 1);
    
    % write metadata file
    YAML.write('database_metadata.yaml',data);
    clear data
    
    % write entries file
    fid = fopen('database_entries.csv','w');
    fprintf(fid,'X [mm], Y [mm], Z [mm], Heading [degrees], Filename, Grid X, Grid Y, Grid Z\n');
    for zi = 1:length(p.zs)
        for yi = 1:length(p.ys)
            for xi = 1:length(p.xs)
                fname = sprintf('im_%03d_%03d_%03d.png',xi,yi,zi);
                if exist(fname,'file')
                    fprintf(fid, '%d, %d, %d, 0, %s, %d, %d, %d\n', p.xs(xi), p.ys(yi), p.zs(zi), fname, xi-1, yi-1, zi-1);
                end
            end
        end
    end
    fclose(fid);
    
    cd ..
end

cd(olddir);
