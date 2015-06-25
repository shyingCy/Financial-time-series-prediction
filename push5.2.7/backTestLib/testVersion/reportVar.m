function [obj,completeEntryRecord,completeExitRecord,mytraderecord,openExitRecord,DynamicEquity_List] = reportVar(strategy,bardata,pro_information,isMoveOn,varargin)

%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

%初始资金
originalMoney = 1e6;
isTrain = varargin{1};
%品种信息
pinPrefix = pro_information{1};
TradingUnits = cell2mat(pro_information(:,2));       %交易单位
MinPoint = cell2mat(pro_information(:,3));  %最小变动单位
MarginRatio = cell2mat(pro_information(:,6));        %保证金率
TradingCost_info = cell2mat(pro_information(:,5));  %交易费用


%生成完整的建仓平仓记录和裁剪掉剩余持仓数的建平仓记录，后者是为了保持后面的代码无须修改,滑点作为参数进行设置
[ completeEntryRecord,completeExitRecord,entryRecord,exitRecord ] = genEntryExitRecord(strategy,isMoveOn,MinPoint);

%生成遗传算法的交易记录
openExitRecord = genOpenExitRecord(completeEntryRecord,completeExitRecord,pinPrefix,TradingUnits,MarginRatio,TradingCost_info);

%生成交易记录
[traderecord,isExitLeft] = genTradeRecord(entryRecord,exitRecord);

%处理交易记录未平仓记录
if isExitLeft == 1
    repairedRec = zeros(1,3);
    repairedRec(1:2) = bardata(end,1:2);
    repairedRec(3) = bardata(end,6);
    traderecord = handleLeftTraderecord(traderecord,repairedRec);
end

%若交易记录为空或者目前是在测试阶段，则把所有指标置为-Inf且返回
if size(traderecord,1) == 0 || isTrain == 0
    openExitRecord = [];
    mytraderecord = {};
    DynamicEquity_List = {};
    profitRet = -Inf;
    CumNetRetStdOfTradeRecord = -Inf;
    maxDDOfTradeRecord = -Inf;
    maxDDRetOfTradeRecord = -Inf;
    LotsWinTotalDLotsTotal = -Inf;
    AvgWinLossRet = -Inf;
    obj = [profitRet,CumNetRetStdOfTradeRecord,maxDDOfTradeRecord,maxDDRetOfTradeRecord,LotsWinTotalDLotsTotal,AvgWinLossRet];
    return;
end

mytraderecord = num2cell(traderecord);
mytraderecord(:,2) = cellstr(datestr(traderecord(:,2),'yyyy-mm-dd'));
mytraderecord(:,3) = cellstr(datestr(traderecord(:,3),'HH:MM:SS'));
mytraderecord(:,5) = cellstr(datestr(traderecord(:,5),'yyyy-mm-dd'));
mytraderecord(:,6) = cellstr(datestr(traderecord(:,6),'HH:MM:SS'));

%根据交易记录得到每条记录的收益等
[Type,Lots,NetMargin,RateOfReturn,CostSeries] =...
    handleTradeRecord(traderecord,TradingUnits,TradingCost_info);

%交易记录长度
RecLength = length(NetMargin);


%累计净利
CumNetMargin=cumsum(NetMargin);

%由交易记录算出的相对初始资金的累计收益率标准差
CumNetRetStdOfTradeRecord = std(CumNetMargin/originalMoney);

addMoney = min(CumNetMargin);
if addMoney <= 0
    addMoney = abs(addMoney);
else
    addMoney = 0;
end

if length(CumNetMargin) > 1
    %由交易记录计算得到的最大回撤值以及最大回撤率
    maxDDOfTradeRecord = maxdrawdown(CumNetMargin+addMoney,'arithmetic');
    maxDDRetOfTradeRecord = maxdrawdown(CumNetMargin+addMoney+originalMoney);
else
     maxDDOfTradeRecord = -Inf;
     maxDDRetOfTradeRecord = -Inf;
end

mytraderecord(:,9) = num2cell(CumNetMargin);
mytraderecord(:,10) = num2cell(CostSeries);


%累计收益率
CumRateOfReturn=cumsum(RateOfReturn);


