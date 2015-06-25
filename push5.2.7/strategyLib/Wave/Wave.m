function [ output_args ] = Wave(strategy,data,FlagSome,pro_information,ConOpenTimes)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
%参数解释
%strategy:策略名，为字符串
%data为测试数据
%pro_information为商品数据
%ConOpenTimes为连续建仓次数
%以上参数均不用修改
%M,Cycle为策略参数
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
%---------------------------------------%
%---------------------------------------%

%---------以下变量根据需要进行修改--------%
%策略变量
MyEntryPrice = []; %开仓价格，本例是开仓均价，也可根据需要设置为某次入场的价格

HighestAfterEntry=zeros(barLength,1); %开仓后出现的最高价
LowestAfterEntry=zeros(barLength,1); %开仓后出现的最低价
AvgEntryPrice = 0;

MarketPosition = 0;
BarsSinceEntry = -1; %距离最近一次开仓K数量，-1表示没开仓，大于等于0表示在持仓情况下
%---------------------------------------%
%---------------------------------------%

%交易
for i=1:barLength%判断趋势 以次日开盘价交易 -1防止超出
    if(FlagSome(i) == -1)%相量进入一二象限 看空           %查看此次"<"or">".
        isSucess = sellshort(strategy,Date(i),Time(i),Open(i),1,ConOpenTimes);
        if isSucess == 1
            BarsSinceEntry = 0;
            MyEntryPrice(1) = Open(i);
            MarketPosition = -1;
        end
    end
    if(FlagSome(i) == 1)%看多
        isSucess = buy(strategy,Date(i),Time(i),Open(i),1,ConOpenTimes);
        %isSucess是开仓是否成功的标志
        if isSucess == 1
            BarsSinceEntry = 0; %无需止损可删除
            MyEntryPrice(1) = Open(i); %无需止损可删除
            MarketPosition = 1; %需要用到MarketPosition则设置，无需要则删除
        end
    end
end
end

