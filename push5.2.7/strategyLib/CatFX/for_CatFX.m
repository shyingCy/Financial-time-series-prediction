function [ entryRecord,exitRecord,my_currentcontracts,obj,vararg ] = for_CatFX( strategy,bardata,pro_information,ConOpenTimes,isMoveOn,trainBeg,trainEnd,strategyArg,varargin )
%UNTITLED11 Summary of this function goes here
%   Detailed explanation goes here

count = 1;
vararg = {};
my_currentcontracts = varargin{2};
entryRecord = [];
exitRecord = [];
trainData = bardata(trainBeg:trainEnd,:);

for Length=strategyArg{1}
    for Period=strategyArg{2}
        con = CatCon( strategy,bardata,pro_information,Period,Length );
        con = con(trainBeg:trainEnd);
        [entryRecord,exitRecord] = train_CatFX(trainData,pro_information,con,ConOpenTimes);
        [obj(count,:),entryRecord,exitRecord] = train_reportVar(trainData,entryRecord,exitRecord,0,pro_information,isMoveOn,varargin{:});
        count = count + 1;
    end
end

varargout(1) = {obj};

end

