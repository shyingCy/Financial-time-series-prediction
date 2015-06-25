function [condition,FS] = Dollycondition(data,guppylength,diff,k,a,b,c)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

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

%---------以下变量根据需要进行修改--------%
%策略变量
FMACD1=a{1};
FMACD2=a{2};
FMACD3=a{3};
FMACD4=a{4};
FMACD5=a{5};
FMACD6=a{6};

SMACD1=a{7};
SMACD2=a{8};
SMACD3=a{9};
SMACD4=a{10};
SMACD5=a{11};
SMACD6=a{12};

newdiff_m1=b{1};
newdiff_m5=b{2};
newdiff_m15=b{3};       
newdiff_m30=b{4};       
newdiff_h1=b{5};
Date_m1=c{1};
Date_m5=c{2};
Date_m15=c{3};
Date_m30=c{4};
Date_h1=c{5};

refLen = length(FMACD1);

diff1=zeros(refLen,1);
diff2=zeros(refLen,1);
diff3=zeros(refLen,1);
diff4=zeros(refLen,1);
diff5=zeros(refLen,1);
diff6=zeros(refLen,1);
diff7=zeros(refLen,1);
diff8=zeros(refLen,1);
diff9=zeros(refLen,1);
diff10=zeros(refLen,1);
Ftrendcond=zeros(refLen,1);
Strendcond=zeros(refLen,1);
Ftrend=zeros(refLen,1);
Strend=zeros(refLen,1); 
trendsignal=zeros(refLen,1);
trendmain=zeros(refLen,1);
tradecon=zeros(refLen,1);
trendd1=zeros(refLen,1);
Fmax=zeros(refLen,1);
Fmin=zeros(refLen,1);
Smax=zeros(refLen,1);
Smin=zeros(refLen,1);
condition=zeros(refLen,1);


MyEntryPrice = []; %开仓价格，本例是开仓均价，也可根据需要设置为某次入场的价格
HighestAfterEntry=zeros(barLength,1); %开仓后出现的最高价
LowestAfterEntry=zeros(barLength,1); %开仓后出现的最低价
AvgEntryPrice = 0;

MarketPosition = 0;
BarsSinceEntry = -1; %距离最近一次开仓K数量，-1表示没开仓，大于等于0表示在持仓情况下
%---------------------------------------%
%---------------------------------------%

