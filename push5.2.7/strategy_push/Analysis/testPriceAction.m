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

%----------Z006测试--------%
%导入数据
tb = 'if000_m1';
pro = 'if_pro_info';
load(tb);
load(pro);
%策略参数
strategy = 'Z006';
k = 1.6;
TrailingStart = 150;
TrailingStop = 30;
StopLossSet = 50;
refn = 3;

%---------测试版本---------%
tic
priceAction(strategy,bardata,pro_information,TrailingStart,TrailingStop,StopLossSet,refn,ConOpenTimes)
[mytraderecord,openExitRecord,DynamicEquity_List,test_obj] = reportVar(strategy,bardata,pro_information);
toc
%--------训练版本----------%
tic
Close = bardata(:,6);
swingprice = myZigZag(Close,k);
[profitRet,CumNetRetStdOfTradeRecord,maxDDOfTradeRecord,maxDDRetOfTradeRecord,LotsWinTotalDLotsTotal,AvgWinLossRet] = train_priceAction(bardata,pro_information,TrailingStart,TrailingStop,StopLossSet,refn,ConOpenTimes,isMoveOn);
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