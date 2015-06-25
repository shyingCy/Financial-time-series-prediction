function [entryRecord,exitRecord,my_currentcontracts] = train_EMD(data,pro_information,T0,Rmean,StopLossRate,ConOpenTimes)
%UNTITLED Summary of this function goes here
%运行的机器需先安装EMD相关函数包
%   Detailed explanation goes here


%参数
MinPoint = pro_information{3}; %商品最小变动单位
lots = 1; %交易手数

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
barLength = size(Close,1); %K线总量


%调用买卖函数需要的变量
entryRecord = []; %开仓记录
exitRecord = []; %平仓记录
my_currentcontracts = 0;  %持仓手数

%策略变量
stoploss=zeros(barLength,1); %止损价格
MyEntryPrice = []; %开仓价格，本例是开仓均价，也可根据需要设置为某次入场的价格

HighestAfterEntry=zeros(barLength,1); %开仓后出现的最高价
LowestAfterEntry=zeros(barLength,1); %开仓后出现的最低价
AvgEntryPrice = 0;

MarketPosition = 0;
BarsSinceEntry = 0; %距离最近一次开仓K数量，-1表示没开仓，大于等于0表示在持仓情况下

MarketPosition = 0;

%Times = 0;
%上午开仓点
%从当日开盘后往后推长度为T0的窗口
%Action = datestr(Time(M+1),'HH:MM:SS');
%Action = Time(T0+1);%c窗口长度为T0

%止损比例
%StopLossRate = 0.006;
C = 1 ;
beg = 0;
%从第二天的起点 寻找开盘点
a=day(Date);
b=diff(a);
index=b>0;
Begin = find(index>0,1)+1;
OpenMoment = Time(Begin);%开盘点
Action = Time(Begin + T0);%开仓点 保证窗口长度为T0 - 1

for i=1:barLength-1
    %百分比止损
    if MarketPosition~=0 %开始跟踪止损 若MarketPositon=0 说明已经进行过平仓
        if MarketPosition == 1 %当前看多
            LossRate = (EntryPrice - Close(i-1))/EntryPrice;
            if LossRate > StopLossRate %止损大于阈值
                [exitRecord,my_currentcontracts] = train_sell(exitRecord,my_currentcontracts,...
                    Date(i),Time(i),Open(i),lots);
                MarketPosition = 0;
                EnrtyPrice = [ ];
                %                 GotoNextDay = 1;
            end
        else if MarketPosition == -1 %当前看空
                LossRate = (Close(i-1) - EntryPrice)/EntryPrice;
                if LossRate > StopLossRate %止损大于阈值
                    [exitRecord,my_currentcontracts] = train_buyToCover(exitRecord,my_currentcontracts,...
                        Date(i),Time(i),Open(i),lots);
                    MarketPosition = 0;
                    EnrtyPrice = [ ];
                    %                    GotoNextDay = 1;
                end
            end
        end
    end
    %上午开仓
    if Time(i) == OpenMoment %标记开盘时间
        beg  = i ;
    end
    if (Time(i) == Action) && (beg~=0) %确保已标记开盘点
        winClose = Close(beg:i-1);%窗口长度为T0
        %winClose = Close(i-T0:i-1);%窗口长度为T0
        Output = emd(winClose); %EMD处理
        residue = Output(end,:); %输出的最后一行为剩余项rn;
        R = log(std(winClose'-residue)/std(residue)); %得到判断指标 波动能量比R %winClose需要倒置
        if R < Rmean(C) %市场情绪平稳度小于阈值,说明当日行情趋势明显
            C = C + 1;
            EntryPrice = Open(i);
            %            GoToNextDay = 0; %当天有交易 需要跟踪止损
            if Close(i-1) > Open(beg) %T0时刻股指高于开盘价,做多
                [entryRecord,exitRecord,my_currentcontracts,isSucess] = train_buy(entryRecord,exitRecord,my_currentcontracts,...
                    Date(i),Time(i),EntryPrice,lots,ConOpenTimes);
                %isSucess是开仓是否成功的标志
                if isSucess == 1
                    MyEntryPrice(1) = Open(i);
                    MarketPosition = 1; %需要用到MarketPosition则设置，无需要则删除
                end
            else %t时刻股指低于开盘价,做空
                [entryRecord,exitRecord,my_currentcontracts,isSucess] = train_sellshort(entryRecord,exitRecord,my_currentcontracts,...
                    Date(i),Time(i),EntryPrice,lots,ConOpenTimes);
                if isSucess == 1
                    MyEntryPrice(1) = Open(i);
                    MarketPosition = -1;
                end
            end
        end
    end
    %下午收盘时进行平仓
    %股指平仓时间为15:15:00 非股指为15:00:00
    if  ((((0.6243-Time(i))<0.0001)&&(strcmp(pro_information(1),'IF')~=1))||((0.6347-Time(i))<0.0001))
        %if  ((strcmp(datestr(Time(i),'HH:MM:SS'),'14:59:00')&&(strcmp(pro_information(1),'IF')~=1))||(strcmp(datestr(Time(i),'HH:MM:SS'),'15:14:00')))
        if MarketPosition == 1;
            exitPrice = Close(i);
            [exitRecord,my_currentcontracts] = train_sell(exitRecord,my_currentcontracts,...
                Date(i),Time(i),exitPrice,lots);
            MarketPosition = 0;
            EnrtyPrice = [ ];
        end
        if MarketPosition == -1;
            exitPrice = Close(i);
            [exitRecord,my_currentcontracts] = train_buyToCover(exitRecord,my_currentcontracts,...
                Date(i),Time(i),exitPrice,lots);
            MarketPosition = 0;
            EnrtyPrice = [ ];
        end
        beg = 0;
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
end


end