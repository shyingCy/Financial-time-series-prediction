function HPFminuteClose = HPF( price,a )
%UNTITLED2 Summary of this function goes here
%¶þ½×¸ßÍ¨ÂË²¨Æ÷
%   Detailed explanation goes here
m=length(price);
HPFminuteClose(1)=price(1);
HPFminuteClose(2)=price(2);
for i=3:m
    HPFminuteClose(i)=((1-a/2)^2)*(price(i)-2*price(i-1)+price(i-2))+2*(1-a)*HPFminuteClose(i-1)-((1-a)^2)*HPFminuteClose(i-2);
end

