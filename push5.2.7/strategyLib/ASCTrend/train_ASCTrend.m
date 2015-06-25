function [entryRecord,exitRecord,my_currentcontracts] = train_ASCTrend(data,pro_information,risk,TrailingStart,TrailingStop,StopLossSet,value2,ConOpenTimes)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
%参数解释
%strategy:策略名，为字符串
%data为测试数据
%pro_information为商品数据
%ConOpenTimes为连续建仓次数
%以上参数均不用修改
%k,n为策略参数
%TrailingStart,TrailingStop,StopLossSet是止损参数，若需要止损则必须加

%------以下为固定参数，无需修改--------%
% 参数
MinPoint = pro_information{3}; %商品最小变动单位


%变量
preciseV = 2e-7; %精度变量，控制两值相等的精度问题
% 
% %变量
%K线变量
Date = data(:,1);
Time = data(:,2);
Open = data(:,3);
High = data(:,4);
Low = data(:,5);
Close = data(:,6);
barLength = size(Date,1); %K线总量
% 
%调用买卖函数需要的变量
entryRecord = []; %开仓记录
exitRecord = []; %平仓记录
my_currentcontracts = 0;  %持仓手数

% %---------------------------------------%
% %---------------------------------------%
% 
% %---------以下变量根据需要进行修改--------%
% %策略变量
value10 = 3 + risk*2;
% value11 = value10;
x1 = 67 + risk;
x2 = 33 - risk;
% TrueCount = 0;
% value2 = zeros(barLength);

MyEntryPrice = []; %开仓价格，本例是开仓均价，也可根据需要设置为某次入场的价格

HighestAfterEntry=zeros(barLength,1); %开仓后出现的最高价
LowestAfterEntry=zeros(barLength,1); %开仓后出现的最低价
AvgEntryPrice = 0;

MarketPosition = 0;
BarsSinceEntry = -1; %距离最近一次开仓K数量，-1表示没开仓，大于等于0表示在持仓情况下
% %---------------------------------------%
% %---------------------------------------%
% 
% %交易
% for i=value10+1:barLength
%     Range = sum(High(i-10:i-1)-Low(i-10:i-1))/10;
%     j = 1;
%     while j<=10 && TrueCount<1
%         if abs(Open(i-j)-Close(i-j))>= Range*2
%             TrueCount = TrueCount + 1;
%         end
%         j = j+1;
%     end
%     if TrueCount >= 1
%         MRO1 = j;
%     else
%         MRO1 = -1;
%     end 
% 
%     j = 1;
%     TrueCount = 0;
%     while j<7 && TrueCount<1
%         if(abs(Close(i-j-3)-Close(i-j))>=Range*4.6)
%             TrueCount = TrueCount + 1;
%         end
%         j = j+1;
%     end
%     if(TrueCount>=1)
%         MRO2 = j;
%     else
%         MRO2 = -1;
%     end
% 
%     if MRO1>-1
%         value11 = 3;
%     else
%         value11 = value10;
%     end
%     if MRO2>-1
%         value11 = 4;
%     else
%         value11 = value10;
%     end
%     
%     iHigh = max(High(i-value11:i-1));
%     iLow = min(Low(i-value11:i-1));
%     WPR = (Close(i-value11)-iHigh)/(iHigh-iLow)*100;
%     value2(i) = 100 - abs(WPR);
for i = 2:barLength
    %-----这里的设置是为了止损，无需止损则可删掉------%
    %涉及到止损的变量是HighestAfterEntry，LowestAfterEntry，BarsSinceEntry，MyEntryPrice
    if i > 1
        HighestAfterEntry(i) = HighestAfterEntry(i-1);
        LowestAfterEntry(i) = LowestAfterEntry(i-1);
    end
    if MarketPosition~=0
        BarsSinceEntry = BarsSinceEntry+1;
    end
    %-----------------------------------------------%
    %-----------------------------------------------%
    
    if MarketPosition~=1 && value2(i-1)<x2
        [entryRecord,exitRecord,my_currentcontracts,isSucess] = train_buy(entryRecord,exitRecord,my_currentcontracts,...
            Date(i),Time(i),Open(i),1,ConOpenTimes); %这里只需修改max(Open(i),smallswing(i))，这个是价格
        %isSucess是开仓是否成功的标志
        if isSucess == 1
            BarsSinceEntry = 0;
            MyEntryPrice(1) = Open(i);
            MarketPosition = 1; %需要用到MarketPosition则设置，无需要则删除
        end
    end
    if MarketPosition~=-1 && value2(i-1)>x1
        [entryRecord,exitRecord,my_currentcontracts,isSucess] = train_sellshort(entryRecord,exitRecord,my_currentcontracts,...
            Date(i),Time(i),Open(i),1,ConOpenTimes);
        if isSucess == 1
            BarsSinceEntry = 0;
            MyEntryPrice(1) = Open(i);
            MarketPosition = -1;
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

