function skyl=g_bb_cap_skyl(skyl,x1,x2,ht)
sel = true(size(skyl));
if x2 < x1
    x2 = x2+length(skyl);
end
sel(normaz(x1:x2,length(skyl))) = false;
skyl(sel) = ht;
