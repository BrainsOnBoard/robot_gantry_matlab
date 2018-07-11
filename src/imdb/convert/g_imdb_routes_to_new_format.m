function g_imdb_routes_to_new_format(arena)
d = dir(fullfile(g_dir_routes,['route_' arena '_*.mat']));
for i = 1:length(d)
    fn = d(i).name;
    routefn = fullfile(g_dir_routes,fn);
    fprintf('Processing %s...\n',routefn)
    if isempty(whos('snaps','-file',routefn))
        warning('no snaps found!')
    else
        load(routefn,'p','ptr','clx','cly','snaps');
        routenum = str2double(fn(end-6:end-4));
        [snaps,~,snx,sny,snth,~,snapszht]=g_imdb_route_getrealsnaps(arena,routenum,720,@deal);

        newname = sprintf('%s_route%d',arena,routenum);
        newdir = fullfile(g_dir_imdb,'new',newname);
        mkdir(newdir);
        fid = fopen(fullfile(newdir,[newname '.csv']),'w');
        if fid==-1
            error('could not open file for writing');
        end
        fprintf('Processing %s...\n',newname);
        fprintf(fid,'X [mm], Y [mm], Z [mm], Heading [degrees], Filename\n');
        for j = 1:length(snx)
            imfn = sprintf('%s_%04d.png',newname,j);
            fprintf(fid,'%d, %d, %d, %d, %s\n',snx(i),sny(i),snapszht,snth(i)*180/pi,imfn);
            imwrite(snaps(:,:,j),fullfile(newdir,imfn));
        end
        fclose(fid);
    end
end