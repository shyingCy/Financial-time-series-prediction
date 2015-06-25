function [entryRecord,exitRecord,my_currentcontracts,obj,vararg] = for_MESproM5(strategy,bardata,pro_information,ConOpenTimes,isMoveOn,trainBeg,trainEnd,strategyArg,varargin )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

trainData = bardata(trainBeg:trainEnd,:);
count = 1;
vararg = {};
my_currentcontracts = varargin{2};
entryRecord = [];
exitRecord = [];
obj = [];

for M=strategyArg{1}
    for N=strategyArg{2}
        for E=strategyArg{3}
            for StopLossRate=strategyArg{4}
                
                [entryRecord,exitRecord,my_currentcontracts] = ...
                    train_MESproM5(trainData,pro_information,M,N,E,StopLossRate,ConOpenTimes);
                
                [obj(count,:),entryRecord,exitRecord] = train_reportVar(trainData,entryRecord,exitRecord,0,pro_information,isMoveOn,varargin{:});
                count = count + 1;
            end
        end
    end
end

end

