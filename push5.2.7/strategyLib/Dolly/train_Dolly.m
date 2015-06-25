function [entryRecord,exitRecord,my_currentcontracts] = train_Dolly(data,pro_information,condition,FS,ConOpenTimes)
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
preciseV = 1e-2; %精度变量，控制两值相等的精度问题

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
%调用买卖函数需要的变量
entryRecord = []; %开仓记录
exitRecord = []; %平仓记录
my_currentcontracts = 0;  %持仓手数

%---------以下变量根据需要进行修改--------%
%策略变量
Fmax = FS{1};
Fmin = FS{2};
Smax = FS{3};
Smin = FS{4};
% fast1=3;
% fast2=5;
% fast3=8;
% fast4=10;
% fast5=12;
% fast6=15;
% slow1=30;
% slow2=35;
% slow3=40;
% slow4=45;
% slow5=50;
% slow6=60; 

% fastlength=12;
% slowlength=26;
% MACDlength=9;

% FMACD1=EMA(Close,fast1);
% FMACD2=EMA(Close,fast2);
% FMACD3=EMA(Close,fast3);
% FMACD4=EMA(Close,fast4);
% FMACD5=EMA(Close,fast5);
% FMACD6=EMA(Close,fast6);
% 
% SMACD1=EMA(Close,slow1);
% SMACD2=EMA(Close,slow2);
% SMACD3=EMA(Close,slow3);
% SMACD4=EMA(Close,slow4);
% SMACD5=EMA(Close,slow5);
% SMACD6=EMA(Close,slow6);
% 
% FMACD1=a{1};
% FMACD2=a{2};
% FMACD3=a{3};
% FMACD4=a{4};
% FMACD5=a{5};
% FMACD6=a{6};
% 
% SMACD1=a{7};
% SMACD2=a{8};
% SMACD3=a{9};
% SMACD4=a{10};
% SMACD5=a{11};
% SMACD6=a{12};

% load([pro,'_m1']);
% close_m1=bardata(:,6);
% Date_m1=bardata(:,1)+bardata(:,2);
% load([pro,'_m5']);
% close_m5=bardata(:,6);
% Date_m5=bardata(:,1)+bardata(:,2);
% load([pro,'_m15']);
% close_m15=bardata(:,6);
% Date_m15=bardata(:,1)+bardata(:,2);
% load([pro,'_m30']);
% close_m30=bardata(:,6);
% Date_m30=bardata(:,1)+bardata(:,2);
% load([pro,'_h1']);
% close_h1=bardata(:,6);
% Date_h1=bardata(:,1)+bardata(:,2);
% load([pro,'_h4']);
% close_h4=bardata(:,6);
% Date_h4=bardata(:,1)+bardata(:,2);
% load([pro,'_d1']);
% close_d1=bardata(:,6);
% Date_d1=bardata(:,1)+bardata(:,2);

% newdiff_m1=b{1};
% newdiff_m5=b{2};
% newdiff_m15=b{3};       
% newdiff_m30=b{4};       
% newdiff_h1=b{5};
% Date_m1=c{1};
% Date_m5=c{2};
% Date_m15=c{3};
% Date_m30=c{4};
% Date_h1=c{5};


% diff_m1=MACD(close_m1,fastlength,slowlength,MACDlength);
% diff_m5=MACD(close_m5,fastlength,slowlength,MACDlength);  
% diff_m15=MACD(close_m15,fastlength,slowlength,MACDlength);        
% diff_m30=MACD(close_m30,fastlength,slowlength,MACDlength);        
% diff_h1=MACD(close_h1,fastlength,slowlength,MACDlength);    
% diff_h4=MACD(close_h4,fastlength,slowlength,MACDlength);  
% diff_d1=MACD(close_d1,fastlength,slowlength,MACDlength);  

% refLen = length(FMACD1);
% curDate=Date+Time;

% newdiff_m1=tran(curDate,Date_m1,diff_m1);
% newdiff_m5=tran(curDate,Date_m5,diff_m5);
% newdiff_m15=tran(curDate,Date_m15,diff_m15);
% newdiff_m30=tran(curDate,Date_m30,diff_m30);
% newdiff_h1=tran(curDate,Date_h1,diff_h1);
% newdiff_h4=tran(curDate,curDiff,Date_h4,diff_h4);
% newdiff_d1=tran(curDate,curDiff,Date_d1,diff_d1);

