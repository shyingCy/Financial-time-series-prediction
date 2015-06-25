function [barData,minuteData] = getBarData(pro,Freq)
%UNTITLED8 Summary of this function goes here
%   Detailed explanation goes here

tbName = [pro,'_',Freq];
barDataName = [tbName,'_barData'];
minuteDataName = [tbName,'_minuteData'];

if ~isExistInWork(barDataName) || ~isExistInWork(minuteDataName)
    temp = load(tbName);
    barData = temp.bardata;
    minuteData = temp.minuteData;
    assignin('base',barDataName,barData);
    assignin('base',minuteDataName,minuteData);
else
    barData = evalin('base',barDataName);
    minuteData = evalin('base',minuteDataName);
end

end

