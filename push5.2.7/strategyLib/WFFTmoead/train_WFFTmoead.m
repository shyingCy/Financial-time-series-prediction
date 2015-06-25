function [pareto,totalobj] = train_WFFTmoead( bardata,trainBeg,trainEnd,pro_information,ConOpenTimes,isMoveOn,strategyPara,moeadPara,N,len,q,Tq,Length,Dq,varargin)
 
 p.od = 4;
 p.pd = length(strategyPara);
 p.domain= strategyPara;
 p.func = @evaluate;
 
 %KNO1 evaluation function.
    function [y,obj] = evaluate(x)
        x = floor(x);
        con = WFFTcon(bardata,pro_information,N(x(1)),len(x(2)),q(x(3)),Tq(x(4)),Length(x(5)),Dq(x(6)));
        con = con(trainBeg:trainEnd);
        trainData = bardata(trainBeg:trainEnd);
        [entryRecord,exitRecord] = ...
            train_WFFT(trainData,pro_information,con,ConOpenTimes);
        [obj] = train_reportVar(trainData,entryRecord,exitRecord,0,pro_information,isMoveOn,varargin{:});
        y(1)= (-1) * obj(1);
        y(2) = obj(2);
        y(3) = obj(3);
        y(4)= (-1) * obj(5);
        y = y';
        obj = obj';
    end

[pareto,totalobj] = moead( p, 'popsize', moeadPara(1), 'niche', moeadPara(2), 'iteration', moeadPara(3), 'method', 'te');

end
