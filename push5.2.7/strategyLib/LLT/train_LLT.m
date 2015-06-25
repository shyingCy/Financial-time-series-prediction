function [entryRecord,exitRecord,my_currentcontracts] = train_LLT(data,pro_information,d,q,ConOpenTimes)
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
%MinPoint = pro_information{3}; %商品最小变动单位


%变量
%preciseV = 2e-7; %精度变量，控制两值相等的精度问题

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
% a=2/(Length+1);% α值

MyEntryPrice = []; %开仓价格，本例是开仓均价，也可根据需要设置为某次入场的价格

HighestAfterEntry=zeros(barLength,1); %开仓后出现的最高价
LowestAfterEntry=zeros(barLength,1); %开仓后出现的最低价
AvgEntryPrice = 0;

MarketPosition = 0;
BarsSinceEntry = -1; %距离最近一次开仓K数量，-1表示没开仓，大于等于0表示在持仓情况下
%---------------------------------------%
%---------------------------------------%

%交易


% for i=1:2
%     LLTvalue(i) = Close(i);
% end
% 
% for i = 3:barLength   %计算LLT趋势线
%     LLTvalue(i)=(a-0.25*a^2)*Close(i)+0.5*a^2*Close(i-1)-(a-0.75*a^2)*Close(i-2)+(2-2*a)*LLTvalue(i-1)-(1-a)^2*LLTvalue(i-2);
%  %  LLTvalue(i)=a*Price(i)+(1-a)*LLTvalue(i-1);
% end
%     d=diff(LLTvalue); %求差分
%     
for i=3:barLength
    
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
    
    if MarketPosition~=1 && d(i-2)>q
        [entryRecord,exitRecord,my_currentcontracts,isSucess] = train_buy(entryRecord,exitRecord,my_currentcontracts,...
                Date(i),Time(i),Open(i),1,ConOpenTimes); %这里只需修改max(Open(i),smallswing(i))，这个是价格
        %isSucess是开仓是否成功的标志
        if isSucess == 1
            BarsSinceEntry = 0;
            MyEntryPrice(1) = Open(i);
            MarketPosition = 1; %需要用到MarketPosition则设置，无需要则删除
        end
    end
    if MarketPosition~=-1 && d(i-2)<q
        [entryRecord,exitRecord,my_currentcontracts,isSucess] = train_sellshort(entryRecord,exitRecord,my_currentcontracts,...
                Date(i),Time(i),Open(i),1,ConOpenTimes);
        if isSucess == 1
            BarsSinceEntry = 0;
            MyEntryPrice(1) = Open(i);
            MarketPosition = -1;
        end
    end
     
end

end
