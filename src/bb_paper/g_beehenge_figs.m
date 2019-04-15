clear

%%
shortwhd = 'unwrapped_2017-06-06_001';
routenums = 1;
trainheights = [100 600];
testheights = trainheights;
allheights = 0:100:600;

%%
g_bb_quiver(shortwhd,routenums,testheights,trainheights,false, ...
    false,[],true,false,true,true)

%%
g_bb_boxplot(shortwhd,routenums,allheights,trainheights,false,false,[],true,true)

%%
g_bb_errlines(shortwhd,routenums,allheights,allheights,false, ...
    false,[],true,[],[],NaN)