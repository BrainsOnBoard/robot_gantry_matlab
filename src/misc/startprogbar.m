function startprogbar(cntint,lpsz,waitbarstr,clonly)
% function startprogbar(cntint,lpsz)
global PB_LOOP PB_INT PB_COUNT PB_WB_H PB_WB_STR
PB_LOOP = lpsz;
PB_INT = cntint;
PB_COUNT = 0;

if feature('ShowFigureWindows') && (nargin~=4 || ~clonly)
    if nargin < 3
        PB_WB_STR = '';
    else
        PB_WB_STR = waitbarstr;
    end
    
    PB_WB_H = waitbar(0,PB_WB_STR);
    figure(PB_WB_H);
else
    if nargin >= 3 && ~isempty(waitbarstr)
        disp(waitbarstr)
    end
    
    PB_WB_H = [];
end

tic