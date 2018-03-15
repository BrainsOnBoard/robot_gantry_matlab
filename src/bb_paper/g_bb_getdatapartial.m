function [allheads,allerrs,allwhsn] = g_bb_getdatapartial( ...
    coords,shortwhd,routenum,res,zht,useinfomax,improc,forcegen, ...
    improcforinfomax,userealsnaps,snapszht,dosave)

p = g_imdb_getparams(shortwhd);

[allheads,allerrs,allwhsn] = deal(cell(length(zht),1));
for i = 1:length(zht)
    [imxi,imyi,heads,whsn,errs] = g_imdb_route_getdata( ...
        shortwhd,routenum,res,zht(i),useinfomax,improc,forcegen, ...
        improcforinfomax,userealsnaps,snapszht,dosave);

    imx = p.xs(imxi);
    imy = p.ys(imyi);
    [xyi,~] = find(bsxfun(@eq,coords(:,1)',imx(:)) & bsxfun(@eq,coords(:,2)',imy(:)));
    allheads{i} = heads(xyi)';
    allerrs{i} = errs(xyi)';
    allwhsn{i} = whsn(xyi)';
end
allheads = cell2mat(allheads);
allerrs = cell2mat(allerrs);
allwhsn = cell2mat(allwhsn);
