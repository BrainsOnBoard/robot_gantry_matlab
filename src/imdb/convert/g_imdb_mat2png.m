function g_imdb_mat2png

d = dir;
for i = 1:length(d)
    if d(i).isdir && d(i).name(1)~='.'
        fprintf('entering %s\n',d(i).name);
        cd(d(i).name);
        imfns = dir(fullfile('im_*_*.mat'));
        for j = 1:length(imfns)
            load(imfns(j).name,'fr');
            imwrite(fr,[imfns(j).name(1:end-4) '.png']);
            delete(imfns(j).name);
        end
        cd('..');
    end
end
