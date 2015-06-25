function Flag = ReturnFlagPhase(data,M,MAClose)
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

%做MA移动平均线
%低级错误 不可把data当Close用

%通过二阶高通滤波进行去除长期趋势
SFClose0 = SF(MAClose);

%截取有效段
%粗略方式 无明确标准
for t=1:length(SFClose0)
    if(SFClose0(t)<0)
        index=t;
        break;
    end
end
SFClose = SFClose0(1,index:end);%Attention!难度

%希尔伯特处理
HiClose = Hilbertrewroten(M,SFClose);

%转换相角
P=angle(HiClose);
%转换瞬时周期序列
T(1)=0;
for t=2:length(P)
    T(t)=(2*pi)/(P(t)-P(t-1));
    if(T(t)>62) T(t)=62;
    end
    if(T(t)<5) T(t)=5;
    end
end
%对周期序列做EMA平滑处理
Tafter=EMA(T);

%傅里叶变换计算动态相角
a=0;
for t=index+M:barLength-M
    N=floor(Tafter(t-index-M+1));%当期t时刻的瞬时周期%跳过第一个T(1)=0
    if(N<=t)%截取不到所需数据 暂时不考虑
        I=0;
        R=0;
        for n=(t-N+1):t
            I=I+Close(n)*sin((2*pi*(n-(t-N+1)))/N);%虚部
            R=R+Close(n)*cos((2*pi*(n-(t-N+1)))/N);%实部
        end
        a=a+1;
        Theta(a)=atan(I/R);
    end
end

%提前判断 -1为看空 1为看多 0为没有趋势
Flag0(1) = 0;
Flag0(2) = 0;
for i=2:length(Theta)-1%判断趋势 以次日开盘价交易 -1防止超出
    d1 = sin(Theta(i-1)+pi)-sin(Theta(i-1)+1.25*pi);
    d2 = sin(Theta(i)+pi)-sin(Theta(i)+1.25*pi);
    t=i+1;%+1为获取次日开盘数据
    if( d1 * d2 < 0)%趋势切换
        if( d2 > 0 )%看空           %查看此次"<"or">".
            Flag0(t) = -1;
        end
        if( d2 < 0 ) %看多
            Flag0(t) = 1;
        end
    else
        Flag0(t) = 0;
    end
end
%补零到与bardata长度相同(?)
a=zeros(1,2*M+index-1);%与M,index有关 3.12尚未对齐
%b=zeros(1,M);
Flag=[a,Flag0];
end