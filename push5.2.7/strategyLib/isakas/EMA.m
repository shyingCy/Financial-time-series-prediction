function [ ema ] = EMA( Price,Length )
%UNTITLED6 Summary of this function goes here
%   Detailed explanation goes here

sFcactor = 2/(Length+1);
barLength=size(Price,1);

ema=zeros(barLength,1);
ema(1)=Price(1);
for i=2:barLength
    ema(i)= ema(i-1)+sFcactor*(Price(i)-ema(i-1));
end


end

