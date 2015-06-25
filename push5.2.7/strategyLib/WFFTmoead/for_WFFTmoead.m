function [ entryRecord,exitRecord,my_currentcontracts,obj,vararg] = for_WFFTmoead( strategy,bardata,pro_information,ConOpenTimes,isMoveOn,trainBeg,trainEnd,strategyArg,varargin)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

count = 1;
isTrain = varargin{1};
vararg = {};
arg = [];
my_currentcontracts = varargin{2};
entryRecord = [];
exitRecord = [];
trainData = bardata(trainBeg:trainEnd,:);

if isTrain == 1
    strategyPara = {1:1:length(strategyArg{1});
        1:1:length(strategyArg{2});
        1:1:length(strategyArg{3});
        1:1:length(strategyArg{4});
        1:1:length(strategyArg{5});
        1:1:length(strategyArg{6})};
    moeadPara = [strategyArg{7},strategyArg{8},strategyArg{9}];
    N = strategyArg{1};
    len = strategyArg{2};
    q = strategyArg{3};
    Tq = strategyArg{4};
    Length = strategyArg{5};
    Dq = strategyArg{6};
    [pareto,totalobj] = ...
        train_WFFTmoead( bardata,trainBeg,trainEnd,pro_information,ConOpenTimes,isMoveOn,strategyPara,moeadPara,N,len,q,Tq,Length,Dq,varargin{:});
    
    for paretoNum=1:length(pareto)
        arg(count,:) = pareto(paretoNum).parameter;
        count = count + 1;
    end
    obj = totalobj;
    
else
    N = strategyArg{1};
    len = strategyArg{2};
    q = strategyArg{3};
    Tq = strategyArg{4};
    Length = strategyArg{5};
    Dq = strategyArg{6};
    con = WFFTcon(bardata,pro_information,N,len,q,Tq,Length,Dq);
    con = con(trainBeg:trainEnd);
    [entryRecord,exitRecord] = train_WFFT(trainData,pro_information,con,ConOpenTimes);
    [obj,entryRecord,exitRecord] = train_reportVar(trainData,entryRecord,exitRecord,0,pro_information,isMoveOn,varargin{:});
end

vararg{1} = {arg};

end