% diff1=zeros(refLen,1);
% diff2=zeros(refLen,1);
% diff3=zeros(refLen,1);
% diff4=zeros(refLen,1);
% diff5=zeros(refLen,1);
% diff6=zeros(refLen,1);
% diff7=zeros(refLen,1);
% diff8=zeros(refLen,1);
% diff9=zeros(refLen,1);
% diff10=zeros(refLen,1);
% Ftrendcond=zeros(refLen,1);
% Strendcond=zeros(refLen,1);
% Ftrend=zeros(refLen,1);
% Strend=zeros(refLen,1); 
% trendsignal=zeros(refLen,1);
% trendmain=zeros(refLen,1);
% tradecon=zeros(refLen,1);
% trendd1=zeros(refLen,1);
% Fmax=zeros(refLen,1);
% Fmin=zeros(refLen,1);
% Smax=zeros(refLen,1);
% Smin=zeros(refLen,1);

MyEntryPrice = []; %开仓价格，本例是开仓均价，也可根据需要设置为某次入场的价格
HighestAfterEntry=zeros(barLength,1); %开仓后出现的最高价
LowestAfterEntry=zeros(barLength,1); %开仓后出现的最低价
AvgEntryPrice = 0;

MarketPosition = 0;
BarsSinceEntry = -1; %距离最近一次开仓K数量，-1表示没开仓，大于等于0表示在持仓情况下
%---------------------------------------%
%---------------------------------------%

