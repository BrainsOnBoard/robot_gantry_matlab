function [objtf,oxs,oys] = gantry_getobjmatrix(arenafn,objgridac)
load('arenadim.mat')
if isempty(arenafn)
    objtf = false(ceil(lim([2 1])'/objgridac));
else
    load(arenafn)
    if iscell(objverts)
        objverts = cellfun(@(x)x./objgridac,objverts,'UniformOutput',false);
    else
        objverts = objverts/objgridac;
    end
   
    objI = zeros([ceil(lim([1 2])'/objgridac),3],'uint8');
    objI = insertShape(objI,'FilledPolygon',objverts,'Color','white','Opacity',1);
    objtf = any(objI > 0,3)';
end

oxs = objgridac*(0:size(objtf,2));
oys = objgridac*(0:size(objtf,1));