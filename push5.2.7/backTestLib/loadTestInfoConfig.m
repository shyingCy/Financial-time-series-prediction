function user_Config = loadTestInfoConfig()
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
%testPro_list is test product table
%testFreq_list is test Frequency table
%begD is the test begin date，endD is the end date
%isMoveOn is slip point，isConOpen is max continous open times
%trainDay_Length is train days list,testDay_Length is test days list
%opt_Way is the optimization way


% p1 = mfilename('fullpath');
% i=findstr(p1,'\');
% p1=p1(1:i(end));
% cd(p1);

filename = 'Config/user_trade_info.txt';

[fid,message] = fopen(filename,'r');
if fid==-1
    error(message);
end

temp1 = [{'if000'};{'i9000'};{'j9000'};{'l9000'};{'M9000'};...
    {'rb000'};{'sr000'};{'ta000'};{'y9000'};{'p9000'};{'ru000'};...
    {'ag000'};{'au000'};{'cu000'};{'cf000'};{'jd000'};{'al000'};{'rm000'}];
temp2 = [{'m1'};{'m5'};{'m15'};{'m30'};{'h1'};{'h4'};{'d1'};{'w1'}];

%设置换行格式
line_Format = '\n';

fscanf(fid,['All products are as follow:',line_Format]);
for i = 1:length(temp1)
    pro = fscanf(fid,['pro%*d:%s',line_Format]);
end

fscanf(fid,['Please input the number of test pro,format as(the first pro1,if more than 1 to test,for example:2,5).testpro=']);
%读取用户选取的品种数量
pro_N = fscanf(fid,['%d%*c',line_Format]);

if isempty(pro_N)
    error('Somethings error in configuring!Please go to the Config floder to configure user_trade_info.txt');
end
fscanf(fid,['All frequency as follow:',line_Format]);
for i = 1:length(temp2)
    Freq = fscanf(fid,['freq%d:%s',line_Format]);
end

fscanf(fid,['input the test frequency(format as product):testfreq=']);
%读取用户选取的周期数量
Freq_N = fscanf(fid,['%d%*c']);

%读取用户选取的日期
fscanf(fid,['Please input the test begin date,format as 2012-01-01,test begin date=']);
begD = fscanf(fid,['%sPlease']);

fscanf(fid,[line_Format,'Please input the test end date,format as 2012-01-01,test end date=']);
endD = fscanf(fid,'%s是');
%endD = fscanf(fid,['请输入测试结束日期，必须为字符串，格式如(2012-01-01),测试结束日期=','%s',line_Format])    %数据所取起始日期

fscanf(fid,[line_Format,'slip point(1:open slip 2:close slip 3.no 4.two-sides slip):']);
isMoveOn = fscanf(fid,'%d');

fscanf(fid,[line_Format,'continuous open times(please input a number,0 stop continuous open):']);
ConOpenTimes = fscanf(fid,'%d');


fscanf(fid,'Please input train days,if only one type then input a number,if more,then input like a matlab array(22:44:66).Please input:');
trainD_Info = fscanf(fid,'%d%*c');
if length(trainD_Info) > 1
    trainDay_Length = trainD_Info(1):trainD_Info(2):trainD_Info(3);
else
    trainDay_Length = trainD_Info;
end


fscanf(fid,'Please input test days,if only one type then input a number,if more,then input like a matlab array(22:44:66).Please input:');
testD_Info = fscanf(fid,'%d%*c');
if length(testD_Info) > 1
    testDay_Length = testD_Info(1):testD_Info(2):testD_Info(3);
else
    testDay_Length = testD_Info;
end


%随机起点
fscanf(fid,'Please choose if open the random location(0 is shut down,1 is open):');
istrainRandom = fscanf(fid,'%d%*c');

fscanf(fid,'Please input the lower limit of the random range:');
random_down = fscanf(fid,'%d%*c');

fscanf(fid,'Please input the higher limit of the random range:');
random_up = fscanf(fid,'%d%*c');

%数据获取方式
fscanf(fid,'Please choose the way to get test data(0 is by mat file,1 is by mysql):');
isDB = fscanf(fid,'%d%*c');

%读取优化方法
fscanf(fid,['All optimical way as follow:',line_Format]);
fscanf(fid,['1.totalProfit',line_Format]);
fscanf(fid,['2.Sharp',line_Format]);
fscanf(fid,['3.WinRet',line_Format]);
fscanf(fid,['4.AverageProfit/AverageLoss',line_Format]);
fscanf(fid,['5.Using first X percentage of profit indicators to get a intersection A,then use the same method on risk indicators to get a intersection B,finally get the best one by sharp',line_Format]);
fscanf(fid,['6.Using first X percentage of all indicators to get a intersection A,get the best one by the best sharp',line_Format]);
fscanf(fid,['Please choose a way to optimize:',line_Format]);
opt_Way = fscanf(fid,['%d%*c']);

testPro_list = {};
count = 0;
for i =1:length(pro_N)
    count = count + 1;
    testPro_list(count) = temp1(pro_N(i));
end

testFreq_list = {};
count = 0;
for i =1:length(Freq_N)
    count = count + 1;
    testFreq_list(count) = temp2(Freq_N(i));
end

%处理随机起点问题
if istrainRandom==0
    random_down = 0; %随机下限
    random_up = 0; %随机上限
end

user_Config.testPro_list = testPro_list;
user_Config.testFreq_list = testFreq_list;
user_Config.begD = begD;
user_Config.endD = endD;
user_Config.isMoveOn = isMoveOn;
user_Config.ConOpenTimes = ConOpenTimes;
user_Config.trainDay_Length = trainDay_Length;
user_Config.testDay_Length = testDay_Length;
user_Config.istrainRandom = istrainRandom;
user_Config.random_down = random_down;
user_Config.random_up = random_up;
user_Config.isDB = isDB;
user_Config.opt_Way = opt_Way;

fclose(fid);

end