function [entryRecord,exitRecord,my_currentcontracts] = train_WFFT(data,pro_information,con,ConOpenTimes)
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
% a=2/(1+Length);   %α值
% n=1:N;

MyEntryPrice = []; %开仓价格，本例是开仓均价，也可根据需要设置为某次入场的价格

HighestAfterEntry=zeros(barLength,1); %开仓后出现的最高价
LowestAfterEntry=zeros(barLength,1); %开仓后出现的最低价
AvgEntryPrice = 0;

MarketPosition = 0;
BarsSinceEntry = -1; %距离最近一次开仓K数量，-1表示没开仓，大于等于0表示在持仓情况下
%---------------------------------------%
%---------------------------------------%

%交易
% 
% LLTvalue(1:2) = Close(1:2);    %LLT线初始化
% for i = 2+1:barLength   %计算LLT趋势线
%     LLTvalue(i)=(a-0.25*a^2)*Close(i)+0.5*a^2*Close(i-1)-(a-0.75*a^2)*Close(i-2)+(2-2*a)*LLTvalue(i-1)-(1-a)^2*LLTvalue(i-2);
% end
%     d=diff(LLTvalue); %求差分
%     
%     MA(1:len-1) = Close(1:len-1);    %MA平滑
% for j = len:barLength
%     MA(j) = mean(Close(j-len+1:j));
% end
%     MA = MA-mean(MA); %消除直流分量
%     
% for j = N:barLength
%     y = fft(MA(j-N+1:j));    %对一个时间窗口进行傅里叶变换
%     pow(1:N) = abs(y).^2;    %计算一个时间窗口功率谱强度
%     if j==N                  %计算每个周期的强度
%         S(1:N-1) = (-10/log(10))*log(0.01./(1-(pow(1:N-1)./max(pow(1:N))))) ;
%     end
%     S(j) = (-10/log(10))*log(0.01./(1-(pow(N)./max(pow(1:N))))) ;
%     if S(j)<0
%         S(j) = 0;
%     end
% 
%      %计算权重
%      k(1:N) = abs(q - S(1:N)); 
%      k(j) = abs(q - S(j)); 
% 
%      T(j) = sum(k(j-N+1:j).*n)/sum(k(j-N+1:j));  %求一段时间序列的平均周期
%                                                  %对应即第j个点瞬时周期
% end
             
for i=1:barLength
    if MarketPosition~=1 && con(i)==1    %趋势状态
%         if d(i-2)>Dq    %斜率大于0，做多   
            [entryRecord,exitRecord,my_currentcontracts,isSucess] = train_buy(entryRecord,exitRecord,my_currentcontracts,...
                Date(i),Time(i),Open(i),1,ConOpenTimes); %这里只需修改max(Open(i),smallswing(i))，这个是价格
            %isSucess是开仓是否成功的标志
            if isSucess == 1
                BarsSinceEntry = 0; %无需止损可删除
                MyEntryPrice(1) = Open(i); %无需止损可删除
                MarketPosition = 1; %需要用到MarketPosition则设置，无需要则删除
            end
    end
    if MarketPosition~=-1 && con(i)==-1    %趋势状态
%         if d(i-2)<Dq  %斜率小于0，做空
            [entryRecord,exitRecord,my_currentcontracts,isSucess] = train_sellshort(entryRecord,exitRecord,my_currentcontracts,...
                Date(i),Time(i),Open(i),1,ConOpenTimes);
            if isSucess == 1
                BarsSinceEntry = 0;
                MyEntryPrice(1) = Open(i);
                MarketPosition = -1;
            end
    end
    if con(i)==2
        if MarketPosition == 1
            MyExitPrice = Open(i);
            [exitRecord,my_currentcontracts] = train_sell(exitRecord,my_currentcontracts,...
              Date(i),Time(i),MyExitPrice,1);
            MarketPosition = 0;
            BarsSinceEntry = 0;
            MyEntryPrice = []; %重置开仓价格序列
        elseif MarketPosition == -1
            MyExitPrice = Open(i);
            [exitRecord,my_currentcontracts] = train_buyToCover(exitRecord,my_currentcontracts,...
              Date(i),Time(i),MyExitPrice,1);
            MarketPosition = 0;
            BarsSinceEntry = 0;
            MyEntryPrice = []; %重置开仓价格序列
        end
    end
end

end

