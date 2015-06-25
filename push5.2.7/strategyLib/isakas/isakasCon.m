function [isakascon] = isakasCon(strategy,data,pro_information,Length_1,filter,Length)
%UNTITLED Summary of this function goes here
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


cycle=4;
pricesmoothing=0.3;
indexsmoothing=0.3;
rangeperiods=35;
MACDfast=12;
MACDslow=26;
MACDma=9;
devition=2;
moneyrisk=1;
phase=Length_1-1;
coeff=3*pi;
len=Length_1*cycle+phase;

MACDvalue=EMA(Close,MACDfast)-EMA(Close,MACDslow);
MACDmain=EMA(MACDvalue,MACDma);
MACDsignal=MACDvalue-MACDmain;

con1=zeros(barLength,1);
con2=zeros(barLength,1);
con3=zeros(barLength,1);
Trend=zeros(barLength,1);
smoothedlocation=zeros(barLength,1);
smoothedfish=zeros(barLength,1);
ma=zeros(barLength,1);
iHigh=zeros(barLength,1);
iLow=zeros(barLength,1);
upperband=zeros(barLength,1);
lowerband=zeros(barLength,1);
% weight=zeros(barLength,1);
% sum=zeros(barLength,1);
price=zeros(barLength,1);
isakascon=zeros(barLength,1);

for i=len*2-1:barLength
    %Nonlagdot 指标
    m=0;
    sum=0;
    weight=0;
    
    for j = 0:len-1
        g=1/(coeff*m+1);
        if m<=0.5
            g=1;
        end
        b=cos(m*pi);
        a=g*b;
        price(i)=mean(Close(i-len-j+1:i));  %%price
        sum=sum+a*price(i-1);
        weight=weight+a;
        if m<1
            m=m+1/(phase-1);
        elseif m<len-1
            m=m+(2*cycle-1)/(cycle*Length_1-1);
        end
    end
    if weight>0
        ma(i)=(1+devition/100)*sum/weight;
    end
    if filter>0 && abs(ma(i)-ma(i-1))<filter*MinPoint
        ma(i)=ma(i-1);
    end
    if ma(i)-ma(i-1)>filter*MinPoint
        con1(i)=1;
    elseif ma(i-1)-ma(i)>filter*MinPoint
        con1(i)=-1;
    else
        con1(i)=con1(i-1);
    end
    
    
    %fisher kuskus指标
    iHigh(i)=max(High(i-rangeperiods+1:i));  %%
    iLow(i)=min(Low(i-rangeperiods+1:i));
    if iHigh(i)-iLow(i)<0.1*MinPoint
        iHigh(i)=iLow(i)+0.1*MinPoint;
    end
    greatrange=iHigh(i-1)-iLow(i-1);
    midprice=(High(i-1)+Low(i-1))/2;
    
%     if i==len*2+1
%         smoothedlocation(i)=0;
%         smoothedfish(i)=0;
%         fisherindex=0;
%         pricelocation=0;
%     end
    pricelocation=(midprice-iLow(i-1))/greatrange;
    pricelocation=2*pricelocation-1;
    
    smoothedlocation(i)=pricesmoothing*smoothedlocation(i-1)+(1-pricesmoothing)*pricelocation;
    if smoothedlocation(i)>0.99
        smoothedlocation(i)=0.99;
    end
    if smoothedlocation(i)<-0.99
        smoothedlocation(i)=-0.99;
    end
    
    if 1-smoothedlocation(i)~=0
        fisherindex=log((1+smoothedlocation(i))/(1-smoothedlocation(i)));
    end
    smoothedfish(i)=indexsmoothing*smoothedfish(i-1)+(1-indexsmoothing)*fisherindex;
    if smoothedfish(i)>0
        con2(i)=1;
    elseif smoothedfish(i)<0
        con2(i)=-1;
    else
        con2(i)=con2(i-1);
    end
    
    %flattrend

    if MACDsignal(i)<MACDmain(i)
        con3(i)=1;
    elseif MACDsignal(i)>MACDmain(i)
        con3(i)=-1;
    else
        con3(i)=con3(i-1);
    end
    
    %bolling band

    upperband(i)=mean(Close(i-Length+1:i))+2*std(Close(i-Length+1:i));
    lowerband(i)=mean(Close(i-Length+1:i))-2*std(Close(i-Length+1:i));
    
    if Close(i)>upperband(i-1)
        Trend(i)=1;
    elseif Close(i)<lowerband(i-1)
        Trend(i)=-1;
    else
        Trend(i)=Trend(i-1);
    end
    if con1(i-1)>0 && con2(i-1)>0 && con3(i-1)>0 && Trend(i-1)>0
        isakascon(i) = 1;
    elseif con1(i-1)<0 && con2(i-1)<0 && con3(i-1)<0 && Trend(i-1)<0
        isakascon(i) = -1;
    end
end

