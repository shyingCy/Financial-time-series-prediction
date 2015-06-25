function isSucess = sell(strategy,date,time,price,lots)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here

my_currentcontracts = 0;
exitRecord = [];
currentcontracts_Name = [strategy,'MY_CURRENTCONTRACTS'];
exitRecord_Name = [strategy,'MY_EXITRECORD'];

if isExistInWork(currentcontracts_Name)   %记录持仓数量，当平掉所有仓时可用？？这里的判断如果正确调用了buy或者sellshort其实是不用的
    my_currentcontracts =  evalin('base', currentcontracts_Name);
end

if ~isExistInWork(exitRecord_Name)
    assignin('base',exitRecord_Name,exitRecord);
end

if my_currentcontracts > 0     %只有持多仓时才采取操作
    if lots == 0 || lots > my_currentcontracts
        lots = my_currentcontracts;
    end
    
    my_currentcontracts = my_currentcontracts - lots;  %改变持仓
    
    temp = [-2,date,time,price,lots,my_currentcontracts];
    exitRecord = evalin('base', exitRecord_Name);
    exitRecord = [exitRecord;temp];
    
    assignin('base',currentcontracts_Name,my_currentcontracts);
    assignin('base',exitRecord_Name,exitRecord);
    
    isSucess = 1;  %平仓成功
    return ;
end

isSucess = -1;  %平仓失败

end
