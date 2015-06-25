function [ ] = MES(strategy,data,pro_information,M,E,StopLossRate,ConOpenTimes)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
%需保证data开始第一条bar为当日开盘时的bar
%M为上午开仓时间
%N为下午开仓时间
%E为开仓阈值
%StopLossRate为止损百分比

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

%策略变量
MyEntryPrice = []; %开仓价格，本例是开仓均价，也可根据需要设置为某次入场的价格

MarketPosition = 0;

%GG = 1;
%上午开仓点
%从当日开盘后往后推长度为M的窗口
%Action = datestr(Time(M+1),'HH:MM:SS');
Action = Time(M+1);
for i=1:barLength-1
    %百分比止损
    if MarketPosition~=0 %开始跟踪止损 若MarketPositon=0 说明已经进行过平仓
        if MarketPosition == 1 %当前看多
            LossRate = (EntryPrice - Close(i-1))/EntryPrice;
            if LossRate > StopLossRate %止损大于阈值
                sell(strategy,Date(i),Time(i),Open(i),1);
                MarketPosition = 0;
                EnrtyPrice = [ ];
                %                 GotoNextDay = 1;
            end
        else if MarketPosition == -1 %当前看空
                LossRate = (Close(i-1) - EntryPrice)/EntryPrice;
                if LossRate > StopLossRate %止损大于阈值
                    buyToCover(strategy,Date(i),Time(i),Open(i),1);
                    MarketPosition = 0;
                    EnrtyPrice = [ ];
                    %                    GotoNextDay = 1;
                end
            end
        end
    end
    %上午开仓
    if Time(i) == Action 
        for t = 1:M
            winClose = Close(i-M:i-M-1+t);
            DT = winClose - Close(i-M-1+t);%一个窗口减去当前收盘价Close(i-M-1+t)
            %最大回撤
            if isempty(DT(find(DT>0)))==1
                DDser(t) = 0;
            else
                DDser(t) = max((DT(find(DT>0)))/Close(i-M-1+t));
            end
            %反向最大回撤
            if isempty(DT(find(DT<0)))==1
                RDDser(t) = 0;
            else
                RDDser(t) = -min((DT(find(DT<0)))/Close(i-M-1+t));
            end
        end
        MDD = sum(DDser)/M;%平均最大回撤
        MRDD = sum(RDDser)/M;%平均反向最大回撤
        Emotion = min(MDD,MRDD);%市场情绪稳定度
%         saveEmotion(GG) = Emotion;
%         GG = GG + 1;
        if Emotion < E %市场情绪平稳度小于阈值,说明当日行情趋势明显
            EntryPrice = Open(i);
            %            GoToNextDay = 0; %当天有交易 需要跟踪止损
            if Close(i-1) > Close(i-M) %t时刻股指高于开盘价,做多
                isSucess = buy(strategy,Date(i),Time(i),Open(i),1,ConOpenTimes);
                %isSucess是开仓是否成功的标志
                if isSucess == 1
                    MyEntryPrice(1) = Open(i);
                    MarketPosition = 1; %需要用到MarketPosition则设置，无需要则删除
                end
            else %t时刻股指低于开盘价,做空
                isSucess = sellshort(strategy,Date(i),Time(i),Open(i),1,ConOpenTimes);
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
            sell(strategy,Date(i),Time(i),exitPrice,lots);
            MarketPosition = 0;
            EnrtyPrice = [ ];
        end
        if MarketPosition == -1;
            exitPrice = Close(i);
            buyToCover(strategy,Date(i),Time(i),exitPrice,lots);
            MarketPosition = 0;
            EnrtyPrice = [ ];
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
    %                 sell(strategy,Date(i),Time(i),MyExitPrice,1);
    %                 MarketPosition = 0;
    %                 BarsSinceEntry = 0;
    %                 MyEntryPrice = []; %重置开仓价格序列
    %             end
    %         elseif Low(i) < (temp -StopLossSet*MinPoint) || abs(Low(i) - (temp -StopLossSet*MinPoint)) < preciseV
    %             MyExitPrice = temp - StopLossSet*MinPoint;
    %             if Open(i) < MyExitPrice
    %                 MyExitPrice=Open(i);
    %             end
    %             sell(strategy,Date(i),Time(i),MyExitPrice,1);
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
    %                 buyToCover(strategy,Date(i),Time(i),MyExitPrice,1);
    %                 MarketPosition = 0;
    %                 BarsSinceEntry = 0;
    %                 MyEntryPrice = []; %重置开仓价格序列
    %             end
    %         elseif High(i) > (temp+StopLossSet*MinPoint) || abs(High(i) - (temp+StopLossSet*MinPoint)) < preciseV
    %             MyExitPrice = temp+StopLossSet*MinPoint;
    %             if Open(i) > MyExitPrice
    %                 MyExitPrice=Open(i);
    %             end
    %             buyToCover(strategy,Date(i),Time(i),MyExitPrice,1);
    %             MarketPosition = 0;
    %             BarsSinceEntry = 0;
    %             MyEntryPrice = []; %重置开仓价格序列
    %         end
    %     end
    % end
    
end