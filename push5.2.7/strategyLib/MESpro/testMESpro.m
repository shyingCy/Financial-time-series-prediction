
%-------导入用户配置----------%
[testPro_list,testFreq_list,begD,endD,isMinPointOn,ConOpenTimes,trainDay_Length,testDay_Length,opt_Way] = loadTestInfoConfig();

load([testPro_list{1},'_',testFreq_list{1}]);
pinPrefix = cell2mat(regexp(testPro_list{1},'[^\d]','match'));
load([pinPrefix,'_pro_info']);
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

%----------MES测试--------%
%策略参数
strategy = 'MESpro';
% M = '10:04:00'; %上午开仓时间 窗口长度(从9:15:00开始)
% N = '13:33:00'; %下午开仓时间 窗口长度(从11:12:00开始)
M = 50;
N = 50;
E = 0.0009; %平稳度阈值
StopLossRate = 0.005 ;%止损阈值
%---------测试版本---------%
tic
MESpro(strategy,bardata,pro_information,M,N,E,StopLossRate,ConOpenTimes);
[mytraderecord,openExitRecord,DynamicEquity_List] = reportVar(strategy,bardata,pro_information);
toc
%--------训练版本----------%
tic
[profitRet,CumNetRetStd,maxDD,LotsWinTotalDLotsTotal,AvgWinLossRet,traderecord,Dy] = train_MESpro(bardata,pro_information,M,N,E,StopLossRate,ConOpenTimes,isMinPointOn);
toc

