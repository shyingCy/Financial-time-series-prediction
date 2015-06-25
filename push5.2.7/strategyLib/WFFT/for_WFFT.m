function [entryRecord,exitRecord,my_currentcontracts,obj,vararg] = for_WFFT( strategy,bardata,pro_information,ConOpenTimes,isMoveOn,trainBeg,trainEnd,strategyArg,varargin )
%UNTITLED10 Summary of this function goes here
%   Detailed explanation goes here

trainData = bardata(trainBeg:trainEnd,:);
count = 1;
vararg = {};
my_currentcontracts = varargin{2};
entryRecord = [];
exitRecord = [];
for N=strategyArg{1}
    for len=strategyArg{2}
        for q=strategyArg{3}
            for Tq =strategyArg{4}
                for Length = strategyArg{5}
                    for Dq = strategyArg{6}
                        con = WFFTcon(strategy,bardata,pro_information,N,len,q,Tq,Length,Dq);
                        con = con(trainBeg:trainEnd);
                        [entryRecord,exitRecord] = ...
                            train_WFFT(trainData,pro_information,con,ConOpenTimes);
                        [obj(count,:),entryRecord,exitRecord] = train_reportVar(trainData,entryRecord,exitRecord,0,pro_information,isMoveOn,varargin{:});
                        count = count + 1;
                    end
                end
            end
        end
    end
end

varargout(1) = {obj};

end