%交易
for i = guppylength+1:refLen
    f=[FMACD1(i-1),FMACD2(i-1),FMACD3(i-1),FMACD4(i-1),FMACD5(i-1),FMACD6(i-1)];
    Fmin(i)=min(f);
    Fmax(i)=max(f);

    if FMACD1(i)>FMACD1(i-1) && FMACD2(i)>FMACD2(i-1) && FMACD3(i)>FMACD3(i-1) && FMACD4(i)>FMACD4(i-1) && FMACD5(i)>FMACD5(i-1) && FMACD6(i)>FMACD6(i-1)
        Ftrend(i)=1;
    else
        Ftrend(i)=-1;
    end
    
    s=[SMACD1(i-1),SMACD2(i-1),SMACD3(i-1),SMACD4(i-1),SMACD5(i-1),SMACD6(i-1)];
    Smin(i)=min(s);
    Smax(i)=max(s); 
    if SMACD1(i)>SMACD1(i-1) && SMACD2(i)>SMACD2(i-1) && SMACD3(i)>SMACD3(i-1) && SMACD4(i)>SMACD4(i-1) && SMACD5(i)>SMACD5(i-1) && SMACD6(i)>SMACD6(i-1)
        Strend(i)=1;
    else
        Strend(i)=-1;
    end
    
    diff1(i) = abs(FMACD1(i)-FMACD2(i));
    diff2(i) = abs(FMACD2(i)-FMACD3(i));
    diff3(i) = abs(FMACD3(i)-FMACD4(i));    
    diff4(i) = abs(FMACD4(i)-FMACD5(i));
    diff5(i) = abs(FMACD5(i)-FMACD6(i));  
    diff6(i) = abs(SMACD1(i)-SMACD2(i));  
    diff7(i) = abs(SMACD2(i)-SMACD3(i));  
    diff8(i) = abs(SMACD3(i)-SMACD4(i));  
    diff9(i) = abs(SMACD4(i)-SMACD5(i));  
    diff10(i) = abs(SMACD5(i)-SMACD6(i));  

    count1=0;
    count2=0;
    for j=1:guppylength-1
        if diff1(i-j)-diff1(i-j-1)>diff && diff2(i-j)-diff2(i-j-1)>diff && diff3(i-j)-diff3(i-j-1)>diff && diff4(i-j)-diff4(i-j-1)>diff && diff5(i-j)-diff5(i-j-1)>diff
            count1=count1+1;
        elseif diff1(i-j-1)-diff1(i-j)>diff && diff2(i-j-1)-diff2(i-j)>diff && diff3(i-j-1)-diff3(i-j)>diff && diff4(i-j-1)-diff4(i-j)>diff && diff5(i-j-1)-diff5(i-j)>diff
            count1=count1-1;
        end
        if diff6(i-j)-diff6(i-j-1)>diff && diff7(i-j)-diff7(i-j-1)>diff && diff8(i-j)-diff8(i-j-1)>diff && diff9(i-j)-diff9(i-j-1)>diff && diff10(i-j)-diff10(i-j-1)>diff
            count2=count2+1;
        elseif diff6(i-j-1)-diff6(i-j)>diff && diff7(i-j-1)-diff7(i-j)>diff && diff8(i-j-1)-diff8(i-j)>diff && diff9(i-j-1)-diff9(i-j)>diff && diff10(i-j-1)-diff10(i-j)>diff
            count2=count2-1;
        end
    end
    if count1>k*guppylength  %发散
        Ftrendcond(i)=1;
    elseif count1<-k*guppylength  %聚拢
        Ftrendcond(i)=-1;
    else
        Ftrendcond(i)=0;  %平行
    end
    if count2>k*guppylength  %发散
        Strendcond(i)=1;
    elseif count2<-k*guppylength  %聚拢
        Strendcond(i)=-1;
    else
        Strendcond(i)=0;  %平行
    end

    if newdiff_m5(i)>0 && newdiff_m1(i)>0
        trendsignal(i)=1;
    elseif newdiff_m5(i)<0 && newdiff_m1(i)<0
        trendsignal(i)=-1;
    elseif newdiff_m5(i)<0 && newdiff_m1(i)>0
        trendsignal(i)=0;
    elseif newdiff_m5(i)>0 && newdiff_m1(i)<0
        trendsignal(i)=0;  
    end
    
    if newdiff_m15(i)<0 && newdiff_m30(i)>0 && newdiff_h1(i)>0
        trendmain(i)=1;
    elseif newdiff_m15(i)>0 && newdiff_m30(i)<0 && newdiff_h1(i)<0
        trendmain(i)=-1;
    end
    if newdiff_m15(i)<0 && newdiff_m30(i)<0 && newdiff_h1(i)>0
        trendmain(i)=-1;
    elseif newdiff_m15(i)>0 && newdiff_m30(i)>0 && newdiff_h1(i)<0
        trendmain(i)=1;
    end
    if newdiff_m15(i)<0 && newdiff_m30(i)>0 && newdiff_h1(i)<0
        trendmain(i)=-1;
    elseif newdiff_m15(i)>0 && newdiff_m30(i)<0 && newdiff_h1(i)>0
        trendmain(i)=1; 
    end
    
    if newdiff_h1(i)>0
        trendd1(i)=1;
    elseif newdiff_h1(i)<0
        trendd1(i)=-1;
    end
    
    if Strend(i)>0 && Ftrendcond(i)>0 && Strendcond(i)>0
        tradecon(i)=1;

    elseif Strend(i)<0 && Strendcond(i-1)>0 && Strendcond(i)<0 && Ftrend(i)>0 && Ftrendcond(i)>0 && Fmax(i)>Smin(i)
        tradecon(i)=1;

    elseif Strend(i)>0 && Strendcond(i)<0 && Ftrendcond(i)>0 && Ftrend(i)>0 && Fmax(i)>Smin(i)
        tradecon(i)=1;

    elseif Strend(i)>0 && Strendcond(i)>0 && Ftrend(i)>0 && Fmax(i)>Smin(i) % && Strendcond(i-3)==0
        tradecon(i)=1;

    elseif Strend(i)<0 && Strendcond(i)>0 && Ftrend(i)<0 && Fmin(i)<Smax(i) % && Strendcond(i-3)==0
        tradecon(i)=-1;

    elseif Strend(i)<0 && Strendcond(i)<0 && Ftrend(i)<0 && Ftrendcond(i)>0 && Smax(i)>Fmin(i)
        tradecon(i)=-1;

    elseif Strend(i)<0 && Strendcond(i)<0 && Ftrendcond(i)>0 && Smax(i)>Fmin(i)
        tradecon(i)=-1;

    elseif Strend(i)<0 && Strendcond(i)>0 && Fmax(i)<Smin(i)
        tradecon(i)=-1;
    else 
        tradecon(i)=tradecon(i-1);        
    end
    
    if tradecon(i)>0 && trendmain(i)>0 && trendd1(i)>0
        condition(i) = 1;
    elseif tradecon(i)<0 && trendmain(i)<0 && trendd1(i)<0
        condition(i) = -1;
%     else
%         condition(i) = condition(i-1);
    end       
        
end
FS = {Fmax,Fmin,Smax,Smin};
end