%用收益率算夏普比率
SharpRet = (mean(RateOfReturn)*length(RateOfReturn))/(std(RateOfReturn)*sqrt(length(RateOfReturn)));
%save('D:\MatlabWork\program\策略\策略及推进\RateOfReturn','RateOfReturn','NetMargin');
%-------------------------交易汇总------------------------------------
%根据交易记录得到每根K线资产变化变量

%净利润
ProfitTotal=sum(NetMargin);
ProfitLong=sum(NetMargin(Type==1));
ProfitShort=sum(NetMargin(Type==-1));

%净收益率（净收益/初始资金）
profitRet = ProfitTotal/originalMoney;

%总盈利
WinTotal=sum(NetMargin(NetMargin>0));
temp=NetMargin(Type==1);
WinLong=sum(temp(temp>0));
temp=NetMargin(Type==-1);
WinShort=sum(temp(temp>0));

%平均盈利
AvgWinTotal = WinTotal/length(NetMargin(NetMargin>0));

%总亏损
LoseTotal=sum(NetMargin(NetMargin<0));
temp=NetMargin(Type==1);
LoseLong=sum(temp(temp<0));
temp=NetMargin(Type==-1);
LoseShort=sum(temp(temp<0));

%平均亏损
AvgLossTotal = LoseTotal/length(NetMargin(NetMargin<0));

%总盈利/总亏损
WinTotalDLoseTotal=abs(WinTotal/LoseTotal);
WinLongDLoseLong=abs(WinLong/LoseLong);
WinShortDLoseShort=abs(WinShort/LoseShort);

%平均收益/平均亏损
AvgWinLossRet = AvgWinTotal/AvgLossTotal;

%交易手数
LotsTotal = sum(Lots);
LotsLong= sum(Lots(Type==1));
LotsShort=sum(Lots(Type==-1));

%盈利手数
LotsWinTotal =  sum(Lots(NetMargin>0));
temp=NetMargin(Type==1);
LotsWinLong = sum(Lots(temp>0));
temp=NetMargin(Type==-1);
LotsWinShort = sum(Lots(temp>0));

%亏损手数
LotsLoseTotal = sum(Lots(NetMargin>0));
temp=NetMargin(Type==1);
LotsLoseLong = sum(Lots(temp<0));
temp=NetMargin(Type==-1);
LotsLoseShort = sum(Lots(temp<0));

%持平手数
temp=NetMargin(Type==1);
LotsDrawLong = sum(Lots(temp==0));
temp=NetMargin(Type==-1);
LotsDrawShort = sum(Lots(temp==0));
LotsDrawTotal=LotsDrawLong+LotsDrawShort;

%盈利比率
LotsWinTotalDLotsTotal = LotsWinTotal/LotsTotal;
LotsWinLongDLotsLong = LotsWinLong/LotsLong;
LotsWinShortDLotsShort = LotsWinShort/LotsShort;

%最大盈利
MaxWinTotal=max(NetMargin(NetMargin>0));
temp=NetMargin(Type==1);
MaxWinLong=max(temp(temp>0));
temp=NetMargin(Type==-1);
MaxWinShort=max(temp(temp>0));

%最大亏损
MaxLoseTotal=min(NetMargin(NetMargin<0));
temp=NetMargin(Type==1);
MaxLoseLong=min(temp(temp<0));
temp=NetMargin(Type==-1);
MaxLoseShort=min(temp(temp<0));

