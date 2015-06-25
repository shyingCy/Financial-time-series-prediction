function [ completeEntryRecord,completeExitRecord,entryRecord,exitRecord ] = genEntryExitRecord(strategy,isMoveOn,MinPoint)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
%此函数生成建仓和平仓记录用于输入genTradeRecord生成交易记录

entryRecord_Name = [strategy,'MY_ENTRYRECORD'];
exitRecord_Name = [strategy,'MY_EXITRECORD'];

if ~isExistInWork(entryRecord_Name)
    disp('Please check if there are open records\n');
    completeEntryRecord = zeros(1,6);
else
    completeEntryRecord = evalin('base', entryRecord_Name);      %开仓记录
end

if ~isExistInWork(exitRecord_Name)
    disp('Please check if there are exit records\n');
    completeExitRecord = zeros(1,6);
else
    completeExitRecord = evalin('base', exitRecord_Name);       %平仓记录
end

%处理价格不合理情况
temp1 = completeEntryRecord(:,1);
temp2 = completeEntryRecord(:,4); %取小数点后2位
temp2(temp1>0) = temp2(temp1>0) + mod(temp2(temp1>0),MinPoint); %向价格不利方向取价格
temp2(temp1<0) = temp2(temp1<0) - mod(temp2(temp1<0),MinPoint);
temp2 = roundn(temp2,-2); %因为精度问题，不进行四舍五入是有问题的
completeEntryRecord(:,4) = temp2;

temp1 = completeExitRecord(:,1);
temp2 = completeExitRecord(:,4);
temp2(temp1>0) = temp2(temp1>0) + mod(temp2(temp1>0),MinPoint); %向价格不利方向取价格
temp2(temp1<0) = temp2(temp1<0) - mod(temp2(temp1<0),MinPoint);
temp2 = roundn(temp2,-2); %因为精度问题，不进行四舍五入是有问题的
completeExitRecord(:,4) = temp2; 

%处理滑点
if isMoveOn==1  %建仓滑点
    temp1 = completeEntryRecord(:,1);
    temp2 = completeEntryRecord(:,4);
    temp2(temp1>0) = temp2(temp1>0) + MinPoint; %建仓买入的时候的滑点
    temp2(temp1<0) = temp2(temp1<0) - MinPoint; %建仓卖出的时候的滑点
    completeEntryRecord(:,4) = temp2;
elseif isMoveOn==2  %平仓滑点
    temp1 = completeExitRecord(:,1);
    temp2 = completeExitRecord(:,4);
    temp2(temp1>0) = temp2(temp1>0) + MinPoint; %平仓买入的时候的滑点
    temp2(temp1<0) = temp2(temp1<0) - MinPoint; %平仓卖出的时候的滑点
    completeExitRecord(:,4) = temp2;
elseif isMoveOn==4
    temp1 = completeEntryRecord(:,1);
    temp2 = completeEntryRecord(:,4);
    temp2(temp1>0) = temp2(temp1>0) + MinPoint;
    temp2(temp1<0) = temp2(temp1<0) - MinPoint;
    completeEntryRecord(:,4) = temp2;
    temp1 = completeExitRecord(:,1);
    temp2 = completeExitRecord(:,4);
    temp2(temp1>0) = temp2(temp1>0) + MinPoint;
    temp2(temp1<0) = temp2(temp1<0) - MinPoint;
    completeExitRecord(:,4) = temp2;
end

entryRecord = completeEntryRecord(:,1:end-1);
exitRecord = completeExitRecord(:,1:end-1);

end

