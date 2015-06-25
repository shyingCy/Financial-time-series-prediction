function [exitRecord,my_currentcontracts,isSucess] = train_sell(exitRecord,my_currentcontracts,date,time,price,lots)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here


if my_currentcontracts > 0     %只有持多仓时才采取操作
    if lots == 0 || lots > my_currentcontracts
        lots = my_currentcontracts;
    end
    temp = [-2,date,time,price,lots,my_currentcontracts];
    exitRecord = [exitRecord;temp];
    my_currentcontracts = my_currentcontracts - lots;
    
    isSucess = 1;   %平仓成功
    return;
end

isSucess = -1;  %平仓失败

end
