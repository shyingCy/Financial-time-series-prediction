function [entryRecord,exitRecord,my_currentcontracts ] = train_priceAction(data,pro_information,ConOpenTimes,refn,TrailingStart,TrailingStop,StopLossSet)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

%参数
MinPoint = pro_information{3}; %商品最小变动单位

%变量
preciseV = 2e-7; %精度变量，控制两值相等的精度问题
%K线变量
Date = data(:,1);
Time = data(:,2);
Open = data(:,3);
High = data(:,4);
Low = data(:,5);
Close = data(:,6);
barLength = size(Close,1); %K线总量

%策略变量
MyEntryPrice = []; %开仓价格，本例是开仓均价，也可根据需要设置为某次入场的价格
entryRecord = []; %开仓记录
exitRecord = []; %平仓记录
my_currentcontracts = 0;  %持仓手数

HighestAfterEntry=zeros(barLength,1); %开仓后出现的最高价
LowestAfterEntry=zeros(barLength,1); %开仓后出现的最低价
AvgEntryPrice = 0;

MarketPosition = 0;
BarsSinceEntry = -1; %距离最近一次开仓K数量，-1表示没开仓，大于等于0表示在持仓情况下

startPos = 2*refn+1;
highTemp1 = 0;
highTemp2 = 0;
lowTemp1 = 0;
lowTemp2 = 0;

for i=startPos:barLength
    
    if i==9161
        disp(1);
    end
    HighestAfterEntry(i) = HighestAfterEntry(i-1);
    LowestAfterEntry(i) = LowestAfterEntry(i-1);
    if MarketPosition~=0
        BarsSinceEntry = BarsSinceEntry+1;
    end
    
    if High(i-refn)>High(i-1) && High(i-refn)>High(i-2*refn+1)
        highTemp1 = highTemp2;
        highTemp2 = High(i-refn);
    end
    
    if Low(i-refn)<Low(i-1) && Low(i-refn)<Low(i-2*refn+1)
        lowTemp1 = lowTemp2;
        lowTemp2 = Low(i-refn);
    end
    
    if highTemp2 > highTemp1 && lowTemp2 > lowTemp1
        if High(i) > highTemp2
            [entryRecord,exitRecord,my_currentcontracts,isSucess] = train_buy(entryRecord,exitRecord,my_currentcontracts,...
                Date(i),Time(i),max(Open(i),highTemp2),1,ConOpenTimes);
            if isSucess == 1
                BarsSinceEntry = 0;
                MyEntryPrice(1) = max(Open(i),highTemp2);
                MarketPosition = 1;
            end
        end
    end
    
    if highTemp2 < highTemp1 && lowTemp2 < lowTemp1
        if Low(i) < lowTemp2
            [entryRecord,exitRecord,my_currentcontracts,isSucess] = train_sellshort(entryRecord,exitRecord,my_currentcontracts,...
                Date(i),Time(i),min(Open(i),lowTemp2),1,ConOpenTimes);
            if isSucess == 1
                BarsSinceEntry = 0;
                MyEntryPrice(1) = min(Open(i),lowTemp2);
                MarketPosition = -1;
            end
        end
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
        if HighestAfterEntry(i-1) > (temp+TrailingStart*MinPoint) || abs(HighestAfterEntry(i-1) - (temp+TrailingStart*MinPoint)) < preciseV
            if (Low(i) < (HighestAfterEntry(i-1) - TrailingStop*MinPoint)) || abs(Low(i) - (HighestAfterEntry(i-1) - TrailingStop*MinPoint)) < preciseV
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
        elseif Low(i) < (temp -StopLossSet*MinPoint) || abs(Low(i) - (temp -StopLossSet*MinPoint)) < preciseV
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
        if LowestAfterEntry(i-1) < (temp - TrailingStart*MinPoint) || abs(LowestAfterEntry(i-1) - (temp - TrailingStart*MinPoint)) < preciseV
            if (High(i) > (LowestAfterEntry(i-1) + TrailingStop*MinPoint)) || abs(High(i)-(LowestAfterEntry(i-1) + TrailingStop*MinPoint)) < preciseV %这样表示大于或等于
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
        elseif High(i) > (temp+StopLossSet*MinPoint) || abs(High(i) - (temp+StopLossSet*MinPoint)) < preciseV
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

