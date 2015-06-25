function [entryRecord,exitRecord,my_currentcontracts,obj,vararg] = for_LLT( strategy,bardata,pro_information,ConOpenTimes,isMoveOn,trainBeg,trainEnd,strategyArg,varargin )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

trainData = bardata(trainBeg:trainEnd,:);
Close = bardata(:,6);
count = 1;
vararg = {};
my_currentcontracts = varargin{2};
entryRecord = [];
exitRecord = [];
obj = [];
for Length=strategyArg{1}
    a=2/(Length+1);% α值
    for t=1:2
        LLTvalue(t) = Close(t);
    end
    for t = 3:length(Close)   %计算LLT趋势线
        LLTvalue(t)=(a-0.25*a^2)*Close(t)+0.5*a^2*Close(t-1)-(a-0.75*a^2)*Close(t-2)+(2-2*a)*LLTvalue(t-1)-(1-a)^2*LLTvalue(t-2);
    end
    d = zeros(length(LLTvalue),1);
    d(2:end)=diff(LLTvalue); %求差分
    for q=strategyArg{2}
        trainDiff = d(trainBeg:trainEnd);
        [entryRecord,exitRecord,my_currentcontracts] = train_LLT(trainData,pro_information,trainDiff,q,ConOpenTimes);
        [obj(count,:),entryRecord,exitRecord] = train_reportVar(trainData,entryRecord,exitRecord,0,pro_information,isMoveOn,varargin{:});
        count = count + 1;
    end
end

varargout(1) = {obj};

end

