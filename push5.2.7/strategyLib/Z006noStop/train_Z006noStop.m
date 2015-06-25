function [entryRecord,exitRecord,my_currentcontracts] = train_Z006noStop(data,pro_information,ConOpenTimes,currentcontracts,swingprice)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
%Z006 0.3版本
%data为价格数据，pro_info为商品数据
%k=1.6 ZigZag拟合程度
%TrailingStart=72 跟踪止损启动设置
%TrailingStop=27 跟踪止损设置
%StopLossSet=37 止损设置
%14/10/11 19:39

%参数
MinPoint = pro_information{3}; %商品最小变动单位
lots = 1; %交易手数

%变量
preciseV = 0.09; %精度变量，控制两值相等的精度问题

%变量
%K线变量
Date = data(:,1);
Time = data(:,2);
Open = data(:,3);
High = data(:,4);
Low = data(:,5);
Close = data(:,6);
barLength = size(Close,1); %K线总量

%调用买卖函数需要的变量
entryRecord = []; %开仓记录
exitRecord = []; %平仓记录
my_currentcontracts = currentcontracts;  %持仓手数

%策略变量
stoploss=0; %止损价格
MyEntryPrice = []; %开仓价格，本例是开仓均价，也可根据需要设置为某次入场的价格

MarketPosition = getMarketPosition(my_currentcontracts);

for i=3:barLength
    
    %-------------交易主体--------------%
    %==================================%
    tranVar1 = High(i-1)-Low(i-1);
    tranVar2 = High(i-2)-Low(i-2);
    tranCon1 = (tranVar1 - tranVar2) > preciseV;
    if MarketPosition~=1 && (Low(i-1)>swingprice(i)) && tranCon1 && (Low(i-1)>Low(i-2))
        entryPrice = Open(i);
        [entryRecord,exitRecord,my_currentcontracts,isSucess] = train_buy(entryRecord,exitRecord,my_currentcontracts,...
            Date(i),Time(i),entryPrice,lots,ConOpenTimes); %这里只需修改max(Open(i),smallswing(i))，这个是价格
        %isSucess是开仓是否成功的标志
        if isSucess == 1
            MyEntryPrice(1) = entryPrice; %无需止损可删除
            stoploss=swingprice(i);
            MarketPosition = 1; %需要用到MarketPosition则设置，无需要则删除
        end
    end
    if MarketPosition~=-1 && (High(i-1)<swingprice(i)) && tranCon1 && (High(i-1)<High(i-2))
        entryPrice = Open(i);
        [entryRecord,exitRecord,my_currentcontracts,isSucess] = train_sellshort(entryRecord,exitRecord,my_currentcontracts,...
            Date(i),Time(i),entryPrice,lots,ConOpenTimes);
        if isSucess == 1
            MyEntryPrice(1) = entryPrice;
            stoploss=swingprice(i);
            MarketPosition = -1;
        end
    end
    if MarketPosition == 1 && Close(i-1) < stoploss
        exitPrice = Open(i);
        [exitRecord,my_currentcontracts] = train_sell(exitRecord,my_currentcontracts,...
            Date(i),Time(i),exitPrice,lots);
        MarketPosition = 0;
        MyEntryPrice = []; %重置开仓价格
    end
    if MarketPosition == -1 && Close(i-1) > stoploss
        exitPrice = Open(i);
        [exitRecord,my_currentcontracts] = train_buyToCover(exitRecord,my_currentcontracts,...
            Date(i),Time(i),exitPrice,lots);
        MarketPosition=0;
        MyEntryPrice = []; %重置开仓价格
    end
    
end

end