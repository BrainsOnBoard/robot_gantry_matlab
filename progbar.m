function killed=progbar(newtxt)
global PB_LOOP PB_INT PB_COUNT PB_WB_H PB_WB_STR
killed = false;

PB_COUNT = PB_COUNT+1;
if ~isempty(PB_WB_H) && ~ishandle(PB_WB_H)
    killed = true;
    return;
end

if PB_COUNT==PB_LOOP || ~mod(PB_COUNT,PB_INT)
    fr = PB_COUNT/PB_LOOP;

    t = (PB_LOOP-PB_COUNT)*toc/PB_COUNT;
    totmin = ceil(t/60);
    tmin = mod(totmin,60);
    thour = (totmin-tmin)/60;
    pinf = sprintf('%3.2f%% ~%dh %dm remains',fr*100,thour,tmin);

    if isempty(PB_WB_H)
        ws = get(0,'CommandWindowSize');
        sz = ws(1)-length(pinf)-3;
        ndone = round(fr*sz);
        fprintf('[%s%s] %s\r',char(ones(1,ndone)*'='),char(ones(1,(sz-ndone))*'-'),pinf);
        if PB_COUNT==PB_LOOP
            fprintf('\n');
        end
    elseif ishandle(PB_WB_H)
        if PB_COUNT==PB_LOOP
            close(PB_WB_H);
        else
            if nargin
                PB_WB_STR = newtxt;
            end
            if ~isempty(PB_WB_STR)
                pinf = [' - ' pinf];
            end
            waitbar(fr,PB_WB_H,[PB_WB_STR pinf]);
        end
    else
        killed = true;
    end
end