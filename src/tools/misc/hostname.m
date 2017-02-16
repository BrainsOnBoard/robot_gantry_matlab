function cn=hostname
if isunix
    [~,cn] = system('hostname');
    cn = strtrim(cn);
else
    cn = char(java.net.InetAddress.getLocalHost.getHostName);
end
