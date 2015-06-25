function [entryRecord,exitRecord,my_currentcontracts] = train_Z006(data,pro_information,ConOpenTimes,currentcontracts,swingprice,TrailingStart,TrailingStop,StopLossSet)
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

HighestAfterEntry=zeros(barLength,1); %开仓后出现的最高价
LowestAfterEntry=zeros(barLength,1); %开仓后出现的最低价
AvgEntryPrice = 0;

MarketPosition = getMarketPosition(my_currentcontracts);
BarsSinceEntry = 0; %距离最近一次开仓K数量，-1表示没开仓，大于等于0表示在持仓情况下

for i=3:barLength
    
    HighestAfterEntry(i) = HighestAfterEntry(i-1);
    LowestAfterEntry(i) = LowestAfterEntry(i-1);
    
    if MarketPosition~=0
        BarsSinceEntry = BarsSinceEntry+1;
    end
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
            BarsSinceEntry = 0; %无需止损可删除
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
            BarsSinceEntry = 0;
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
        BarsSinceEntry = 0;
        MyEntryPrice = []; %重置开仓价格
    end
    if MarketPosition == -1 && Close(i-1) > stoploss
        exitPrice = Open(i);
        [exitRecord,my_currentcontracts] = train_buyToCover(exitRecord,my_currentcontracts,...
            Date(i),Time(i),exitPrice,lots);
        MarketPosition=0;
        BarsSinceEntry = 0;
        MyEntryPrice = []; %重置开仓价格
    end
    
    %---------------止损主体---------------%
    %=====================================%
    if BarsSinceEntry == 0
        AvgEntryPrice = mean(MyEntryPrice);
        HighestAfterEntry(i) = Close(i);
        LowestAfterEntry(i) = Close(i);
        if MarketPosition ~= 0
            HighestAfterEntry(i) = max(HighestAfterEntry(i),AvgEntryPrice);
            LowestAfterEntry(i) = min(LowestAfterEntry(i),AvgEntryPrice);
        end
    elseif BarsSinceEntry > 0
        HighestAfterEntry(i) = max(HighestAfterEntry(i),High(i));
        LowestAfterEntry(i) = min(LowestAfterEntry(i),Low(i));
    end
    
    temp=AvgEntryPrice; %开仓价格均价
    if MarketPosition==1 && BarsSinceEntry > 0
        if HighestAfterEntry(i-1) > (temp+TrailingStart*MinPoint)
            if (Low(i) < (HighestAfterEntry(i-1) - TrailingStop*MinPoint))
                MyExitPrice = HighestAfterEntry(i-1) - TrailingStop*MinPoint;
                if Open(i) < MyExitPrice
                    MyExitPrice = Open(i);
                end
                [exitRecord,my_currentcontracts] = train_sell(exitRecord,my_currentcontracts,...
                    Date(i),Time(i),MyExitPrice,1);
                MarketPosition = 0;
                BarsSinceEntry = 0;
                MyEntryPrice = []; %重置开仓价格序列
            end
        elseif Low(i) < (temp -StopLossSet*MinPoint)
            MyExitPrice = temp - StopLossSet*MinPoint;
            if Open(i) < MyExitPrice
                MyExitPrice=Open(i);
            end
            [exitRecord,my_currentcontracts] = train_sell(exitRecord,my_currentcontracts,...
                Date(i),Time(i),MyExitPrice,1);
            MarketPosition = 0;
            BarsSinceEntry = 0;
            MyEntryPrice = []; %重置开仓价格序列
        end
    elseif MarketPosition==-1 && BarsSinceEntry > 0
        if LowestAfterEntry(i-1) < (temp - TrailingStart*MinPoint)
            if (High(i) > (LowestAfterEntry(i-1) + TrailingStop*MinPoint))
                MyExitPrice = LowestAfterEntry(i-1) + TrailingStop*MinPoint;
                if Open(i) > MyExitPrice
                    MyExitPrice = Open(i);
                end
                [exitRecord,my_currentcontracts] = train_buyToCover(exitRecord,my_currentcontracts,...
                    Date(i),Time(i),MyExitPrice,1);
                MarketPosition = 0;
                BarsSinceEntry = 0;
                MyEntryPrice = []; %重置开仓价格序列
            end
        elseif High(i) > (temp+StopLossSet*MinPoint)
            MyExitPrice = temp+StopLossSet*MinPoint;
            if Open(i) > MyExitPrice
                MyExitPrice=Open(i);
            end
            [exitRecord,my_currentcontracts] = train_buyToCover(exitRecord,my_currentcontracts,...
                Date(i),Time(i),MyExitPrice,1);
            MarketPosition = 0;
            BarsSinceEntry = 0;
            MyEntryPrice = []; %重置开仓价格序列
        end
    end
end

end