%交易成本合计
CostTotal=sum(CostSeries);
temp=CostSeries(Type==1);
CostLong=sum(temp);
temp=CostSeries(Type==-1);
CostShort=sum(temp);
%----------------------用动态权益算出的变量，每根K线均有------------------------%
% [Date,pos,StaticEquity,DynamicEquity,LongMargin,ShortMargin] = ...
%     handleTradeProcedure(bardata,traderecord,TradingUnits,MarginRatio,TradingCost_info);
% 
% %K线长度
% barLength = length(Date);
% 
% % %========老的回撤数据计算，可以算出最长回撤时间=========%
% % retracement=zeros(barLength,1);  
% % retracementTime=zeros(barLength,1);
% % BackRatio = zeros(barLength,1);
% % for i=1:barLength
% %     [maxD, index] = max(DynamicEquity(1:i));
% %     if maxD==DynamicEquity(i)
% %         retracement(i) = 0;
% %         BackRatio(i) = 0;
% %         retracementTime(i) = 0;
% %     else 
% %         retracement(i) = DynamicEquity(i)-maxD;
% %         BackRatio(i) = retracement(i)/maxD;
% %         retracementTime(i) = round( Date(i) - Date(index) );
% %     end
% % end
% % 
% % %最大回撤
% % [value,D] = min(retracement);
% % maxRetracement = abs(value);
% % %最大回撤比例
% % maxRetracementRet = abs(min(BackRatio))*100;
% % %最大回撤周期(按日算)
% % maxRetracementTime = retracementTime(D);
% % %最长回撤周期（按日算）
% % longestRetracementTime = max(retracementTime);
% % %最大回撤发生时间
% % maxRectracementDate = datestr(Date(D),'yyyy-mm-dd HH:MM:SS');
% % %=========老的回撤数据计算，可以算出最长回撤时间=========%
% 
% % %最大回撤
% % [value,D] = maxdrawdown(DynamicEquity,'arithmetic');
% % %最大回撤比例
% % maxRetracementRet = maxdrawdown(DynamicEquity);
% % %最大回撤周期(按日算)
% % maxRetracementTime = round(Date(D(2)) - Date(D(1)));
% 
% 
% %由动态权益算出的相对初始资金的累计收益率标准差
% CumNetRetStdOfDy = std(DynamicEquity/originalMoney - 1);
% 
% addMoney = min(DynamicEquity);
% if addMoney <= 0
%     addMoney = abs(addMoney) + 1;
% else
%     addMoney = 0;
% end
% 
% if length(DynamicEquity) > 1
%     %由日动态权益计算得到的最大回撤值以及最大回撤率
%     maxDDOfDy = maxdrawdown(DynamicEquity+addMoney,'arithmetic');
%     maxDDRetOfDy = maxdrawdown(DynamicEquity+addMoney);
% else
%     maxDDOfDy = 0;
%     maxDDRetOfDy = 0;
% end
% 
% %存储动态权益表，第一列为时间，第二列为动态权益，第三列为pos
% DynamicEquity_List = {};
% DynamicEquity_List(:,1) = cellstr(datestr(Date,'yyyy-mm-dd HH:MM:SS'));
% DynamicEquity_List(:,2) = cellstr(repmat(',',length(Date),1));
% DynamicEquity_List(:,3) = num2cell(DynamicEquity);
% DynamicEquity_List(:,4) = cellstr(repmat(',',length(Date),1));
% DynamicEquity_List(:,5) = num2cell(pos);
% 
% %日开始时间和结束时间设置,这里是用数据来推导的,最好还是改进为每个品种对应确定的数据
% temp = day(Date);
% temp = find((temp(1:end-1)-temp(2:end))~=0,1); %错开相减如果不等于0就是每天的最后一个K了
% begDate = Date(temp+1);
% endDate = Date(temp);
% begHour = hour(begDate); begMin = minute(begDate); begSec = second(begDate);
% endHour = hour(endDate); endMin = minute(endDate); endSec = second(endDate);
% 
% %根据动态权益算累计收益率
% CumDynamicRet = DynamicEquity/DynamicEquity(1) - 1;
% 
% %根据静态权益算累计收益率
% CumStaticRet = StaticEquity/StaticEquity(1) - 1;
% 
% %日收益率&累计收益率
% Daily=Date(hour(Date)==begHour  & minute(Date)==begMin & second(Date)==begSec);
% DailyEquity=DynamicEquity(hour(Date)==begHour  & minute(Date)==begMin & second(Date)==begSec);
% 
% %此条件防止只有一天数据，调用tick2ret会出错
% if length(Daily) > 1
%     DailyRet=tick2ret(DailyEquity);  %日收益率
% else
%     DailyRet = CumStaticRet(end);
% end
% 
% %根据动态权益算日累计收益率
% DailyCumDynamicRet = CumDynamicRet(hour(Date)==endHour  & minute(Date)==endMin & second(Date)==endSec);
% 
% %根据静态权益算日累计收益率
% DailyCumStaticRet = CumStaticRet(hour(Date)==endHour  & minute(Date)==endMin & second(Date)==endSec);
% 
% %周收益率
% WeeklyNum=weeknum(Daily);    %weeknum返回是一年的第几周
% Weekly=[Daily((WeeklyNum(1:end-1)-WeeklyNum(2:end))~=0);Daily(end)];
% WeeklyEquity=[DailyEquity((WeeklyNum(1:end-1)-WeeklyNum(2:end))~=0);DailyEquity(end)];
% 
% if length(Weekly) > 1
%     WeeklyRet=tick2ret(WeeklyEquity);   %周收益率
% else
%     WeeklyRet = CumStaticRet(end);
% end
% 
% %根据动态权益算周累计收益率
% WeeklyCumDynamicRet = [DailyCumDynamicRet((WeeklyNum(1:end-1)-WeeklyNum(2:end))~=0);DailyCumDynamicRet(end)];
% 
% %根据静态权益算周累计收益率
% WeeklyCumStaticRet = [DailyCumStaticRet((WeeklyNum(1:end-1)-WeeklyNum(2:end))~=0);DailyCumStaticRet(end)];
% 
% %月收益率
% MonthNum=month(Daily);
% Monthly=[Daily((MonthNum(1:end-1)-MonthNum(2:end))~=0);Daily(end)];
% MonthlyEquity=[DailyEquity((MonthNum(1:end-1)-MonthNum(2:end))~=0);DailyEquity(end)];
% 
% if length(Monthly) > 1
%     MonthlyRet=tick2ret(MonthlyEquity);     %月收益率
% else
%     MonthlyRet = CumStaticRet(end);
% end
% 
% %根据动态权益算月累计收益率
% MonthlyCumDynamicRet = [DailyCumDynamicRet((MonthNum(1:end-1)-MonthNum(2:end))~=0);DailyCumDynamicRet(end)];
% 
% %根据静态权益算月累计收益率
% MonthlyCumStaticRet = [DailyCumStaticRet((MonthNum(1:end-1)-MonthNum(2:end))~=0);DailyCumStaticRet(end)];
% 
% %年收益率
% YearNum=year(Daily);
% Yearly=[Daily((YearNum(1:end-1)-YearNum(2:end))~=0);Daily(end)];
% YearlyEquity=[DailyEquity((YearNum(1:end-1)-YearNum(2:end))~=0);DailyEquity(end)];
% 
% if length(Yearly) > 1
%     YearlyRet=tick2ret(YearlyEquity);       %年收益率
%     YearSharp = (mean(YearlyRet)*length(YearlyRet))/(std(YearlyRet)*sqrt(length(YearlyRet)));
% else
%     YearlyRet = CumStaticRet(end);
%     YearSharp = 0; %不够一年没有年化夏普比
% end
% 
% %根据动态权益算年累计收益率
% YearlylyCumDynamicRet = [DailyCumDynamicRet((YearNum(1:end-1)-YearNum(2:end))~=0);DailyCumDynamicRet(end)];
% 
% %根据静态权益算年累计收益率
% YearlyCumStaticRet = [DailyCumStaticRet((YearNum(1:end-1)-YearNum(2:end))~=0);DailyCumStaticRet(end)];
% 
% %持仓时间
% HoldingDays=round(round(Date(end)-Date(1))*(length(pos(pos~=0))/barLength));%持仓时间
% 
% %有效收益率
% TrueRatOfRet=(DynamicEquity(end)-DynamicEquity(1))/max(max(LongMargin),max(ShortMargin));

% obj.ProfitTotal = ProfitTotal;
% obj.CumNetRetStd = CumNetRetStd;
% obj.maxDD = maxDD;
% obj.LotsWinTotalDLotsTotal = LotsWinTotalDLotsTotal;
% obj.AvgWinLossRet = AvgWinLossRet;
% objNum = 9;
% obj = zeros(objNum,1);
% obj(1:end) = [ProfitTotal;CumNetRetStdOfTradeRecord;CumNetRetStdOfDy;maxDDOfTradeRecord;maxDDRetOfTradeRecord;...
%     maxDDOfDy;maxDDRetOfDy;LotsWinTotalDLotsTotal;AvgWinLossRet];
DynamicEquity_List = {};
obj = [profitRet,CumNetRetStdOfTradeRecord,maxDDOfTradeRecord,maxDDRetOfTradeRecord,LotsWinTotalDLotsTotal,AvgWinLossRet];

end

