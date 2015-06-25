function [entryRecord,exitRecord,my_currentcontracts,obj,vararg] = for_priceAction(strategy,bardata,pro_information,ConOpenTimes,isMoveOn,trainBeg,trainEnd,strategyArg,varargin)
%UNTITLED9 Summary of this function goes here
%   Detailed explanation goes here

trainData = bardata(trainBeg:trainEnd,:);
count = 1;
vararg = {};
my_currentcontracts = varargin{2};
entryRecord = [];
exitRecord = [];

for refn=strategyArg{1}
    for TrailingStart=strategyArg{2}
        for TrailingStop=strategyArg{3}
            for StopLossSet=strategyArg{4}
                [entryRecord,exitRecord,my_currentcontracts] = train_priceAction(trainData,pro_information,ConOpenTimes,refn,TrailingStart,TrailingStop,StopLossSet);
                [obj(count,:),entryRecord,exitRecord] = train_reportVar(trainData,entryRecord,exitRecord,0,pro_information,isMoveOn,varargin{:});
                count = count + 1;
            end
        end
    end
end

varargout(1) = {obj};

end

