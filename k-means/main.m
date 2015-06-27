% clear all;
% close all;
% clc;
% 
% begT = '2010-05-01';
% endT = '2010-09-01';
% sql = ['select Close,Date,Time from if000_M1 where Date>''',begT,'''and Date < ''',endT,''';'];
% bardata = getBarData(sql);
% Close = cell2mat(bardata(:,1));
% Date = exchangeDateToNum(bardata(:,2),bardata(:,3));
% 
% DayBegTime = [];    %每天的第一时刻
% DayEndTime = [];    %每天的最后一刻
% 
% %提取每天的第一刻和最后一刻
% for i=2:length(Date)
%     yestD = Date(i-1,:);
%     if day(Date(i,:)) ~= day(yestD)  %过日，记录昨天的最后一个时刻
%         DayBegTime = Date(i,:);
%         DayEndTime = yestD;
%         break;
%     end
% end
% before6Time = DayEndTime - datenum('0000-01-00 00:30:00','yyyy-mm-dd HH:MM:SS');    %datenum是从0000-01-00开始计算的，所以月份必须为1月
% betweenI = find(Date==DayEndTime) - find(Date==before6Time); %算出最后半个小时所含数据数量
% begI = find(hour(Date)==hour(DayBegTime)&minute(Date)==minute(DayBegTime)&second(Date)==second(DayBegTime));   %找出每天的第一刻数据的下标
% endI = find(hour(Date)==hour(DayEndTime)&minute(Date)==minute(DayEndTime)&second(Date)==second(DayEndTime));   %找出每天的最后一刻数据的下标
% 
% %用每天收盘价除以每天开盘价-1来算出收益率
% DayPro = Close(endI)./Close(begI) - 1;
% %提取最后半小时数据
% [m n] = size(endI);
% m=m-1;
% for i=1:m %m-1是为了留下一个最后可以算收益率
%     before6Close(i,:) = Close(endI(i)-betweenI+1:endI(i));
% end
% 
% %
% data = mapminmax(before6Close);
% K = 5;
% [u re] = KMeans(data,K);
% K_Pro = zeros(K,1);
% 
% for i=1:K
%     k_index = find(re(:,end)==i);
%     K_Pro(i) = mean(DayPro(k_index+1));
% end
% 
% %测试交易
% 
% begT = '2010-05-01';
% endT = '2010-09-01';
% begT = endT;
% endT = datestr(datenum(endT,'yyyy-mm-dd')+datenum('0001-01-00','yyyy-mm-dd'),'yyyy-mm-dd');
% sql = ['select Close,Date,Time from if000_M1 where Date>''',begT,'''and Date < ''',endT,''';'];
% bardata = getBarData(sql);
% testClose = cell2mat(bardata(:,1));
% testDate = exchangeDateToNum(bardata(:,2),bardata(:,3));
% 
% DayBegTime = [];    %每天的第一时刻
% DayEndTime = [];    %每天的最后一刻
% 
% %提取每天的第一刻和最后一刻
% for i=2:length(testDate)
%     yestD = testDate(i-1,:);
%     if day(testDate(i,:)) ~= day(yestD)  %过日，记录昨天的最后一个时刻
%         DayBegTime = testDate(i,:);
%         DayEndTime = yestD;
%         break;
%     end
% end
% before6Time = DayEndTime - datenum('0000-01-00 00:30:00','yyyy-mm-dd HH:MM:SS');    %datenum是从0000-01-00开始计算的，所以月份必须为1月
% betweenI = find(testDate==DayEndTime) - find(testDate==before6Time); %算出最后半个小时所含数据数量
% 
% begI = find(hour(testDate)==hour(DayBegTime)&minute(testDate)==minute(DayBegTime)&second(testDate)==second(DayBegTime));   %找出每天的第一刻数据的下标
% endI = find(hour(testDate)==hour(DayEndTime)&minute(testDate)==minute(DayEndTime)&second(testDate)==second(DayEndTime));   %找出每天的最后一刻数据的下标
% 
% %用每天收盘价除以每天开盘价-1来算出收益率
% testDayPro = testClose(endI)./testClose(begI) - 1;
% %提取最后半小时数据
% [m n] = size(endI);
% m=m-1;
% for i=1:m %m-1是为了留下一个最后可以算收益率
%     testbefore6Close(i,:) = testClose(endI(i)-betweenI+1:endI(i));
% end
% 
% testre=[];
% [m n] = size(testbefore6Close);
% K = 5;
% for i=1:m
%     tmp=[];
%     for j=1:K
%         tmp=[tmp norm(testbefore6Close(i,:)-u(j,:))];
%     end
%     [junk index]=min(tmp);
%     testre=[testre;testbefore6Close(i,:) index];
% end
% 
% 
% %% 
% [m n] = size(re);
% hold on;
% for i=1:m
%     if re(i,end)==1
%         plot(re(i,1:end-1),'r');
%     elseif re(i,end)==2
%         plot(re(i,1:end-1),'g');
%     elseif re(i,end)==3
%         plot(re(i,1:end-1),'b');
%     elseif re(i,end)==4
%         plot(re(i,1:end-1),'y');
%     else
%         plot(re(i,1:end-1),'m');
%     end
% end
% grid on;
% %% 
% %第一类数据
% mu1=[0 0 0];  %均值
% S1=[0.3 0 0;0 0.35 0;0 0 0.3];  %协方差
% data1=mvnrnd(mu1,S1,100);   %产生高斯分布数据
% 
% %%第二类数据
% mu2=[1.25 1.25 1.25];
% S2=[0.3 0 0;0 0.35 0;0 0 0.3];
% data2=mvnrnd(mu2,S2,100);
% 
% %第三个类数据
% mu3=[-1.25 1.25 -1.25];
% S3=[0.3 0 0;0 0.35 0;0 0 0.3];
% data3=mvnrnd(mu3,S3,100);
% 
% %显示数据
% plot3(data1(:,1),data1(:,2),data1(:,3),'+');
% hold on;
% plot3(data2(:,1),data2(:,2),data2(:,3),'r+');
% plot3(data3(:,1),data3(:,2),data3(:,3),'g+');
% grid on;
% 
% %三类数据合成一个不带标号的数据类
% data=[data1;data2;data3];   %这里的data是不带标号的
% 
% %k-means聚类
% [u re]=KMeans(data,3);  %最后产生带标号的数据，标号在所有数据的最后，意思就是数据再加一维度
% [m n]=size(re);
% 
% %最后显示聚类后的数据
% figure;
% hold on;
% for i=1:m 
%     if re(i,4)==1   
%          plot3(re(i,1),re(i,2),re(i,3),'ro'); 
%     elseif re(i,4)==2
%          plot3(re(i,1),re(i,2),re(i,3),'go'); 
%     else 
%          plot3(re(i,1),re(i,2),re(i,3),'bo'); 
%     end
% end
% grid on;

%% 导入测试数据聚类结果和评分矩阵并进行测试

% clear all
% load clusterResult.mat
% %分钟数据+五维数据（Close,High,Low,Open,Vol）
% begD = '2010-04-06';
% endD = '2011-07-07';
% %sql = ['select Close,Date,Time,Vol from if000_m1 where Date>''',begT,'''and Date < ''',endT,''';'];
% %bardata = getBarData(sql);
% testData = load('if000_m1');
% bardata = testData.bardata;
% %下面这部分截取可以提取出来
% begNum = datenum(begD); endNum = datenum(endD);
% %提取bardata
% Date = bardata(:,1);
% dbeg = find(Date>=begNum,1); %找到截取数据的起始下标
% dend = find(Date<=endNum); %结束下标
% dend = dend(end);
% bardata = bardata(dbeg:dend,:);
% Time = bardata(:,2);
% Close = bardata(:,6);
% [normClose,ps] = mapminmax(Close'); %标准化
% 
% testBegD = '2011-04-07';
% testEndD = '2011-05-07';
% %下面这部分截取可以提取出来
% testBegNum = datenum(testBegD); testEndNum = datenum(testEndD);
% dbeg = find(Date>=testBegNum,1); %找到截取数据的起始下标
% dend = find(Date<=testEndNum); %结束下标
% dend = dend(end);
% testData = bardata(dbeg:dend,:);
% Time = testData(:,2);
% normClose = normClose(dbeg:dend);
% 
% %提取上午和下午分别价格  0.3854   0.4785  0.5625  0.6347
% %%------！！！提取数据这里写死了，需要修改！！！----------%%
% begtime = find(hour(Time)==9 & minute(Time)==15);
% % begtime = find(hour(Time)==14 & minute(Time)==15);  %可能出现数据缺失问题
% midtime1 = find(hour(Time)==11 & minute(Time)==29);
% midtime2 = find(hour(Time)==13 & minute(Time)==00);
% endtime = find(hour(Time)==15 & minute(Time)==14);
% m = length(begtime);
% AMClose = zeros(m,midtime1(1)-begtime(1)+1);
% for i = 1:m
%     AMClose(i,1:midtime1(i)-begtime(i)+1) = normClose(begtime(i):midtime1(i));
%     lossnum(i) = length(find(AMClose(i,:)==0));             %处理数据缺失
% end
% 
% PMClose = zeros(m,endtime(1)-midtime2(1)+1);
% for i = 1:m
%     PMClose(i,1:endtime(i)-midtime2(i)+1) = normClose(midtime2(i):endtime(i));
%     lossnum(i) = length(find(PMClose(i,:)==0));             %处理数据缺失
% end
% 
% % compute the distance of the new series of the cluster meter
% % and drop the delete the invalid cluster
% [m,n] = size(rating); [m_am,n_am] = size(AMClose); [m_pm,n_pm] = size(PMClose);
% distance = inf; amCluster = zeros(m_am,1); 
% recommendDir = zeros(m_pm,1); % record the recommending series direction,up(1) or down(-1)
% UP = 1; DOWN = -1;
% 
% for testIndex=1:m_am
%     distance = inf;
%     for userIndex=1:m
%         if sum(isnan(rating(userIndex,:))) ~= n
%             disTmp = norm(AMClose(testIndex,:)-u_am(userIndex,:)); % the distance between the new serie and the cluster center
%             if distance > disTmp
%                 distance = disTmp;
%                 amCluster(testIndex) = userIndex; % record the belonging cluster of the new serie
%             end
%         end
%     end
% end
% 
% %%%%%---recommend the series and compute the recommending series' direction---%%%%%
% 
% % recommend the pm series according to the cluster of the am series
% [recommend_v,recommend_i] = max(rating(amCluster,:)');
% 
% % use the pm cluster center to determine the predicting serie's direction
% %%%%--------------------here can be improved-------------------------%%%%
% recommendDir = u_pm(recommend_i,end) - u_pm(recommend_i,1);
% recommendDir(recommendDir > 0) = UP;
% recommendDir(recommendDir < 0) = DOWN;
% 
% %%%%%---compare the recommend pm series with the real pm series---%%%%%
% %%%%%---use a vector to record the which is a wrong recommendation(0)---%%%%%
% %%%%%---which is right recommendation(1)---%%%%%
% 
% % the real pm series direction
% realDir = PMClose(:,end) - PMClose(:,1);
% realDir(realDir > 0) = UP;
% realDir(realDir < 0) = DOWN;
% 
% % compute the right hit of the recommendation
% hit = length(find(recommendDir == realDir)==1)/length(realDir);
% 
% % trade according to the recommendation
% % buy when it is up,sell when it is down
% [trade_m,trade_n] = size(recommendDir);
% profit = zeros(trade_m,1);
% reverseClose = mapminmax('reverse',PMClose,ps);
% for i=1:trade_m
%     if recommendDir(i) == UP
%         profit(i) = reverseClose(i,end) - reverseClose(i,1);
%     else
%         profit(i) = reverseClose(i,1) - reverseClose(i,end);
%     end
% end
% cumsumProfit = cumsum(profit);
% plot(cumsumProfit * 300);


%% 测试最新的归一化聚类
%   2015-06-24 01:13

clear all
trainBegD = '2014-01-06';
trainEndD = '2014-04-06';
K = 5;
fileName = [trainBegD,'To',trainEndD,'_',num2str(K),'cluster'];
load(fileName);

testBegD = '2014-04-07';
testEndD = '2014-05-07';
testData = extractDataByDate(bardata,totalDate,testBegD,testEndD);
time = testData(:,2);
testClose = testData(:,6);
%[ userSeries,itemSeries ] = getAMPMData(testClose,time);
preMinute = 15; rearMinute = 15;
[ userSeries,itemSeries ] = getbeforeAfterOpenSeries(testClose,time,preMinute,rearMinute);

% 归一化数据
normUserSeries = mapminmax(userSeries);
normItemSeries = mapminmax(itemSeries);

% compute the distance of the new series of the cluster meter
% and drop the delete the invalid cluster
[m,n] = size(rating); [m_user,n_user] = size(normUserSeries); [m_item,n_item] = size(normItemSeries);
distance = inf; userCluster = zeros(m_user,1); 
recommendDir = zeros(m_item,1); % record the recommending series direction,up(1) or down(-1)
UP = 1; DOWN = -1;

for testIndex=1:m_user
    distance = inf;
    for userIndex=1:m
        if sum(isnan(rating(userIndex,:))) ~= n
            disTmp = norm(normUserSeries(testIndex,:)-u_user(userIndex,:)); % the distance between the new serie and the cluster center
            if distance > disTmp
                distance = disTmp;
                userCluster(testIndex) = userIndex; % record the belonging cluster of the new serie
            end
        end
    end
end

%%%%%---recommend the series and compute the recommending series' direction---%%%%%

% recommend the pm series according to the cluster of the am series
[recommend_v,recommend_i] = max(rating(userCluster,:)');

% use the pm cluster center to determine the predicting serie's direction
%%%%--------------------here can be improved-------------------------%%%%
recommendDir = u_item(recommend_i,end) - u_item(recommend_i,1);
recommendDir(recommendDir > 0) = UP;
recommendDir(recommendDir < 0) = DOWN;

%%%%%---compare the recommend pm series with the real pm series---%%%%%
%%%%%---use a vector to record the which is a wrong recommendation(0)---%%%%%
%%%%%---which is right recommendation(1)---%%%%%

% the real pm series direction
realDir = normItemSeries(:,end) - normItemSeries(:,1);
realDir(realDir > 0) = UP;
realDir(realDir < 0) = DOWN;

% compute the right hit of the recommendation
hit = length(find(recommendDir == realDir)==1)/length(realDir);

% trade according to the recommendation
% buy when it is up,sell when it is down
[trade_m,trade_n] = size(recommendDir);
profit = zeros(trade_m,1); 

% trade without using a threshold to control the loss
for i=1:trade_m
    if recommendDir(i) == UP
        profit(i) = itemSeries(i,end) - itemSeries(i,1);
    else
        profit(i) = itemSeries(i,1) - itemSeries(i,end);
    end
end
cumsumProfit = cumsum(profit);
figure;
plot(cumsumProfit * 300);
title(['无止损累积收益图，预测准确率为',num2str(hit)]);

% trade with using a threshold to control the loss
stopLossRet = -0.001; [test_m,test_n] = size(itemSeries);
for i=1:trade_m
    entryPrice = itemSeries(i,1);
    if recommendDir(i) == UP
        for j=1:test_n
            tmpProfitRet = itemSeries(i,j)/entryPrice - 1;
            if tmpProfitRet < stopLossRet
                profit(i) = itemSeries(i,j) - entryPrice;
                break ;
            end
        end
    else
        for j=1:test_n
            tmpProfitRet = 1 - itemSeries(i,j)/entryPrice;
            if tmpProfitRet < stopLossRet
                profit(i) = entryPrice - itemSeries(i,j);
                break ;
            end
        end
    end
end
cumsumProfit = cumsum(profit);
figure;
plot(cumsumProfit * 300);
title(['止损累积收益图，预测准确率为',num2str(hit)]);
