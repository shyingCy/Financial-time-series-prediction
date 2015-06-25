function [ entryRecord,exitRecord,my_currentcontracts,obj,vararg] = for_Z017moead( strategy,bardata,pro_information,ConOpenTimes,isMoveOn,trainBeg,trainEnd,strategyArg,varargin)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

count = 1;
isTrain = varargin{1};
my_currentcontracts = varargin{2};
entryRecord = [];
exitRecord = [];
arg =[];
trainData = bardata(trainBeg:trainEnd,:);
Close = bardata(:,6);
smallswingPara = zeros(length(Close),length(strategyArg{1}));
largeswingnPara = zeros(length(Close),length(strategyArg{2}));
num = 1;
for smallswingk = strategyArg{1}
    smallswingPara(:,num) = myZigZag(Close,smallswingk);
    num = num + 1;
end

num = 1;
for largeswingn = strategyArg{2}
    largeswingnPara(:,num) = myZigZag(Close,largeswingn);
    num = num + 1;
end

trainSmallswingPara = smallswingPara(trainBeg:trainEnd,:);
trainLargeswingnPara = largeswingnPara(trainBeg:trainEnd,:);



if isTrain == 1
    strategyPara = {1:1:length(strategyArg{1});
                1:1:length(strategyArg{2});
                1:1:length(strategyArg{3});
                1:1:length(strategyArg{4});
                1:1:length(strategyArg{5})};
moeadPara = [strategyArg{6},strategyArg{7},strategyArg{8}];
TrailingStart = strategyArg{3};
TrailingStop = strategyArg{4};
StopLossSet = strategyArg{5};
    [pareto,totalobj] = ...
        train_Z017moead( trainData,pro_information,ConOpenTimes,isMoveOn,strategyPara,moeadPara,trainSmallswingPara,trainLargeswingnPara,TrailingStart,TrailingStop,StopLossSet,varargin{:});
    
    for paretoNum=1:length(pareto)
        arg(count,:) = pareto(paretoNum).parameter;
        count = count + 1;
    end
    obj = totalobj;
    
else
    smallswingPara = myZigZag(Close,strategyArg{1});
    largeswingnPara = myZigZag(Close,strategyArg{2});
    smallswing = smallswingPara(trainBeg:trainEnd);
    largeswingn = largeswingnPara(trainBeg:trainEnd);
    TrailingStart = strategyArg{3};
    TrailingStop = strategyArg{4};
    StopLossSet = strategyArg{5};
    [entryRecord,exitRecord,my_currentcontracts] = ...
        train_Z017(trainData,pro_information,smallswing,largeswingn,TrailingStart,TrailingStop,StopLossSet,ConOpenTimes);
    [obj,entryRecord,exitRecord] = train_reportVar(trainData,entryRecord,exitRecord,0,pro_information,isMoveOn,varargin{:});
end

vararg{1} = {arg};

end

