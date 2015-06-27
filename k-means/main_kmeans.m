function [ output_args ] = main_kmeans(  )
%   author: shying 2016-06-24 00:12
%   main_kmeans Summary of this function goes here
%   Detailed explanation goes here
%   author shying 2015-06-23
%   this function is to test the recommender algorithm
%   using k-means

%% get the data

testData = load('if000_m1');
bardata = testData.bardata;
totalDate = bardata(:,1);
totalTime = bardata(:,2);

%% preprocess data

trainBegD = '2014-01-06';
trainEndD = '2014-04-06';
trainData = extractDataByDate(bardata,totalDate,trainBegD,trainEndD);
time = trainData(:,2);
trainClose = trainData(:,6);
%[ trainUserSeries,trainItemSeries ] = getAMPMData(trainClose,time);
preMinute = 15; rearMinute = 15;
[ trainUserSeries,trainItemSeries ] = getbeforeAfterOpenSeries(trainClose,time,preMinute,rearMinute);

trainNormUserSeries = mapminmax(trainUserSeries);
trainNormItemSeries = mapminmax(trainItemSeries);

%% train data and compute the rating matrix

%k-means聚类
K1 = 5; %set the categories numbers of am close series
K2 = 5; %set the categories numbers of pm close series
[u_user re_user]=KMeans(trainNormUserSeries,K1);  %最后产生带标号的数据，标号在所有数据的最后，意思就是数据再加一维度
[m_user n_user]=size(u_user);

[u_item re_item]=KMeans(trainNormItemSeries,K2);  %最后产生带标号的数据，标号在所有数据的最后，意思就是数据再加一维度
[m_item n_item]=size(u_item);

%display the final cluster center result
figure;
title('上午各聚类中心');
for i=1:m_user
    hold on
    plot(u_user(i,:));
end

figure;
title('下午各聚类中心');
for i=1:m_user
    hold on
    plot(u_item(i,:));
end

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

save([trainBegD,'To',trainEndD,'_',num2str(K1),'cluster']);

%% test the data

testBegD = '2014-04-07';
testEndD = '2014-05-07';
testData = extractDataByDate(bardata,totalDate,testBegD,testEndD);
time = testData(:,2);
testClose = testData(:,6);
%[ testUserSeries,testItemSeries ] = getAMPMData(testClose,time);
preMinute = 15; rearMinute = 15;
[ testUserSeries,testItemSeries ] = getbeforeAfterOpenSeries(testClose,time,preMinute,rearMinute);

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
[recommend_v,recommend_i] = max(rating(testUserSeriesCluster,:)');

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
[trade_m,trade_n] = size(recommendDir);
profit = zeros(trade_m,1); 

% trade without using a threshold to control the loss
for i=1:trade_m
    if recommendDir(i) == UP
        profit(i) = testItemSeries(i,end) - testItemSeries(i,1);
    else
        profit(i) = testItemSeries(i,1) - testItemSeries(i,end);
    end
end
cumsumProfit = cumsum(profit);
figure;
plot(cumsumProfit * 300);
title(['无止损累积收益图，预测准确率为',num2str(hit)]);

% trade with using a threshold to control the loss
stopLossRet = -0.005; [test_m,test_n] = size(testItemSeries);
for i=1:trade_m
    entryPrice = testItemSeries(i,1);
    if recommendDir(i) == UP
        for j=1:test_n
            tmpProfitRet = testItemSeries(i,j)/entryPrice - 1;
            if tmpProfitRet < stopLossRet
                profit(i) = testItemSeries(i,j) - entryPrice;
                break ;
            end
        end
    else
        for j=1:test_n
            tmpProfitRet = 1 - testItemSeries(i,j)/entryPrice;
            if tmpProfitRet < stopLossRet
                profit(i) = entryPrice - testItemSeries(i,j);
                break ;
            end
        end
    end
end
cumsumProfit = cumsum(profit);
figure;
plot(cumsumProfit * 300);
title(['止损累积收益图，预测准确率为',num2str(hit)]);

end