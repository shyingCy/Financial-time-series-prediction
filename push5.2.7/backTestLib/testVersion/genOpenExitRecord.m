function openExitRecord = genOpenExitRecord(completeEntryRecord,completeExitRecord,pinPrefix,TradingUnits,MarginRatio,TradingCost_info)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

%此函数是与遗传算法的接口，用于生成用于遗传算法的下单记录
%TradingUnits为交易单位
%MarginRatio为保证金率
%TradingCost_info为交易费用信息，正数为每手收多少手续费，负数为按交易金额的百分比算

entryD = completeEntryRecord(:,2) + completeEntryRecord(:,3);   %开仓时间
exitD = completeExitRecord(:,2) + completeExitRecord(:,3);  %平仓时间


entrylots = completeEntryRecord(:,5);
exitlots = completeExitRecord(:,5);


entryLength = size(completeEntryRecord,1);
exitLength = size(completeExitRecord,1);
recLength = entryLength + exitLength;


temp_openExitRecord = zeros(recLength,6);    %存放交易记录,改进：行数可以初始化为最长的那个，列数是确定的
pin = cellstr(repmat(pinPrefix,recLength,1));
delimeter = cellstr(repmat(',',recLength,1));

%-------组合记录然后进行排序------%
%完整的建平仓记录格式为[-1,date,time,price,lots,my_currentcontracts]
%第一列为方向，最后一列为此下单之后的持仓手数
%temp_openExitRecord是时间，方向，价格，持仓手数，单手保证金，单手手续费

temp_openExitRecord(1:entryLength,1) = entryD;
temp_openExitRecord(1:entryLength,2) = completeEntryRecord(:,1);
temp_openExitRecord(1:entryLength,3) = completeEntryRecord(:,4);
temp_openExitRecord(1:entryLength,4) = completeEntryRecord(:,6);

temp_openExitRecord(entryLength+1:end,1) = exitD;
temp_openExitRecord(entryLength+1:end,2) = completeExitRecord(:,1);
temp_openExitRecord(entryLength+1:end,3) = completeExitRecord(:,4);
temp_openExitRecord(entryLength+1:end,4) = completeExitRecord(:,6);

temp_openExitRecord(1:entryLength,5) = completeEntryRecord(:,4) * TradingUnits * MarginRatio;
temp_openExitRecord(entryLength+1:end,5) = completeExitRecord(:,4) * TradingUnits * MarginRatio;

if TradingCost_info > 0     %如果手续费信息大于0，则为按手数收手续费，否则为按交易金额百分比
    temp_openExitRecord(1:end,6) = repmat(TradingCost_info,recLength,1);
else
    temp_openExitRecord(1:entryLength,6) = (-1) * 0.0001 * TradingCost_info * TradingUnits * completeEntryRecord(:,4);
    temp_openExitRecord(entryLength+1:end,6) = (-1) * 0.0001 * TradingCost_info * TradingUnits * completeExitRecord(:,4);
end

openExitRecord = {};
openExitRecord(:,1) = pin;
openExitRecord(:,2) = delimeter;
openExitRecord(:,3) = cellstr(datestr(temp_openExitRecord(:,1),'yyyy-mm-dd HH:MM:SS'));
openExitRecord(:,4) = delimeter;
openExitRecord(:,5) = num2cell(temp_openExitRecord(:,2));
openExitRecord(:,6) = delimeter;
openExitRecord(:,7) = num2cell(temp_openExitRecord(:,3));
openExitRecord(:,8) = delimeter;
openExitRecord(:,9) = num2cell(temp_openExitRecord(:,4));
openExitRecord(:,10) = delimeter;
openExitRecord(:,11) = num2cell(temp_openExitRecord(:,5));
openExitRecord(:,12) = delimeter;
openExitRecord(:,13) = num2cell(temp_openExitRecord(:,6));

end

