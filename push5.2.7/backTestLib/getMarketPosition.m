function [ MarketPosition ] = getMarketPosition( currentcontracts )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

if currentcontracts == 0
    MarketPosition = 0;
elseif currentcontracts < 0
    MarketPosition = -1;
elseif currentcontracts > 0
    MarketPosition = 1;
end

end

