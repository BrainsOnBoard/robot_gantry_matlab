
objverts = {[540 50 295 515 445 590 680 125], ...
            [730 540 795 675 595 760 550 625], ...
            [430 1130 850 1320 750 1565 320 1375], ...
            [1425 310 1550 30 1965 200 1840 490], ...
            [2130 940 2590 1085 2405 1505 1985 1350]};

objhts = [392 98 604 420 502];

fn = fullfile(g_dir_arenas,'arena1_boxes.mat');

if exist(fn,'file')
    error('file already exists')
else
    save(fn,'objverts','objhts');
end