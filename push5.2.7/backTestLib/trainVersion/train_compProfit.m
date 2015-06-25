function profit = train_compProfit(Type,ClosePosPrice,OpenPosPrice,TradingUnits,Lots,TradingCost_info)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

tradingcost = train_compTradingCost(ClosePosPrice,OpenPosPrice,TradingUnits,Lots,TradingCost_info);
if Type == 1
    profit = (ClosePosPrice-OpenPosPrice)*TradingUnits*Lots - tradingcost;
else
    profit = (OpenPosPrice-ClosePosPrice)*TradingUnits*Lots - tradingcost;
end

end

