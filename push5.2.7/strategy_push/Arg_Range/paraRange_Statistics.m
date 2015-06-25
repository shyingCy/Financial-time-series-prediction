function [ upperFreq,lowerFreq] = paraRange_Statistics(arg,best_arg)
%PARARANGE_STATISTICS Summary of this function goes here
%   Detailed explanation goes here
%统计最优参数触碰到上下范围边缘值次数
%2015.03.25

%对触碰边缘进行统计
[bestArg_Num,argNum] = size(best_arg);
lowerTimes = zeros(1,argNum); %统计参数触碰下边缘次数
upperTimes = zeros(1,argNum); %统计参数触碰上边缘次数
for i=1:argNum
    temp = find(best_arg(:,i)==arg(1,i));
    lowerTimes(i) = length(temp);
    temp = find(best_arg(:,i)==arg(end,i));
    upperTimes(i) = length(temp);
end

lowerFreq = lowerTimes/bestArg_Num;
upperFreq = upperTimes/bestArg_Num;

end

