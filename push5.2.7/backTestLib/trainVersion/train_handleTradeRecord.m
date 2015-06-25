function [Type,Lots,NetMargin,RateOfReturn,CostSeries] = train_handleTradeRecord(traderecord,TradingUnits,TradingCost_info)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here

% 生成对应策略和商品的交易记录，然后根据加交易记录
% 计算收益率，胜率等等
%fprintf('\n%s\n','训练版本处理交易记录...');

recordRows = size(traderecord,1);%交易记录长度

Type(:,1) = traderecord(:,1);                   %多空头类型

entryprice(:,1) = traderecord(:,4);             %开仓价格
exitprice(:,1) = traderecord(:,7);              %平仓价格
Lots(:,1) = traderecord(:,8);            %手数

%回测报告变量设置
NetMargin = zeros(recordRows,1);                  %净收益
RateOfReturn = zeros(recordRows,1);            %收益率
CostSeries = zeros(recordRows,1);              %记录交易成本

%算出每次交易的净收益
for i=1:recordRows
    
    %交易成本(建仓+平仓)
    CostSeries(i)= train_compTradingCost(exitprice(i),entryprice(i),TradingUnits,Lots(i),TradingCost_info);
    %CostSeries(i) = 10;
    if Type(i) == 1
        NetMargin(i) = (exitprice(i) - entryprice(i))*Lots(i)*TradingUnits-CostSeries(i);
    end
    
    if Type(i) == -1
        NetMargin(i) = (entryprice(i) - exitprice(i))*Lots(i)*TradingUnits-CostSeries(i);
    end
    
    temp = entryprice(i)*TradingUnits*Lots(i);
    %收益率
    RateOfReturn(i) = double(NetMargin(i))/double(temp);
end
%fprintf('\n%s\n','训练版本处理交易记录完毕...');

end

