
% objverts = {[800 510 1220 310 1750 260 2030 1000 1150 1300]};
objverts = {[1090 370 1090 1210 2020 1180 2020 380]};

objhts = 680;

fn = fullfile(g_dir_arenas,'arena2_pile.mat');

if exist(fn,'file')
    error('file already exists')
else
    save(fn,'objverts','objhts');
end