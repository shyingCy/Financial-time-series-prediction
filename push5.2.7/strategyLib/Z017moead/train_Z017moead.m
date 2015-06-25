function [pareto,totalobj] = train_Z017moead( trainData,pro_information,ConOpenTimes,isMoveOn,strategyPara,moeadPara,smallswing,largeswing,TrailingStart,TrailingStop,StopLossSet,varargin)
%TRAIN_Z017_MOEAD 
 
 p.od = 4;
 p.pd = length(strategyPara);
 p.domain= strategyPara;
 p.func = @evaluate;
 
    %KNO1 evaluation function.
    function [y,obj] = evaluate(x)
        x = floor(x);
        [entryRecord,exitRecord] = ...
            train_Z017(trainData,pro_information,smallswing(:,x(1)),largeswing(:,x(2)),TrailingStart(x(3)),TrailingStop(x(4)),StopLossSet(x(5)),ConOpenTimes);
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
