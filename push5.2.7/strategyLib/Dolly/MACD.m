function [ Diff ] = MACD( Price,FastLength,SlowLength,MACDLength )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

MACDvalue = EMA(Price,FastLength)-EMA(Price,SlowLength);
AvgMACD = EMA(MACDvalue,MACDLength);
Diff = MACDvalue-AvgMACD;

end

