function [entryRecord,exitRecord,my_currentcontracts,obj,vararg] = for_isakas( strategy,bardata,pro_information,ConOpenTimes,isMoveOn,trainBeg,trainEnd,strategyArg,varargin )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

trainData = bardata(trainBeg:trainEnd,:);
count = 1;
vararg = {};
my_currentcontracts = varargin{2};
entryRecord = [];
exitRecord = [];
obj = [];
for Length_1=strategyArg{1}
    cycle=4;
    phase=Length_1-1;
    len=Length_1*cycle+phase;
    for filter=strategyArg{2}
        for Length=strategyArg{3}
            if trainBeg>len*2-1
                Data = bardata(trainBeg-(len*2-1):trainEnd,:);
                con = isakasCon(strategy,Data,pro_information,Length_1,filter,Length);
                con = con(len*2:len*2+trainEnd-trainBeg);
            else
                Data = trainData;
                con = isakasCon(strategy,Data,pro_information,Length_1,filter,Length);
            end
            [entryRecord,exitRecord] = train_isakas(trainData,pro_information,con,ConOpenTimes);
            [obj(count,:),entryRecord,exitRecord] = train_reportVar(trainData,entryRecord,exitRecord,0,pro_information,isMoveOn,varargin{:});
            count = count + 1;
        end
    end
end

varargout(1) = {obj};

end

