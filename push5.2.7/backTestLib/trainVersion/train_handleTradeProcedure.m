function [tradeTime,Marketposition,StaticEquity,DynamicEquity,LongMargin,ShortMargin] = train_handleTradeProcedure(bardata,traderecord,TradingUnits,MarginRatio,TradingCost_info)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

%fprintf('\n%s\n','正在处理交易过程...');
[m,n] = size(traderecord);
recordRows = m;

%提取出交易记录中数据
Type(:,1) = traderecord(:,1);                   %多空头类型

entryTime = traderecord(:,2) + traderecord(:,3);    %开仓时间
exitTime = traderecord(:,5) + traderecord(:,6);     %平仓时间

entryprice(:,1) = traderecord(:,4);             %开仓价格
exitprice(:,1) = traderecord(:,7);     %平仓价格
lots(:,1) = traderecord(:,8);         %手数

[m,n] = size(bardata);
Close = bardata(:,6);
barLength = m;

tradeTime = bardata(:,1) + bardata(:,2);    %交易时间

%模拟全程交易变量设置
entrypos = 1;   %跟踪开仓时间
exitpos = 1;    %跟踪平仓时间
Marketposition = zeros(barLength,1);
myOpenIntRecord = zeros(1,2);   %记录持仓记录，第一个元素为建仓记录下标，第二条为对应此建仓记录总的手数
myOpenInt = zeros(barLength,1);          %记录目前持仓量
openIntLength = 0;
startPos = find(tradeTime==entryTime(1,:));   %找出第一次开仓的时间

%记录资产变化变量
LongMargin=zeros(barLength,1);              %多头保证金
ShortMargin=zeros(barLength,1);             %空头保证金
DynamicEquity=repmat(1e6,barLength,1);      %动态权益,初始资金为100W
StaticEquity=repmat(1e6,barLength,1);       %静态权益,初始资金为100W

for i=startPos:barLength
    if i > 1
        myOpenInt(i) = myOpenInt(i-1);
        Marketposition(i) = Marketposition(i-1);
    end
    %计算资产变化
    OpenPosPrice = 0;
    my_profit = 0;      %收益归零
    
    %模拟交易过程
    %处理开仓记录
    while entrypos<=recordRows && tradeTime(i,:)==entryTime(entrypos,:) %用while处理同一时间连续建仓
        if Type(entrypos)==1
            Marketposition(i) = 1;
        else
            Marketposition(i) = -1;
        end
        openIntLength = openIntLength + 1;
        myOpenIntRecord(openIntLength,1:2) = [entrypos,lots(entrypos)];
        entrypos = entrypos + 1;
    end
    %处理平仓记录
    while exitpos<=recordRows && tradeTime(i,:)==exitTime(exitpos,:)    %用while处理同一时间以不同价格平仓,此处无需考虑有平仓记录而此时myOpenIntRecord已经为空，
        exitNum = lots(exitpos);   %算出平仓手数                         %这种情况在本质上是不可能出现，因为必须有建仓才有平仓
        k = 1;
        while k <= openIntLength
            if myOpenIntRecord(k,2) == exitNum   %平仓数等于第一条建仓数
                exit_OpenPosPrice = entryprice(myOpenIntRecord(k,1));
                my_profit = my_profit + train_compProfit(Type(myOpenIntRecord(k,1)),exitprice(exitpos),exit_OpenPosPrice,TradingUnits,exitNum,TradingCost_info);
                myOpenIntRecord(k,:) = [];
                k = k -1;
                openIntLength = openIntLength - 1;
                exitpos = exitpos+1;
                break;      %平仓完成跳出循环
            elseif myOpenIntRecord(k,2) > exitNum     %第一条建仓记录建仓数大于平仓数
                myOpenIntRecord(k,2) =  myOpenIntRecord(k,2)-exitNum;
                exit_OpenPosPrice = entryprice(myOpenIntRecord(k,1));
                my_profit = my_profit + train_compProfit(Type(myOpenIntRecord(k,1)),exitprice(exitpos),exit_OpenPosPrice,TradingUnits,exitNum,TradingCost_info); %算收益的开仓价格是平仓对应的开仓记录，但算权益的开仓价格是现有持仓的所有开仓价格
                exitpos = exitpos+1;
                break;   %平仓完成跳出循环
            else            %第一条建仓记录建仓数小于平仓数，继续检查建仓记录
                lots(exitpos) = exitNum - myOpenIntRecord(k,2);      %重置exitpos处的平仓手数
                exit_OpenPosPrice = entryprice(myOpenIntRecord(k,1));
                my_profit = my_profit + train_compProfit(Type(myOpenIntRecord(k,1)),exitprice(exitpos),exit_OpenPosPrice,TradingUnits,exitNum,TradingCost_info); %算收益的开仓价格是平仓对应的开仓记录，但算权益的开仓价格是现有持仓的所有开仓价格
                myOpenIntRecord(k,:)=[];
                k = k-1;
                openIntLength = openIntLength - 1;
            end
            k = k + 1;
        end

    end
    
    myOpenInt(i) = sum(myOpenIntRecord(:,2));
    if myOpenInt(i) == 0
        Marketposition(i) = 0;
    else
        for num=1:length(myOpenIntRecord(:,1))
            OpenPosPrice = OpenPosPrice+entryprice(myOpenIntRecord(num,1))*myOpenIntRecord(num,2);    %开仓用资金
        end
    end
    if i>1
        if Marketposition(i) == 0
            LongMargin(i)=0;                            %多头保证金
            ShortMargin(i)=0;                           %空头保证金
            StaticEquity(i)=StaticEquity(i-1)+my_profit;          %静态权益
            DynamicEquity(i)=StaticEquity(i);           %动态权益
        elseif Marketposition(i) == 1
            LongMargin(i)=Close(i)*myOpenInt(i)*TradingUnits*MarginRatio;
            ShortMargin(i) = 0;
            StaticEquity(i)=StaticEquity(i-1)+my_profit;
            DynamicEquity(i)=StaticEquity(i)+(Close(i)*myOpenInt(i)-OpenPosPrice)*TradingUnits;
        else
            LongMargin(i) = 0;
            ShortMargin(i)=Close(i)*myOpenInt(i)*TradingUnits*MarginRatio;
            StaticEquity(i)=StaticEquity(i-1)+my_profit;
            DynamicEquity(i)=StaticEquity(i)+(OpenPosPrice-Close(i)*myOpenInt(i))*TradingUnits;
        end
    end
end
%fprintf('\n%s\n','处理交易过程完毕...');
end


