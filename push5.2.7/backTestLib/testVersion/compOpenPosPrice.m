function OpenPosPrice = compOpenPosPrice(entryprice,myOpenIntRecord)

%计算开仓用的点数，还没乘上交易单位的
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
myOpenInt = sum(myOpenIntRecord(:,2));
OpenPosPrice = 0;

if myOpenInt ~=0
    for num=1:length(myOpenIntRecord(:,1))
        OpenPosPrice = OpenPosPrice+entryprice(myOpenIntRecord(num,1))*myOpenIntRecord(num,2);    %开仓用资金
    end
end

%OpenPosPrice = OpenPosPrice/sum(myOpenIntRecord(:,2));

end

