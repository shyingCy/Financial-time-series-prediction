function [ entryRecord,exitRecord,my_currentcontracts,obj,vararg ] = for_Z006( strategy,bardata,pro_information,ConOpenTimes,isMoveOn,trainBeg,trainEnd,strategyArg,varargin )
%UNTITLED11 Summary of this function goes here
%   Detailed explanation goes here

count = 1;
vararg = {};
my_currentcontracts = varargin{2};
entryRecord = [];
exitRecord = [];
offset = 2;
if trainBeg < offset+1
    trainData = bardata(trainBeg:trainEnd,:);
else
    trainData = bardata(trainBeg-offset:trainEnd,:);
end
Close = bardata(:,6);
for refn=strategyArg{1}
    swingprice = myZigZag(Close,refn);
    if trainBeg < offset+1
        trainSwingprice = swingprice(trainBeg:trainEnd,:);
    else
        trainSwingprice = swingprice(trainBeg-offset:trainEnd,:);
    end
    for TrailingStart=strategyArg{2}
        for TrailingStop=strategyArg{3}
            for StopLossSet=strategyArg{4}
                [entryRecord,exitRecord,my_currentcontracts] = train_Z006(trainData,pro_information,ConOpenTimes,my_currentcontracts,trainSwingprice,TrailingStart,TrailingStop,StopLossSet);
                [obj(count,:),entryRecord,exitRecord] = train_reportVar(trainData,entryRecord,exitRecord,0,pro_information,isMoveOn,varargin{:});
                count = count + 1;
            end
        end
    end
end

end

