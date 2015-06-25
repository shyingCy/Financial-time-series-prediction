function [ Diff ] = trainMACD( Price,FastLength,SlowLength,MACDLength )
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here

sFcactor(1) = 2/(FastLength+1);
sFcactor(2) = 2/(SlowLength+1);
sFcactor(3) = 2/(MACDLength+1);
barLength=size(Price,1);

MACDvalue1=zeros(barLength,1);
MACDvalue2=zeros(barLength,1);
MACDvalue=zeros(barLength,1);
AvgMACD=zeros(barLength,1);

MACDvalue1(1)=Price(1);
MACDvalue2(1)=Price(1);
MACDvalue(1) = MACDvalue1(1) - MACDvalue2(1);
AvgMACD(1)=MACDvalue(1);

for i=2:barLength
    MACDvalue1(i)= MACDvalue1(i-1)+sFcactor(1)*(Price(i)-MACDvalue1(i-1));
    MACDvalue2(i)= MACDvalue2(i-1)+sFcactor(2)*(Price(i)-MACDvalue2(i-1));
    MACDvalue(i) = MACDvalue1(i) - MACDvalue2(i);
    AvgMACD(i)= AvgMACD(i-1)+sFcactor(3)*(MACDvalue(i)-AvgMACD(i-1));
end

Diff = MACDvalue-AvgMACD;

end

