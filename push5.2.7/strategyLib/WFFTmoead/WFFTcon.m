function [con] = WFFTcon( data,pro_information,N,len,q,Tq,Length,Dq )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here


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
barLength = length(Close); %K线总量
%---------------------------------------%
%---------------------------------------%

%---------以下变量根据需要进行修改--------%
%策略变量
a=2/(1+Length);   %α值
n=1:N;

con = zeros(barLength,1);

LLTvalue(1) = Close(1);    %LLT线初始化
LLTvalue(2) = Close(2); 
for i = 3:barLength   %计算LLT趋势线
    LLTvalue(i)=(a-0.25*a^2)*Close(i)+0.5*a^2*Close(i-1)-(a-0.75*a^2)*Close(i-2)+(2-2*a)*LLTvalue(i-1)-(1-a)^2*LLTvalue(i-2);
end
    d=diff(LLTvalue); %求差分
    
    MA(1:len-1) = Close(1:len-1);    %MA平滑
for j = len:barLength
    MA(j) = mean(Close(j-len+1:j));
end
    MA = MA-mean(MA); %消除直流分量
    
for j = N:barLength
    y = fft(MA(j-N+1:j));    %对一个时间窗口进行傅里叶变换
    pow(1:N) = abs(y).^2;    %计算一个时间窗口功率谱强度
    if j==N                  %计算每个周期的强度
        S(1:N-1) = (-10/log(10))*log(0.01./(1-(pow(1:N-1)./max(pow(1:N))))) ;
    end
    S(j) = (-10/log(10))*log(0.01./(1-(pow(N)./max(pow(1:N))))) ;
    if S(j)<0
        S(j) = 0;
    end

     %计算权重
     k(1:N) = abs(q - S(1:N)); 
     k(j) = abs(q - S(j)); 

     T(j) = sum(k(j-N+1:j).*n)/sum(k(j-N+1:j));  %求一段时间序列的平均周期
                                                 %对应即第j个点瞬时周期
end
shift = max(N,len);
for i = shift:barLength
    if T(i-1)<(N+1)/2+Tq && T(i-1)>(N+1)/2-Tq && d(i-2)>Dq
        con(i) = 1;
    elseif T(i-1)<(N+1)/2+Tq && T(i-1)>(N+1)/2-Tq && d(i-2)<Dq
        con(i) = -1;
    elseif (T(i-1)>(N+1)/2+Tq || T(i-1)<(N+1)/2-Tq)  
        con(i) = 2;
    end
end

end

