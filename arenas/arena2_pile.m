
% objverts = {[1380 1000 1800 800 2330 750 2610 1490 1730 1790]};
objverts = {[800 510 1220 310 1750 260 2030 1000 1150 1300]};

objhts = 680;

fn = fullfile(arenadir,'arena2_pile.mat');

if exist(fn,'file')
    error('file already exists')
else
    save(fn,'objverts','objhts');
end