function g=getgantry

persistent gantryobj
if isempty(gantryobj) || ~isvalid(gantryobj)
    gantryobj = gantry_agent;
else
    
end

g = gantryobj;