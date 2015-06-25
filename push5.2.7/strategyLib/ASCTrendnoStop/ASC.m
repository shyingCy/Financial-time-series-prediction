function [ value2 ] = ASC( strategy,data,pro_information,risk )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
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
value10 = 3 + risk*2;
value11 = value10;
% x1 = 67 + risk;
% x2 = 33 - risk;
TrueCount = 0;

WPR = zeros(barLength,1);
value2 = zeros(barLength,1);
% MyEntryPrice = []; %开仓价格，本例是开仓均价，也可根据需要设置为某次入场的价格
% 
% HighestAfterEntry=zeros(barLength,1); %开仓后出现的最高价
% LowestAfterEntry=zeros(barLength,1); %开仓后出现的最低价
% AvgEntryPrice = 0;
% 
% MarketPosition = 0;
% BarsSinceEntry = -1; %距离最近一次开仓K数量，-1表示没开仓，大于等于0表示在持仓情况下
%---------------------------------------%
%---------------------------------------%

%交易
if barLength > value10
    
for i=value10+1:barLength
    Range = sum(High(i-10:i-1)-Low(i-10:i-1))/10;
    j = 1;
    while (j<=10) && (TrueCount<1)
        if abs(Open(i-j)-Close(i-j))>= Range*2
            TrueCount = TrueCount + 1;
        end
        j = j+1;
    end
    if TrueCount >= 1
        MRO1 = j;
    else
        MRO1 = -1;
    end 

    j = 1;
    TrueCount = 0;
    while (j<7) && (TrueCount<1)
        if(abs(Close(i-j-3)-Close(i-j))>=Range*4.6)
            TrueCount = TrueCount + 1;
        end
        j = j+1;
    end
    if(TrueCount>=1)
        MRO2 = j;
    else
        MRO2 = -1;
    end

    if MRO1>-1
        value11 = 3;
    else
        value11 = value10;
    end
    if MRO2>-1
        value11 = 4;
    else
        value11 = value10;
    end

    iHigh = max(High(i-value11+1:i));
    iLow = min(Low(i-value11+1:i));
    WPR(i) = (Close(i-value11)-iHigh)/(iHigh-iLow)*100;
    value2(i) = 100 - abs(WPR(i-1));
end
end
end

