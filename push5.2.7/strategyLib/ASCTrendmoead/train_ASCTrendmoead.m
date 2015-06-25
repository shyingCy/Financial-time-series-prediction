function [pareto,totalobj] = train_ASCTrendmoead( trainData,pro_information,ConOpenTimes,isMoveOn,strategyPara,moeadPara,risk,TrailingStart,TrailingStop,StopLossSet,value2,varargin)
 
 p.od = 4;
 p.pd = length(strategyPara);
 p.domain= strategyPara;
 p.func = @evaluate;
 
    %KNO1 evaluation function.
    function [y,obj] = evaluate(x)
        x = floor(x);
        [entryRecord,exitRecord] = ...
            train_ASCTrend(trainData,pro_information,risk(x(1)),TrailingStart(x(2)),TrailingStop(x(3)),StopLossSet(x(4)),value2{x(1)},ConOpenTimes);
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
