function TradingCost = train_compTradingCost(ClosePosPrice,OpenPosPrice,TradingUnits,Lots,TradingCost_info)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

if TradingCost_info>0
    TradingCost = 2 * Lots * TradingCost_info; %乘以2表示开平仓均收费
else
    TradingCost = (-1)*0.0001*(OpenPosPrice*TradingUnits*Lots*TradingCost_info + ClosePosPrice*TradingUnits*Lots*TradingCost_info);
end

