function isSucess = sellshort(strategy,date,time,price,lots,ConOpenTimes)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
my_currentcontracts = 0;
entryRecord = [];
entryRecord_Name = [strategy,'MY_ENTRYRECORD'];
currentcontracts_Name = [strategy,'MY_CURRENTCONTRACTS'];

if isExistInWork(currentcontracts_Name)   %记录持仓数量，当平掉所有仓时可用
   my_currentcontracts =  evalin('base', currentcontracts_Name);
   
   if my_currentcontracts > 0 %持空仓则必须先平掉所有仓再买入
       sell(strategy,date,time,price,0);
       my_currentcontracts = 0;
   end
end


%第一次调用需把entryRecord添加到base
if ~isExistInWork(entryRecord_Name)
    assignin('base',entryRecord_Name,entryRecord);
end

if my_currentcontracts >= (-1) * ConOpenTimes     %限制连续建仓次数
    my_currentcontracts = my_currentcontracts-lots; %改变持仓
    
    temp = [-1,date,time,price,lots,my_currentcontracts]; %临时开仓记录
    entryRecord = evalin('base', entryRecord_Name);
    entryRecord = [entryRecord;temp];
    assignin('base',currentcontracts_Name,my_currentcontracts);
    assignin('base',entryRecord_Name,entryRecord);
    isSucess = 1;  %开仓成功
    return ;
end

isSucess = -1;  %开仓失败

end

