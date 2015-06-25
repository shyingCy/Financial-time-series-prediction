function traderecord = handleLeftTraderecord(traderecord,repairedRecord)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

leftI = find(traderecord(:,5)==0);
for i=leftI
    traderecord(i,5:7) = repairedRecord;
end

end