%交易
% for i = guppylength+1:refLen
%     f=[FMACD1(i-1),FMACD2(i-1),FMACD3(i-1),FMACD4(i-1),FMACD5(i-1),FMACD6(i-1)];
%     Fmin(i)=min(f);
%     Fmax(i)=max(f);
%   %  Fmin(i) = min(FMACD1(i-1),FMACD2(i-1));
%   %  Fmin(i) = min(Fmin(i),FMACD3(i-1));
%   %  Fmin(i) = min(Fmin(i),FMACD4(i-1));
%  %   Fmin(i) = min(Fmin(i),FMACD5(i-1));
%  %   Fmin(i) = min(Fmin(i),FMACD6(i-1));
%  %   Fmax (i)= max(FMACD1(i-1),FMACD2(i-1));
%  %   Fmax(i) = min(Fmax(i),FMACD3(i-1));
%  %   Fmax(i) = min(Fmax(i),FMACD4(i-1));
%  %   Fmax(i) = min(Fmax(i),FMACD5(i-1));
%  %   Fmax(i)= min(Fmax(i),FMACD6(i-1));   
%     if FMACD1(i)>FMACD1(i-1) && FMACD2(i)>FMACD2(i-1) && FMACD3(i)>FMACD3(i-1) && FMACD4(i)>FMACD4(i-1) && FMACD5(i)>FMACD5(i-1) && FMACD6(i)>FMACD6(i-1)
%         Ftrend(i)=1;
%     else
%         Ftrend(i)=-1;
%     end
%     
%     s=[SMACD1(i-1),SMACD2(i-1),SMACD3(i-1),SMACD4(i-1),SMACD5(i-1),SMACD6(i-1)];
%     Smin(i)=min(s);
%     Smax(i)=max(s); 
%     if SMACD1(i)>SMACD1(i-1) && SMACD2(i)>SMACD2(i-1) && SMACD3(i)>SMACD3(i-1) && SMACD4(i)>SMACD4(i-1) && SMACD5(i)>SMACD5(i-1) && SMACD6(i)>SMACD6(i-1)
%         Strend(i)=1;
%     else
%         Strend(i)=-1;
%     end
%     
%     diff1(i) = abs(FMACD1(i)-FMACD2(i));
%     diff2(i) = abs(FMACD2(i)-FMACD3(i));
%     diff3(i) = abs(FMACD3(i)-FMACD4(i));    
%     diff4(i) = abs(FMACD4(i)-FMACD5(i));
%     diff5(i) = abs(FMACD5(i)-FMACD6(i));  
%     diff6(i) = abs(SMACD1(i)-SMACD2(i));  
%     diff7(i) = abs(SMACD2(i)-SMACD3(i));  
%     diff8(i) = abs(SMACD3(i)-SMACD4(i));  
%     diff9(i) = abs(SMACD4(i)-SMACD5(i));  
%     diff10(i) = abs(SMACD5(i)-SMACD6(i));  
% 
%     count1=0;
%     count2=0;
%     for j=1:guppylength-1
%         if diff1(i-j)-diff1(i-j-1)>diff && diff2(i-j)-diff2(i-j-1)>diff && diff3(i-j)-diff3(i-j-1)>diff && diff4(i-j)-diff4(i-j-1)>diff && diff5(i-j)-diff5(i-j-1)>diff
%             count1=count1+1;
%         elseif diff1(i-j-1)-diff1(i-j)>diff && diff2(i-j-1)-diff2(i-j)>diff && diff3(i-j-1)-diff3(i-j)>diff && diff4(i-j-1)-diff4(i-j)>diff && diff5(i-j-1)-diff5(i-j)>diff
%             count1=count1-1;
%         end
%         if diff6(i-j)-diff6(i-j-1)>diff && diff7(i-j)-diff7(i-j-1)>diff && diff8(i-j)-diff8(i-j-1)>diff && diff9(i-j)-diff9(i-j-1)>diff && diff10(i-j)-diff10(i-j-1)>diff
%             count2=count2+1;
%         elseif diff6(i-j-1)-diff6(i-j)>diff && diff7(i-j-1)-diff7(i-j)>diff && diff8(i-j-1)-diff8(i-j)>diff && diff9(i-j-1)-diff9(i-j)>diff && diff10(i-j-1)-diff10(i-j)>diff
%             count2=count2-1;
%         end
%     end
%     if count1>k*guppylength  %发散
%         Ftrendcond(i)=1;
%     elseif count1<-k*guppylength  %聚拢
%         Ftrendcond(i)=-1;
%     else
%         Ftrendcond(i)=0;  %平行
%     end
%     if count2>k*guppylength  %发散
%         Strendcond(i)=1;
%     elseif count2<-k*guppylength  %聚拢
%         Strendcond(i)=-1;
%     else
%         Strendcond(i)=0;  %平行
%     end
% 
%     if newdiff_m5(i)>0 && newdiff_m1(i)>0
%         trendsignal(i)=1;
%     elseif newdiff_m5(i)<0 && newdiff_m1(i)<0
%         trendsignal(i)=-1;
%     elseif newdiff_m5(i)<0 && newdiff_m1(i)>0
%         trendsignal(i)=0;
%     elseif newdiff_m5(i)>0 && newdiff_m1(i)<0
%         trendsignal(i)=0;  
%     end
%     
%     if newdiff_m15(i)<0 && newdiff_m30(i)>0 && newdiff_h1(i)>0
%         trendmain(i)=1;
%     elseif newdiff_m15(i)>0 && newdiff_m30(i)<0 && newdiff_h1(i)<0
%         trendmain(i)=-1;
%     end
%     if newdiff_m15(i)<0 && newdiff_m30(i)<0 && newdiff_h1(i)>0
%         trendmain(i)=-1;
%     elseif newdiff_m15(i)>0 && newdiff_m30(i)>0 && newdiff_h1(i)<0
%         trendmain(i)=1;
%     end
%     if newdiff_m15(i)<0 && newdiff_m30(i)>0 && newdiff_h1(i)<0
%         trendmain(i)=-1;
%     elseif newdiff_m15(i)>0 && newdiff_m30(i)<0 && newdiff_h1(i)>0
%         trendmain(i)=1; 
%     end
% %     if newdiff_m15(i)>0 && newdiff_m30(i)>0 && newdiff_h1(i)>0 && newdiff_h4(i)>0
% %         trendmain(i)=1;
% %     elseif newdiff_m15(i)<0 && newdiff_m30(i)<0 && newdiff_h1(i)<0 && newdiff_h4(i)<0
% %         trendmain(i)=-1;
% %     end
% %     if newdiff_m15(i)>0 && newdiff_m30(i)>0 && newdiff_h1(i)>0 && newdiff_h4(i)<0
% %         trendmain(i)=1;
% %     elseif newdiff_m15(i)<0 && newdiff_m30(i)<0 && newdiff_h1(i)<0 && newdiff_h4(i)>0
% %         trendmain(i)=-1;
% %     end
%     
%     if newdiff_h1(i)>0
%         trendd1(i)=1;
%     elseif newdiff_h1(i)<0
%         trendd1(i)=-1;
%     end
%     
%     if Strend(i)>0 && Ftrendcond(i)>0 && Strendcond(i)>0
%         tradecon(i)=1;
% 
%     elseif Strend(i)<0 && Strendcond(i-1)>0 && Strendcond(i)<0 && Ftrend(i)>0 && Ftrendcond(i)>0 && Fmax(i)>Smin(i)
%         tradecon(i)=1;
% 
%     elseif Strend(i)>0 && Strendcond(i)<0 && Ftrendcond(i)>0 && Ftrend(i)>0 && Fmax(i)>Smin(i)
%         tradecon(i)=1;
% 
%     elseif Strend(i)>0 && Strendcond(i)>0 && Ftrend(i)>0 && Fmax(i)>Smin(i) % && Strendcond(i-3)==0
%         tradecon(i)=1;
% 
%     elseif Strend(i)<0 && Strendcond(i)>0 && Ftrend(i)<0 && Fmin(i)<Smax(i) % && Strendcond(i-3)==0
%         tradecon(i)=-1;
% 
%     elseif Strend(i)<0 && Strendcond(i)<0 && Ftrend(i)<0 && Ftrendcond(i)>0 && Smax(i)>Fmin(i)
%         tradecon(i)=-1;
% 
%     elseif Strend(i)<0 && Strendcond(i)<0 && Ftrendcond(i)>0 && Smax(i)>Fmin(i)
%         tradecon(i)=-1;
% 
%     elseif Strend(i)<0 && Strendcond(i)>0 && Fmax(i)<Smin(i)
%         tradecon(i)=-1;
%     else 
%         tradecon(i)=tradecon(i-1);        
%     end
% end

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
    
    if MarketPosition~=1 && condition(i-1)>0
        [entryRecord,exitRecord,my_currentcontracts,isSucess] = train_buy(entryRecord,exitRecord,my_currentcontracts,...
            Date(i),Time(i),Open(i),1,ConOpenTimes); %这里只需修改max(Open(i),smallswing(i))，这个是价格
        %isSucess是开仓是否成功的标志
        if isSucess == 1
            BarsSinceEntry = 0;
            MyEntryPrice(1) = Open(i);
            MarketPosition = 1; %需要用到MarketPosition则设置，无需要则删除
        end 
    elseif MarketPosition~=-1  && condition(i-1)<0
        [entryRecord,exitRecord,my_currentcontracts,isSucess] = train_sellshort(entryRecord,exitRecord,my_currentcontracts,...
            Date(i),Time(i),Open(i),1,ConOpenTimes);
        if isSucess == 1
            BarsSinceEntry = 0;
            MyEntryPrice(1) = Open(i);
            MarketPosition = -1;
        end
    elseif (Fmax(i)-Smax(i))*(Fmin(i-1)-Smin(i-1))<0 || (Smin(i)-Fmin(i))*(Smax(i-1)-Fmax(i-1))<0
%         (Fmax(i)-Smin(i))*(Fmin(i-1)-Smax(i-1))<0 || (Smax(i)-Fmin(i))*(Smin(i-1)-Fmax(i-1))<0
        if MarketPosition == 1                            %平仓
            MyExitPrice = Open(i);
            [exitRecord,my_currentcontracts] = train_sell(exitRecord,my_currentcontracts,...
              Date(i),Time(i),MyExitPrice,1);
            MarketPosition = 0;
            BarsSinceEntry = 0;
            MyEntryPrice = []; %重置开仓价格序列
        elseif MarketPosition == -1                      %平仓
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

