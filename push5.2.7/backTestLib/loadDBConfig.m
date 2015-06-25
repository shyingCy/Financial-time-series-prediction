function [ODBCName,user,password,dbName] = loadDBConfig()
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

filename = 'Config\DBConfig.txt';
[fid,message] = fopen(filename,'r');
if fid==-1
    disp(message);
    return ;
else
    Configdata = textscan(fid, '%s %s','delimiter', ':');
end

ODBCName = Configdata{2}{1};
user = Configdata{2}{2};
password = Configdata{2}{3};
dbName = Configdata{2}{4};

fclose(fid);
end

