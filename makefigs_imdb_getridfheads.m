clear

dbs = {
    'unwrap_imdb_2016-02-04_002', ... % empty, closed
    'unwrap_imdb_2016-02-09_002', ... % empty, open
    'unwrap_imdb_2016-02-05_001', ... % boxes, closed
    'unwrap_imdb_2016-02-09_001'      % boxes, open
    };

for i = 1:length(dbs)
    imdb_getridfheads(dbs{i}, true);
end
