function [entryRecord,exitRecord,my_currentcontracts,isSucess] = train_buy(entryRecord,exitRecord,my_currentcontracts,date,time,price,lots,ConOpenTimes)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here

   
if my_currentcontracts < 0 %持空仓则必须先平掉所有仓再买入
    [exitRecord,my_currentcontracts,isSucess] = train_buyToCover(exitRecord,my_currentcontracts,date,time,price,0);
end

if my_currentcontracts <= ConOpenTimes     %限制连续建仓次数
    temp = [1,date,time,price,lots,my_currentcontracts]; %临时开仓记录
    entryRecord = [entryRecord;temp];
    my_currentcontracts = my_currentcontracts+lots;
    
    isSucess = 1;   %开仓成功
    return;
end

isSucess = -1;  %开仓失败

end

