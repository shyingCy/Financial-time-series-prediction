function SFminuteClose = SF( price )
%UNTITLED2 Summary of this function goes here
%¶þ½×¸ßÍ¨ÂË²¨Æ÷
%   Detailed explanation goes here
m=length(price);
a=0.05;
SFminuteClose(1)=price(1);
SFminuteClose(2)=price(2);
for i=3:m
    SFminuteClose(i)=((1-a/2)^2)*(price(i)-2*price(i-1)+price(i-2))+2*(1-a)*SFminuteClose(i-1)-((1-a)^2)*SFminuteClose(i-2);
end

