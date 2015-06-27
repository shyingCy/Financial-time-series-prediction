function [ entryRecord,exitRecord,obj,hit ] = recommend( trainData,testData,K1,K2,stopLossRet,MinPoint,pro_information,isMoveOn,isTrain )
%   author: shying 2016-06-26 01:42
%   recommend Summary of this function goes here
%   Detailed explanation goes here
%   author shying 2015-06-23
%   this function is to test the recommender algorithm
%   using k-means and it is writed for the recommend_push

%调用买卖函数需要的变量
entryRecord = []; %开仓记录
exitRecord = []; %平仓记录
my_currentcontracts = 0;  %持仓手数
lots = 1; ConOpenTimes = 0;
preciseV = 2e-7; %精度变量，控制两值相等的精度问题

%% pre process the data

trainTime = trainData(:,2);
trainClose = trainData(:,6);
%[ trainUserSeries,trainItemSeries ] = getAMPMData(trainClose,time);
preMinute = 15; rearMinute = 15;
[ trainUserSeries,trainItemSeries ] = getbeforeAfterOpenSeries(trainClose,trainTime,preMinute,rearMinute);

trainNormUserSeries = mapminmax(trainUserSeries);
trainNormItemSeries = mapminmax(trainItemSeries);

%% train data and compute the rating matrix

%k-means聚类
[u_user re_user]=KMeans(trainNormUserSeries,K1);  %最后产生带标号的数据，标号在所有数据的最后，意思就是数据再加一维度
[m_user n_user]=size(u_user);

[u_item re_item]=KMeans(trainNormItemSeries,K2);  %最后产生带标号的数据，标号在所有数据的最后，意思就是数据再加一维度
[m_item n_item]=size(u_item);

% find every cluster and rating according to
% the PMClose's number in which cluster
rating = zeros(K1,K2);
for i=1:K1
    KUserClusterIndex = (re_user(:,end)==i); % find the logical index of everyone in cluster i
    a = re_item(KUserClusterIndex,end);
    for j=1:K2
        rating(i,j) = length(find(a==j))/length(a);
    end
end

%% test the data

testDate = testData(:,1); testTime = testData(:,2); testClose = testData(:,6);
testHigh = testData(:,4); testLow = testData(:,5);
%[ testUserSeries,testItemSeries ] = getAMPMData(testClose,time);
preMinute = 15; rearMinute = 15;
[ testUserSeries,testItemSeries ] = getbeforeAfterOpenSeries(testClose,testTime,preMinute,rearMinute);
[ ~,testItemTimeSeries ] = getbeforeAfterOpenSeries(testTime,testTime,preMinute,rearMinute);
[ ~,testItemDateSeries ] = getbeforeAfterOpenSeries(testDate,testTime,preMinute,rearMinute);
[ ~,testItemHighSeries ] = getbeforeAfterOpenSeries(testHigh,testTime,preMinute,rearMinute);
[ ~,testItemLowSeries ] = getbeforeAfterOpenSeries(testLow,testTime,preMinute,rearMinute);

% 归一化数据
testNormUserSeries = mapminmax(testUserSeries);
testNormItemSeries = mapminmax(testItemSeries);

% compute the distance of the new series of the cluster meter
% and drop the delete the invalid cluster
[m,n] = size(rating); [m_user,n_user] = size(testNormUserSeries); [m_item,n_item] = size(testNormItemSeries);
distance = inf; testUserSeriesCluster = zeros(m_user,1); 
recommendDir = zeros(m_item,1); % record the recommending series direction,up(1) or down(-1)
UP = 1; DOWN = -1;

for testIndex=1:m_user
    distance = inf;
    for userIndex=1:m
        if sum(isnan(rating(userIndex,:))) ~= n
            disTmp = norm(testNormUserSeries(testIndex,:)-u_user(userIndex,:)); % the distance between the new serie and the cluster center
            if distance > disTmp
                distance = disTmp;
                testUserSeriesCluster(testIndex) = userIndex; % record the belonging cluster of the new serie
            end
        end
    end
end

%%%%%---recommend the series and compute the recommending series' direction---%%%%%

% recommend the pm series according to the cluster of the am series
[~,recommend_i] = max(rating(testUserSeriesCluster,:)');

% use the pm cluster center to determine the predicting serie's direction
%%%%--------------------here can be improved-------------------------%%%%
recommendDir = u_item(recommend_i,end) - u_item(recommend_i,1);
recommendDir(recommendDir > 0) = UP;
recommendDir(recommendDir < 0) = DOWN;

%%%%%---compare the recommend pm series with the real pm series---%%%%%
%%%%%---use a vector to record the which is a wrong recommendation(0)---%%%%%
%%%%%---which is right recommendation(1)---%%%%%

% the real pm series direction
realDir = testNormItemSeries(:,end) - testNormItemSeries(:,1);
realDir(realDir > 0) = UP;
realDir(realDir < 0) = DOWN;

% compute the right hit of the recommendation
hit = length(find(recommendDir == realDir)==1)/length(realDir);

% trade according to the recommendation
% buy when it is up,sell when it is down
[trade_m,~] = size(recommendDir);

% trade with using a threshold to control the loss
[~,test_n] = size(testItemSeries);
for i=1:trade_m
    entryPrice = testItemSeries(i,1);
    if recommendDir(i) == UP
        [entryRecord,exitRecord,my_currentcontracts,isSucess] = train_buy(entryRecord,exitRecord,my_currentcontracts,...
            testItemDateSeries(i,j),testItemTimeSeries(i,j),entryPrice,lots,ConOpenTimes);
        for j=1:test_n
            if testItemLowSeries(i,j) < (entryPrice - stopLossRet*MinPoint) || abs(testItemLowSeries(i,j) - (entryPrice - stopLossRet*MinPoint)) < preciseV
                exitPrice = entryPrice - stopLossRet*MinPoint;
                break ;
            end
            % 没有达到止损就用最后的收盘价成交
            exitPrice = testItemSeries(i,j);
        end
        [exitRecord,my_currentcontracts] = train_sell(exitRecord,my_currentcontracts,...
            testItemDateSeries(i,j),testItemTimeSeries(i,j),exitPrice,1);
    else
        [entryRecord,exitRecord,my_currentcontracts,isSucess] = train_sellshort(entryRecord,exitRecord,my_currentcontracts,...
            testItemDateSeries(i,j),testItemTimeSeries(i,j),entryPrice,lots,ConOpenTimes);
        for j=1:test_n
            if testItemHighSeries(i,j) > (entryPrice + stopLossRet*MinPoint) || abs(testItemHighSeries(i,j) - (entryPrice + stopLossRet*MinPoint)) < preciseV
                exitPrice = entryPrice + stopLossRet*MinPoint;
                break ;
            end
            % 没有达到止损就用最后的收盘价成交
            exitPrice = testItemSeries(i,j);
        end
        [exitRecord,my_currentcontracts] = train_buyToCover(exitRecord,my_currentcontracts,...
            testItemDateSeries(i,j),testItemTimeSeries(i,j),exitPrice,1);
    end
end

[obj,entryRecord,exitRecord] = train_reportVar(testData,entryRecord,exitRecord,0,pro_information,isMoveOn,isTrain);


end

