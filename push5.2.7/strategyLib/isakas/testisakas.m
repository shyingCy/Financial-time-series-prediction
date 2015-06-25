clear
%-------导入用户配置----------%
user_Config = loadTestInfoConfig();
testPro_list = user_Config.testPro_list;
testFreq_list = user_Config.testFreq_list;
begD = user_Config.begD;
endD = user_Config.endD;
isMoveOn = user_Config.isMoveOn;
ConOpenTimes = user_Config.ConOpenTimes;
trainDay_Length = user_Config.trainDay_Length;
testDay_Length = user_Config.testDay_Length;
istrainRandom = user_Config.istrainRandom;
random_down = user_Config.random_down;
random_up = user_Config.random_up;
isDB = user_Config.isDB;
opt_Way = user_Config.opt_Way;

 
load('if000_m30');
load('if_pro_info');

%下面这部分截取可以提取出来
begNum = datenum(begD); endNum = datenum(endD);
%提取minuteData
Date = minuteData(:,1);
dbeg = find(Date>=begNum,1); %找到截取数据的起始下标
dend = find(Date<=endNum); %结束下标
dend = dend(end);
minuteData = minuteData(dbeg:dend,:);
%提取bardata
Date = bardata(:,1);
dbeg = find(Date>=begNum,1); %找到截取数据的起始下标
dend = find(Date<=endNum); %结束下标
dend = dend(end);
bardata = bardata(dbeg:dend,:);
%提取各种价格
Date = bardata(:,1); Time = bardata(:,2);
Open = bardata(:,3); High = bardata(:,4);
Low = bardata(:,5); Close = bardata(:,6);
Vol = bardata(:,7);

%----------isakas测试--------%
%策略参数
strategy = 'isakas';
Length_1 = 11;
filter = 10;
Length = 30;

barLength = size(Date,1); %K线总量
% cycle=4;
% phase=Length_1-1;
% weight=zeros(barLength,1);
% sum=zeros(barLength,1);
% price=zeros(barLength,1);
% len=Length_1*cycle+phase;
% coeff=3*pi;
% 
% for i=len*2-1:barLength
%     m=0;
%     for j=0:len-1
%         g=1/(coeff*m+1);
%         if m<=0.5
%             g=1;
%         end
%         b=cos(m*pi);
%         a=g*b;
%         price(i)=mean(Close(i-len-j+1:i));
%         sum(i)=sum(i)+a*price(i-1);
%         weight(i)=weight(i)+a; 
%         if m<1
%             m=m+1/(phase-1);
%         elseif m<len-1
%             m=m+(2*cycle-1)/(cycle*Length_1-1);
%         end        
%     end
% end

con = isakasCon(strategy,bardata,pro_information,Length_1,filter,Length);
%---------测试版本---------%
tic
 isakas(strategy,bardata,pro_information,con,ConOpenTimes);
 [mytraderecord,openExitRecord,DynamicEquity_List,test_obj] = reportVar(strategy,bardata,pro_information);
toc
%--------训练版本----------%
tic
[profitRet,CumNetRetStdOfTradeRecord,maxDDOfTradeRecord,maxDDRetOfTradeRecord,LotsWinTotalDLotsTotal,AvgWinLossRet,traderecord] = train_isakas(bardata,pro_information,con,ConOpenTimes,isMoveOn);
toc
train_obj = [profitRet,CumNetRetStdOfTradeRecord,maxDDOfTradeRecord,maxDDRetOfTradeRecord,LotsWinTotalDLotsTotal,AvgWinLossRet];
%====判断测试版本与训练版本是否有区别====%
isSame = 1;
for i=1:length(test_obj)
    if test_obj(i) ~= train_obj(i)
        isSame = 0;
        error('测试版本和训练版本目标值不同！请检查训练版本');
        break;
    end
end

if isSame == 1
    disp('测试版本和训练版本相同！请转移阵地，测试参数范围！');
end
