function [steerang,dhead] = sl_alg(vc,aimhead,steergain,steermax)
if nargin < 4
    steermax = 45;
end
if nargin < 3
    steergain = 1;
end
if nargin < 2
    aimhead = 0;
end

dhead = circ_distd(aimhead,getheading(vc));
steerang = sign(dhead)*min(dhead,gain*abs(dhead));