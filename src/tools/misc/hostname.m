function cn=hostname
if usejava('jvm')
    cn = char(java.net.InetAddress.getLocalHost.getHostName);
else
    [stat,cn] = system('hostname');
    cn = strtrim(cn);
end
