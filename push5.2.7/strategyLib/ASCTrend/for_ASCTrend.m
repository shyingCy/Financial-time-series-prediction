function [ entryRecord,exitRecord,my_currentcontracts,obj,vararg ] = for_ASCTrend( strategy,bardata,pro_information,ConOpenTimes,isMoveOn,trainBeg,trainEnd,strategyArg,varargin )
%UNTITLED11 Summary of this function goes here
%   Detailed explanation goes here

count = 1;
vararg = {};
my_currentcontracts = varargin{2};
entryRecord = [];
exitRecord = [];
trainData = bardata(trainBeg:trainEnd,:);

for risk=strategyArg{1}
    value10 = 3 + risk*2;
    if trainBeg > value10
        data = bardata(trainBeg-value10:trainEnd,:);
        value2 = ASC(strategy,data,pro_information,risk);
        value2 = value2(value10+1:value10+size(trainData,1));
    else
        data = trainData;
        value2 = ASC(strategy,data,pro_information,risk);
    end
    for TrailingStart=strategyArg{2}
        for TrailingStop=strategyArg{3}
            for StopLossSet=strategyArg{4}
                [entryRecord,exitRecord] = train_ASCTrend(trainData,pro_information,risk,TrailingStart,TrailingStop,StopLossSet,value2,ConOpenTimes);
                [obj(count,:),entryRecord,exitRecord] = train_reportVar(trainData,entryRecord,exitRecord,0,pro_information,isMoveOn,varargin{:});
                count = count + 1;
            end
        end
    end
end

end

