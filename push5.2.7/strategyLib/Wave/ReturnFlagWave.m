function Flag = ReturnFlagWave(data,M,d)
%UNTITLED2 Summary of this function goes here
%将bardata经过完整变化,得出相角数据
%   Detailed explanation goes here
%数据库连接以及读取数据
%在优化函数中链接数据

%待测试方向
%M取值
%消噪or
%把tick数据转化为一分钟数据
%minuteData = exchangeTo1(tickdata);
% evalin('base','clear');
Date = data(:,1);
Time = data(:,2);
Open = data(:,3);
High = data(:,4);
Low = data(:,5);
Close = data(:,6);
barLength = size(Date,1); %K线总量

%先做二阶高通滤波处理(HPF)得到短周期子序列
a=2/(d+1);
HPFClose0=HPF(Close,a);

%截取有效段
%粗略方式 无明确标准
for t=1:length(HPFClose0)
    if(HPFClose0(t)<0)
        index=t;
        break;
    end
end
HPFClose = HPFClose0(1,index:end);%Attention!难度

%希尔伯特处理
HiClose = Hilbertrewroten(M,HPFClose);

%转换相角
P = angle(HiClose);
%转换瞬时周期序列
T(1)=0;
for t=2:length(P)
    T(t) = (2*pi)/(P(t)-P(t-1));
    if(T(t)>62) T(t) = 62;
    end
    if(T(t)<5) T(t) = 5;
    end
end
%对周期序列做EMA平滑处理
Tafter = EMA(T);

c=0;
%计算H浪单周期波动变化
for g=(index+2*M):barLength
    c=c+1;
    deltaN(c)=Close(g)-Close(g-floor(Tafter(g-index-2*M+1)));
end

%提前判断 -1为看空 1为看多 0为没有趋势
Flag0(1) = 0;
for i = 1:length(deltaN)-1%判断趋势 以次日开盘价交易 -1防止超出
    t = i+1;%1为获取次日开盘数据
    if(deltaN(i)>=0)%看多
        Flag0(t) = 1;
    else
        Flag0(t) = -1;
    end
end
%补零到与bardata长度相同(?)
a=zeros(1,2*M+index-1);%与M,index有关 3.12尚未对齐
%b=zeros(1,M);
Flag=[a,Flag0];
end