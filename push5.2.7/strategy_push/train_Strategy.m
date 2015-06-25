 function [entryRecord,exitRecord,my_currentcontracts,obj,vararg] = train_Strategy(strategy,trainData,pro_information,ConOpenTimes,isMoveOn,totalBeg,totalEnd,strategyArg,varargin)
%UNTITLED6 Summary of this function goes here
%   Detailed explanation goes here
%2015.04.03

strategyFun = ['for','_',strategy];
trainFun=eval(['@',strategyFun,';']);
[entryRecord,exitRecord,my_currentcontracts,obj,vararg] = trainFun(strategy,trainData,pro_information,ConOpenTimes,isMoveOn,totalBeg,totalEnd,strategyArg,varargin{:});

 end