function [entryRecord,exitRecord,my_currentcontracts,obj,vararg] = for_Phase( strategy,bardata,pro_information,ConOpenTimes,isMoveOn,trainBeg,trainEnd,strategyArg,varargin )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

trainData = bardata(trainBeg:trainEnd,:);
count = 1;
vararg = {};
my_currentcontracts = varargin{2};
entryRecord = [];
exitRecord = [];
obj = [];
for Cycle=strategyArg{1}
    MAClose = MA(bardata,Cycle);
    %ALL 计算Z 补到bardata长度
    %用前面的trainBeg和trainEnd截出训练的希尔博特
    for M=strategyArg{2}
        Flag = ReturnFlagPhase(bardata,M,MAClose);%在此处判断是否足够2*M+1 %整段处理是否太过浪费(?)
        FlagSome=Flag(trainBeg:trainEnd);%找到对应的希尔伯特变换序列
        [entryRecord,exitRecord] = train_Phase(trainData,FlagSome,pro_information,ConOpenTimes);
        [obj(count,:),entryRecord,exitRecord] = train_reportVar(trainData,entryRecord,exitRecord,0,pro_information,isMoveOn,varargin{:});
        count = count + 1;
    end
end

end

