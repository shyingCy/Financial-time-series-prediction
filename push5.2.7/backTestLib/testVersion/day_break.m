function total_profit=day_break(bardata,f)

%数据库连接以及读取数据 begin
pro = 'IF888';
Freq = 'M5';
strategy = 'day_break';
%交易相关变量设置 begin
status = 0; %记录做多做空，1做多，-1做空
profit = [];
totalprofit = [];
%交易相关变量设置 end

%品种参数
Lots=1;                                       %交易手数
[m,n] = size(bardata);
minuteClose = bardata(:,6);
minuteOpen = bardata(:,3);
minuteHigh = bardata(:,4);
minuteLow = bardata(:,5);
date = bardata(:,1);
time = bardata(:,2);
minuteRows = m;
entryCount = 0; %建仓价格时间序号
exitCount = 0;%平仓价格时间序号
con=0;
day_con=0;%判断是否为新的一天
%简单日内突破
for i=1:minuteRows
    if con==0
        up=minuteOpen(i)*(1+f*0.001);
        down=minuteOpen(i)*(1-f*0.001);
        openD=minuteOpen(i); 
        con=1; 
    end
    
    if minuteHigh(i)>up && day_con==0
        if(status==0)
            entryCount = entryCount + 1;
            entryprice(entryCount) = max([up,minuteOpen(i)]);    %记录开仓价格
            entryDate(entryCount,:) = date(i,:);  %记录开仓时间
            entryTime(entryCount,:) = time(i,:);
            %disp(entryprice(entryCount))
            %buy(strategy,pro,Freq,entryDate(entryCount,:),entryTime(entryCount,:),entryprice(entryCount),Lots);
            status=1;
            day_con=1;
        end
    end
    if minuteLow(i)<down && day_con==0
        if(status==0)
            entryCount = entryCount + 1;
            entryprice(entryCount) = min([down,minuteOpen(i)]);    %记录开仓价格
            entryDate(entryCount,:) = date(i,:);  %记录开仓时间
            entryTime(entryCount,:) = time(i,:);
            %disp(entryprice(entryCount))
            %sellsort(strategy,pro,Freq,entryDate(entryCount,:),entryTime(entryCount,:),entryprice(entryCount),Lots);
            status=-1;
            day_con=1;
        end
    end
    if status==1
        if (minuteLow(i)<openD) && (time(i,:)~=entryTime(entryCount,:))
            exitCount = exitCount + 1;
            exitDate(exitCount,:) = date(i,:);   %记录平仓时间
            exitTime(exitCount,:) = time(i,:);
            exitprice(exitCount) = min([minuteOpen(i),openD]); %记录平仓价格
            %sell(strategy,pro,Freq,exitDate(exitCount,:),exitTime(exitCount,:),exitprice(exitCount),Lots);
            profit(exitCount) = (exitprice(exitCount) - entryprice(entryCount))*Lots*300 - 10; %平仓
            totalprofit(exitCount) = sum(profit(1:end));
            status=0;
            day_con=1;
        end
    end
    if status==-1
        if (minuteHigh(i)>openD) && (time(i,:)~=entryTime(entryCount,:))
            exitCount = exitCount + 1;
            exitDate(exitCount,:) = date(i,:);   %记录平仓时间
            exitTime(exitCount,:) = time(i,:);
            exitprice(exitCount) = max([minuteOpen(i),openD]); %记录平仓价格
            %buyToCover(strategy,pro,Freq,exitDate(exitCount,:),exitTime(exitCount,:),exitprice(exitCount),Lots);
            profit(exitCount) = (entryprice(entryCount) - exitprice(exitCount))*Lots*300-10; %平仓
            totalprofit(exitCount) = sum(profit(1:end));
            status=0;
        end
    end
    if i==minuteRows || date(i,:)~=date(i+1,:) %日末
        con=0;
        day_con=0;
        if status==1
            exitCount = exitCount + 1;
            exitDate(exitCount,:) = date(i,:);   %记录平仓时间
            exitTime(exitCount,:) = time(i,:);
            exitprice(exitCount) = minuteClose(i); %记录平仓价格
            %sell(strategy,pro,Freq,exitDate(exitCount,:),exitTime(exitCount,:),exitprice(exitCount),Lots);
            profit(exitCount) = (exitprice(exitCount) - entryprice(entryCount))*Lots*300 - 10; %平仓
            totalprofit(exitCount) = sum(profit(1:end));
            status=0;
        end
        if status==-1
            exitCount = exitCount + 1;
            exitDate(exitCount,:) = date(i,:);   %记录平仓时间
            exitTime(exitCount,:) = time(i,:);
            exitprice(exitCount) = minuteClose(i); %记录平仓价格
            %buyToCover(strategy,pro,Freq,exitDate(exitCount,:),exitTime(exitCount,:),exitprice(exitCount),Lots);
            profit(exitCount) = (entryprice(entryCount) - exitprice(exitCount))*Lots*300-10; %平仓
            totalprofit(exitCount) = sum(profit(1:end));
            status=0;
        end
        
    end
end

% if entryCount > 1
%    plot(totalprofit(1:end));
% end
total_profit=totalprofit(end);
%report('day_break','IF888','M5');
% save data;

        
        
        

