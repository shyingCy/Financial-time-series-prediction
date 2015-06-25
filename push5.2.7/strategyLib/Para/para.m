function [ output_args ] = para(strategy,data,pro_information,chris,pink,ConOpenTimes)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
%参数解释
%strategy:策略名，为字符串
%data为测试数据
%pro_information为商品数据
%ConOpenTimes为连续建仓次数
%以上参数均不用修改
%chris,pink为策略参数
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
%创建初始两条曲线
%第一条
begin=1;
y1=Close(1:chris);
x=1:chris;
num=polyfit2(x,y1');
%num=polyfit(x,y1',2);
a1=num(1);b1=num(2);
%第二条
y2=Close(1:chris+1);
x=1:chris+1;
num=polyfit2(x,y2');
%num=polyfit(x,y2',2);
a2=num(1);b2=num(2);
%work为判断拐点是否确认的时刻
work=0;
%若第一天就出现拐点的情况
if((2*a1*(chris+1)+b1)*(2*a2*(chris+1)+b2)<=0)
    work=chris+pink;
    a0=a2;b0=b2;
end
%依次生成新曲线
%每天生成
for i=chris+2:barLength-1
        
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
    
    %更新数据
    %a1为前一天,a2为最新,a0为拐点出现的一天
    if((i-begin)>chris)%在bar数目小于chris之前,不进行拟合
        y2=Close(begin:i);
        x=(begin:i);
        %x=(1:i-begin+1);
        num=polyfit2(x,y2');
        %num=polyfit(x,y2',2);
        a1=a2;b1=b2;
        a2=num(1);b2=num(2);%此处逻辑有误(?),但效果无误.10.13未解决
        if(i==work)%验证拐点
            if((a0*a2)>0)%趋势可信,确认拐点
                if(a2>0) %大趋势升
                    isSucess = buy(strategy,Date(i+1),Time(i+1),Open(i+1),1,ConOpenTimes); %这里只需修改max(Open(i),smallswing(i))，这个是价格
                    %isSucess是开仓是否成功的标志
                    if isSucess == 1
                        BarsSinceEntry = 0;
                        MyEntryPrice(1) = Open(i+1);
                        MarketPosition = 1; %需要用到MarketPosition则设置，无需要则删除
                    end
                    %待补充各项记录操作
                else %大趋势跌
                    isSucess = sellshort(strategy,Date(i+1),Time(i+1),Open(i+1),1,ConOpenTimes);
                    if isSucess == 1
                        BarsSinceEntry = 0;
                        MyEntryPrice(1) = Open(i+1);
                        MarketPosition = -1;
                    end
                end
                begin=i;
            end
        else
            if(work>i);%在拐点已出现,但未确认期间,不进行操作
            else
                %判断拐点是否出现
                %多余变量方便观察
                d1=2*a1*i+b1;
                d2=2*a2*i+b2;
                if(d1*d2<=0.001)%拐点出现 重点问题!
                    work=i+pink;
                    a0=a2;b0=b2;%保留此时拟合抛物线参数
                end
            end
        end
    else continue;
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

