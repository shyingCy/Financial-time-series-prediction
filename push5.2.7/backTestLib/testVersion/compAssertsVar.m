function [LongMargin,ShortMargin,StaticEquity,DynamicEquity,Cash] = compAssertsVar(Marketposition,Close,StaticEquity,entryprice,myOpenIntRecord,profit,TradingUnits,MarginRatio)

%计算资产变量，包括多空头保证金，静态权益和动态权益等
%参数中静态权益必须是上一个K的静态权益
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
if Marketposition == 0
    LongMargin=0;                            %多头保证金
    ShortMargin=0;                           %空头保证金
    StaticEquity=StaticEquity+profit;          %静态权益
    DynamicEquity=StaticEquity;           %动态权益
    Cash=DynamicEquity;                   %可用资金
elseif Marketposition == 1
    myOpenInt = sum(myOpenIntRecord(:,2));
    OpenPosPrice = compOpenPosPrice(entryprice,myOpenIntRecord);
    LongMargin=Close*myOpenInt*TradingUnits*MarginRatio;
    ShortMargin = 0;
    StaticEquity=StaticEquity+profit;
    DynamicEquity=StaticEquity+(Close*myOpenInt-OpenPosPrice)*TradingUnits;
    Cash=DynamicEquity-LongMargin;
else
    myOpenInt = sum(myOpenIntRecord(:,2));
    OpenPosPrice = compOpenPosPrice(entryprice,myOpenIntRecord);    %算出开仓费用
    LongMargin = 0;
    ShortMargin=Close*myOpenInt*TradingUnits*MarginRatio;
    StaticEquity=StaticEquity+profit;
    DynamicEquity=StaticEquity+(OpenPosPrice-Close*myOpenInt)*TradingUnits;
    Cash=DynamicEquity-ShortMargin;
end
    
end

