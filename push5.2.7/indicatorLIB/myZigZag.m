function [ZZ] = myZigZag(price,prozent)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

% Datestartstr = datestr(Date(1));

richtung=0;

barLength = size(price,1);

SF=0;
SF(1,1)=richtung;

% Algorithmus
j=1;
neighBorBar = 1; %SwingHighPrice = SwingHigh( 1, Close, 1,2);这条公式中的第三个参数
numberBar = 1;  %SwingHighPrice = SwingHigh( 1, Close, 1,2);这条公式中的第1个参数
backBar = 2; %SwingHighPrice = SwingHigh( 1, Close, 1,2);这条公式中的最后一个参数
backTraceBar = 1; %向前回溯backTraceBar个K
% ZZ(1:backBar+backTraceBar+1,1) = Date(1:backBar+backTraceBar+1);
ZZ=zeros(barLength,1);
ZZ(1:backBar+backTraceBar+1,1) = repmat(price(1),backBar+backTraceBar+1,1);
if backBar==2
    if price(1) > price(2)
        SwingHighPrice = price(1);
        SwingLowPrice = 0;
        SwingPrice = SwingHighPrice;
    else
        SwingLowPrice = price(1);
        SwingHighPrice = 0;
        SwingPrice = SwingLowPrice;
    end
end
for i=backBar+backTraceBar+1:barLength
    %原版本是直接用价格而不是TB里的SwingHighprice
    %算出最近2条k左右至少有一条K的第一个swinghighprice或者swinglowprice
    %也就是TB里面的SwingHighPrice = SwingHigh( 1, Close, 1,2);这条公式
    if price(i-1-backTraceBar) > price(i-backTraceBar) && price(i-1-backTraceBar) >= price(i-backBar-backTraceBar)
        SwingHighPrice = price(i-1-backTraceBar);
%         Sw(i,1) = cellstr('SwingHighP');
%         Sw(i,2) = cellstr(datestr(Date(i),'yyyy-mm-dd'));
%         Sw(i,3) = num2cell(SwingHighPrice);
    elseif price(i-1-backTraceBar) < price(i-backTraceBar) && price(i-1-backTraceBar) <= price(i-backBar-backTraceBar)
        SwingLowPrice = price(i-1-backTraceBar);
%         Sw(i,1) = cellstr('SwingLow');
%         Sw(i,2) = cellstr(datestr(Date(i),'yyyy-mm-dd'));
%         Sw(i,3) = num2cell(SwingLowPrice);
    end
     
    ZZ(i,1) = ZZ(i-1,1);
    
    if SwingHighPrice~=0
        relKurs  = (SwingHighPrice-ZZ(i,1))/ZZ(i,1)*100;
        
        if (richtung<=0)&&(relKurs>=prozent)
            ZZ(i,1) = SwingHighPrice;
            richtung=1;
        elseif (richtung==1)&&(SwingHighPrice >= ZZ(i,1))
            ZZ(i,1) = SwingHighPrice;
        end
    elseif SwingLowPrice~=0
        relKurs  = (SwingLowPrice-ZZ(i,1))/ZZ(i,1)*100;
        
        if (richtung>=0)&&(-relKurs>=prozent)
            ZZ(i,1) = SwingLowPrice;
            richtung=-1;
        elseif (richtung==-1)&&(SwingLowPrice <= ZZ(i,1))
            ZZ(i,1) = SwingLowPrice;
        end
    end
    SwingHighPrice = 0;
    SwingLowPrice = 0;
end

% Letzter Kurs beendet auch den ZigZag-Kurs. Egal ob
% positive oder negative Richtung. Die Richtung kann sich
% erst durch zuk黱ftige Kurse 鋘dern.

% axis([Date(1) Date(end) min(price) max(price)]);
% dateaxis('x',2,Datestartstr);
% 
% plot(ZZ(:,1),ZZ(:,2)','linestyle','--', 'linewidth',3,'color','r')

end

