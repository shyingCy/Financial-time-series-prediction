function [entryRecord,exitRecord,my_currentcontracts] = train_Wave(data,FlagSome,pro_information,ConOpenTimes)
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
%参数
MinPoint = pro_information{3}; %商品最小变动单位


%变量
preciseV = 2e-7; %精度变量，控制两值相等的精度问题

%变量
%K线变量
Date = data(:,1);
Time = data(:,2);
Open = data(:,3);
High = data(:,4);
Low = data(:,5);
Close = data(:,6);
barLength = size(Date,1); %K线总量

%调用买卖函数需要的变量
entryRecord = []; %开仓记录
exitRecord = []; %平仓记录
my_currentcontracts = 0;  %持仓手数

%---------------------------------------%
%---------------------------------------%

%---------以下变量根据需要进行修改--------%
%策略变量
% largeswing = myZigZag(Close,n);
MyEntryPrice = []; %开仓价格，本例是开仓均价，也可根据需要设置为某次入场的价格

HighestAfterEntry=zeros(barLength,1); %开仓后出现的最高价
LowestAfterEntry=zeros(barLength,1); %开仓后出现的最低价
AvgEntryPrice = 0;

MarketPosition = 0;
BarsSinceEntry = -1; %距离最近一次开仓K数量，-1表示没开仓，大于等于0表示在持仓情况下
%---------------------------------------%
%---------------------------------------%

    %-----这里的设置是为了止损，无需止损则可删掉------%
    %涉及到止损的变量是HighestAfterEntry，LowestAfterEntry，BarsSinceEntry，MyEntryPrice
%     if i > 1
%         HighestAfterEntry(i) = HighestAfterEntry(i-1);
%         LowestAfterEntry(i) = LowestAfterEntry(i-1);
%     end
%     if MarketPosition~=0
%         BarsSinceEntry = BarsSinceEntry+1;
%     end
    %-----------------------------------------------%
    %-----------------------------------------------%
%判断趋势
%交易
for i=1:barLength%判断趋势 以次日开盘价交易 -1防止超出
    if(FlagSome(i) == -1)%相量进入一二象限 看空           %查看此次"<"or">".
        [entryRecord,exitRecord,my_currentcontracts,isSucess] = train_sellshort(entryRecord,exitRecord,my_currentcontracts,...
            Date(i),Time(i),Open(i),1,ConOpenTimes);
        if isSucess == 1
            BarsSinceEntry = 0;
            MyEntryPrice(1) = Open(i);
            MarketPosition = -1;
        end
    end
    if(FlagSome(i) == 1)%相量进入三四象限 看多
        [entryRecord,exitRecord,my_currentcontracts,isSucess] = train_buy(entryRecord,exitRecord,my_currentcontracts,...
            Date(i),Time(i),Open(i),1,ConOpenTimes); %这里只需修改max(Open(i),smallswing(i))，这个是价格
        %isSucess是开仓是否成功的标志
        if isSucess == 1
            BarsSinceEntry = 0; %无需止损可删除
            MyEntryPrice(1) = Open(i); %无需止损可删除
            MarketPosition = 1; %需要用到MarketPosition则设置，无需要则删除
        end
    end
end
    %---------------止损主体---------------%
    %=====================================%
%     if BarsSinceEntry == 0
%         AvgEntryPrice = mean(MyEntryPrice);
%         HighestAfterEntry(i) = Close(i);
%         LowestAfterEntry(i) = Close(i);
%         if MarketPosition ~= 0
%             HighestAfterEntry(i) = max(HighestAfterEntry(i),AvgEntryPrice);
%             LowestAfterEntry(i) = min(LowestAfterEntry(i),AvgEntryPrice);
%         end
%     elseif BarsSinceEntry > 0
%         HighestAfterEntry(i) = max(HighestAfterEntry(i),High(i));
%         LowestAfterEntry(i) = min(LowestAfterEntry(i),Low(i));
%     end
%     
%     temp=AvgEntryPrice; %开仓价格均价
%     if MarketPosition==1 && BarsSinceEntry > 0
%         if HighestAfterEntry(i-1) > (temp+TrailingStart*MinPoint) || abs(HighestAfterEntry(i-1) - (temp+TrailingStart*MinPoint)) < preciseV
%             if (Low(i) < (HighestAfterEntry(i-1) - TrailingStop*MinPoint)) || abs(Low(i) - (HighestAfterEntry(i-1) - TrailingStop*MinPoint)) < preciseV
%                 MyExitPrice = HighestAfterEntry(i-1) - TrailingStop*MinPoint;
%                 if Open(i) < MyExitPrice
%                     MyExitPrice = Open(i);
%                 end
%                 [exitRecord,my_currentcontracts] = train_sell(exitRecord,my_currentcontracts,...
%                     Date(i),Time(i),MyExitPrice,1);
%                 MarketPosition = 0;
%                 BarsSinceEntry = 0;
%                 MyEntryPrice = []; %重置开仓价格序列
%             end
%         elseif Low(i) < (temp -StopLossSet*MinPoint) || abs(Low(i) - (temp -StopLossSet*MinPoint)) < preciseV
%             MyExitPrice = temp - StopLossSet*MinPoint;
%             if Open(i) < MyExitPrice
%                 MyExitPrice=Open(i);
%             end
%             [exitRecord,my_currentcontracts] = train_sell(exitRecord,my_currentcontracts,...
%                 Date(i),Time(i),MyExitPrice,1);
%             MarketPosition = 0;
%             BarsSinceEntry = 0;
%             MyEntryPrice = []; %重置开仓价格序列
%         end
%     elseif MarketPosition==-1 && BarsSinceEntry > 0
%         if LowestAfterEntry(i-1) < (temp - TrailingStart*MinPoint) || abs(LowestAfterEntry(i-1) - (temp - TrailingStart*MinPoint)) < preciseV
%             if (High(i) > (LowestAfterEntry(i-1) + TrailingStop*MinPoint)) || abs(High(i)-(LowestAfterEntry(i-1) + TrailingStop*MinPoint)) < preciseV %这样表示大于或等于
%                 MyExitPrice = LowestAfterEntry(i-1) + TrailingStop*MinPoint;
%                 if Open(i) > MyExitPrice
%                     MyExitPrice = Open(i);
%                 end
%                 [exitRecord,my_currentcontracts] = train_buyToCover(exitRecord,my_currentcontracts,...
%                     Date(i),Time(i),MyExitPrice,1);
%                 MarketPosition = 0;
%                 BarsSinceEntry = 0;
%                 MyEntryPrice = []; %重置开仓价格序列
%             end
%         elseif High(i) > (temp+StopLossSet*MinPoint) || abs(High(i) - (temp+StopLossSet*MinPoint)) < preciseV
%             MyExitPrice = temp+StopLossSet*MinPoint;
%             if Open(i) > MyExitPrice
%                 MyExitPrice=Open(i);
%             end
%             [exitRecord,my_currentcontracts] = train_buyToCover(exitRecord,my_currentcontracts,...
%                 Date(i),Time(i),MyExitPrice,1);
%             MarketPosition = 0;
%             BarsSinceEntry = 0;
%             MyEntryPrice = []; %重置开仓价格序列
%         end
%     end
% end

end

