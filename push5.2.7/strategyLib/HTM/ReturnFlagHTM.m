function Flag = ReturnFlagHTM(data,M,MAClose)
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
%sql = strcat('select * from taodata.',pro,'_',Freq,';');全部数据
entryCount = 0; %记录交易次数
status = 0; %记录做多做空，1做多，-1做空
profit = [];
totalprofit = [];
%交易相关变量设置 end
%品种参数
Lots=1;        %交易手数

Date = data(:,1);
Time = data(:,2);
Open = data(:,3);
High = data(:,4);
Low = data(:,5);
Close = data(:,6);
barLength = size(Date,1); %K线总量

%做MA移动平均线
%在函数外计算均线 3.19
% %测试:只做回测
% %差分处理 处理后数据少一位
%x=diff(minuteClose);
x=diff(MAClose);
%x=diff(MA)
%希尔伯特处理
%完整hilbert函数
z=Hilbertrewroten(M,x);%此处用到了当日之前的数据
%转换幅角
Theta=angle(z);

%15.3.15 提前判断 -1为看空 1为看多
%flag为判断结果
Flag0(1) = 0;
Flag0(2) = 0;
for i=2:length(Theta)-1%判断趋势 以次日开盘价交易 -1防止超出
    t=i+1;%3.8 M延迟已在希尔伯特变换时补零解决 1为获取次日开盘数据
    if(Theta(i-1)*Theta(i)<0)%趋势切换
        if(Theta(i)>0)%相量进入一二象限 看空           %查看此次"<"or">".
            Flag0(t) = -1;
        end
        if(Theta(i)<0) %相量进入三四象限 看多
            Flag0(t) = 1;
        end
    else
        Flag0(t) = 0;
    end
end
%补零到与bardata长度相同(?)
a=zeros(1,2*M+1);
%b=zeros(1,M);
Flag=[a,Flag0];
end