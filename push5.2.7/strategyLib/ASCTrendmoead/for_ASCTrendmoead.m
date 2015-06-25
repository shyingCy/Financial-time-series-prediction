function [ entryRecord,exitRecord,my_currentcontracts,obj,vararg] = for_ASCTrendmoead( strategy,bardata,pro_information,ConOpenTimes,isMoveOn,trainBeg,trainEnd,strategyArg,varargin)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

count = 1;
isTrain = varargin{1};
my_currentcontracts = varargin{2};
vararg = {};
arg = [];
my_currentcontracts = varargin{2};
entryRecord = [];
exitRecord = [];
trainData = bardata(trainBeg:trainEnd,:);

num = 1;
for risk=strategyArg{1}
    value10 = 3 + risk*2;
    if trainBeg > value10
        data = bardata(trainBeg-value10:trainEnd,:);
        clear tempValue2
        tempValue2 = ASC(strategy,data,pro_information,risk);
        value2{num} = tempValue2(value10+1:value10+length(trainData));
    else
        data = trainData;
        value2{num} = ASC(strategy,data,pro_information,risk);
    end
    num = num + 1;
end

risk = strategyArg{1};
TrailingStart = strategyArg{2};
TrailingStop = strategyArg{3};
StopLossSet = strategyArg{4};

if isTrain == 1
    strategyPara = {1:1:length(strategyArg{1});
        1:1:length(strategyArg{2});
        1:1:length(strategyArg{3});
        1:1:length(strategyArg{4})};
    moeadPara = [strategyArg{5},strategyArg{6},strategyArg{7}];
    
    [pareto,totalobj] = ...
        train_ASCTrendmoead( trainData,pro_information,ConOpenTimes,isMoveOn,strategyPara,moeadPara,risk,TrailingStart,TrailingStop,StopLossSet,value2,varargin{:});
    
    for paretoNum=1:length(pareto)
        arg(count,:) = pareto(paretoNum).parameter;
        count = count + 1;
    end
    obj = totalobj;
    
else
    value2 = cell2mat(value2);
    [entryRecord,exitRecord] = train_ASCTrend(trainData,pro_information,risk,TrailingStart,TrailingStop,StopLossSet,value2,ConOpenTimes);
    [obj,entryRecord,exitRecord] = train_reportVar(trainData,entryRecord,exitRecord,0,pro_information,isMoveOn,varargin{:});
end

vararg{1} = {arg};

end

