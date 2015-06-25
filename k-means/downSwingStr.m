

begT = '2010-05-01';
endT = '2010-09-01';
sql = ['select Close,Date,Time from if000_M1 where Date>''',begT,'''and Date < ''',endT,''';'];
bardata = getBarData(sql);
Close = cell2mat(bardata(:,1));
Date = exchangeDateToNum(bardata(:,2),bardata(:,3));

DayBegTime = [];    %每天的第一时刻
DayEndTime = [];    %每天的最后一刻

%提取每天的第一刻和最后一刻
for i=2:length(Date)
    yestD = Date(i-1,:);
    if day(Date(i,:)) ~= day(yestD)  %过日，记录昨天的最后一个时刻
        DayBegTime = Date(i,:);
        DayEndTime = yestD;
        break;
    end
end
before6Time = DayEndTime - datenum('0000-01-00 00:30:00','yyyy-mm-dd HH:MM:SS');    %datenum是从0000-01-00开始计算的，所以月份必须为1月
betweenI = find(Date==DayEndTime) - find(Date==before6Time); %算出最后半个小时所含数据数量
begI = find(hour(Date)==hour(DayBegTime)&minute(Date)==minute(DayBegTime)&second(Date)==second(DayBegTime));   %找出每天的第一刻数据的下标
endI = find(hour(Date)==hour(DayEndTime)&minute(Date)==minute(DayEndTime)&second(Date)==second(DayEndTime));   %找出每天的最后一刻数据的下标

%用每天收盘价除以每天开盘价-1来算出收益率
DayPro = Close(endI)./Close(begI) - 1;
%提取最后半小时数据
[m n] = size(endI);
m=m-1;
for i=1:m %m-1是为了留下一个最后可以算收益率
    before6Close(i,:) = Close(endI(i)-betweenI+1:endI(i));
end

%
data = mapminmax(before6Close);
K = 5;
[u re] = KMeans(data,K);
K_Pro = zeros(K,1);

for i=1:K
    k_index = find(re(:,end)==i);
    K_Pro(i) = mean(DayPro(k_index+1));
end

%测试交易

begT = '2010-05-01';
endT = '2010-09-01';
begT = endT;
endT = datestr(datenum(endT,'yyyy-mm-dd')+datenum('0001-01-00','yyyy-mm-dd'),'yyyy-mm-dd');
sql = ['select Close,Date,Time from if000_M1 where Date>''',begT,'''and Date < ''',endT,''';'];
bardata = getBarData(sql);
testClose = cell2mat(bardata(:,1));
testDate = exchangeDateToNum(bardata(:,2),bardata(:,3));

DayBegTime = [];    %每天的第一时刻
DayEndTime = [];    %每天的最后一刻

%提取每天的第一刻和最后一刻
for i=2:length(testDate)
    yestD = testDate(i-1,:);
    if day(testDate(i,:)) ~= day(yestD)  %过日，记录昨天的最后一个时刻
        DayBegTime = testDate(i,:);
        DayEndTime = yestD;
        break;
    end
end
before6Time = DayEndTime - datenum('0000-01-00 00:30:00','yyyy-mm-dd HH:MM:SS');    %datenum是从0000-01-00开始计算的，所以月份必须为1月
betweenI = find(testDate==DayEndTime) - find(testDate==before6Time); %算出最后半个小时所含数据数量

begI = find(hour(testDate)==hour(DayBegTime)&minute(testDate)==minute(DayBegTime)&second(testDate)==second(DayBegTime));   %找出每天的第一刻数据的下标
endI = find(hour(testDate)==hour(DayEndTime)&minute(testDate)==minute(DayEndTime)&second(testDate)==second(DayEndTime));   %找出每天的最后一刻数据的下标

%用每天收盘价除以每天开盘价-1来算出收益率
testDayPro = testClose(endI)./testClose(begI) - 1;
%提取最后半小时数据
[m n] = size(endI);
m=m-1;
for i=1:m %m-1是为了留下一个最后可以算收益率
    testbefore6Close(i,:) = testClose(endI(i)-betweenI+1:endI(i));
end

testre=[];
[m n] = size(testbefore6Close);
K = 5;
for i=1:m
    tmp=[];
    for j=1:K
        tmp=[tmp norm(testbefore6Close(i,:)-u(j,:))];
    end
    [junk index]=min(tmp);
    testre=[testre;testbefore6Close(i,:) index];
end
