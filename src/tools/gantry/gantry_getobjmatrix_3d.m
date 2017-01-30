function [objmap,oxs,oys] = gantry_getobjmatrix_3d(arenafn,objgridac)
load('arenadim.mat')
if isempty(arenafn)
    objmap = zeros(ceil(lim([2 1])'/objgridac));
else
    load(arenafn)
    if ~exist('objhts','var')
        warning('object heights not specified')
        objhts = inf(numel(objverts),1);
    end
    if iscell(objverts)
        objverts = cellfun(@(x)x./objgridac,objverts,'UniformOutput',false);
    else
        objverts = objverts/objgridac;
    end
   
    objmap = zeros(ceil(lim([2 1])'/objgridac));
    blankim = zeros([size(objmap),3],'uint8');
    for i = 1:length(objverts)
        cim = insertShape(blankim,'FilledPolygon',objverts{i},'Color','white','Opacity',1);
        objmap = max(objmap,objhts(i)*logical(cim(:,:,1)));
    end
end

oxs = objgridac*(0:size(objmap,2));
oys = objgridac*(0:size(objmap,1));