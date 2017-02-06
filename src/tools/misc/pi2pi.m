function th=pi2pi(th)
th = mod(th,2*pi);
th(th > pi) = th(th > pi)-2*pi;