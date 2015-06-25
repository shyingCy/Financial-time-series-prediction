function [entryRecord,exitRecord,my_currentcontracts,obj,vararg] = for_EMD( strategy,bardata,pro_information,ConOpenTimes,isMoveOn,trainBeg,trainEnd,strategyArg,varargin )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

load('Rmean.mat');

%找到对应品种
Pro = [{'IF'};{'I'};{'J'};{'L'};{'M'};...
    {'RB'};{'SR'};{'TA'};{'Y'};{'P'};{'RU'};...
    {'AG'};{'AU'};{'CU'};{'CF'};{'JD'};{'AL'};{'RM'}];
for t = 1:length(Pro)
    if strcmp(pro_information(1),Pro(t))
        index = t;
        break;
    end
end
[m,n] = size(bardata);
Date = bardata(:,1);
Day = zeros(m,1);

day  = 1;
for t = 1:m-1
    Day(t) = day ;
    if Date(t+1)>Date(t)
        day = day + 1;
    end
end
Day(m) = day ;

RBeg = Day(trainBeg);
REnd = Day(trainEnd);

RtrainData = Rmean(index,RBeg:REnd); %截取对应的Rmean的值
trainData = bardata(trainBeg:trainEnd,:);
count = 1;
vararg = {};
my_currentcontracts = varargin{2};
entryRecord = [];
exitRecord = [];
obj = [];
for StopLossRate = strategyArg{1}
    for T0 = strategyArg{2}
        [entryRecord,exitRecord,my_currentcontracts] = ...
            train_EMD(trainData,pro_information,T0,RtrainData,StopLossRate,ConOpenTimes);
        [obj(count,:),entryRecord,exitRecord] = train_reportVar(trainData,entryRecord,exitRecord,0,pro_information,isMoveOn,varargin{:});
        count = count + 1;
    end
end
end

