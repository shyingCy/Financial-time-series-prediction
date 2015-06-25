function [ output_args ] = CatFX_push( input_args )
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
%2015/01/21

%-----------回测所需变量设置-------------%
%=============获取用户测试要求===========%
% [testPro_list,testFreq_list,begD,endD,isMinPointOn,...
%     ConOpenTimes,trainDay_Length,testDay_Length,opt_Way] = loadTestInfoConfig();
user_Config = loadTestInfoConfig();
testPro_list = user_Config.testPro_list;
testFreq_list = user_Config.testFreq_list;
begD = user_Config.begD;
endD = user_Config.endD;
isMoveOn = user_Config.isMoveOn;
ConOpenTimes = user_Config.ConOpenTimes;
trainDay_Length = user_Config.trainDay_Length;
testDay_Length = user_Config.testDay_Length;
istrainRandom = user_Config.istrainRandom;
random_down = user_Config.random_down;
random_up = user_Config.random_up;
isDB = user_Config.isDB;
opt_Way = user_Config.opt_Way;

%==========获取用户配置结束=============%
%======================================%

pro_L = length(testPro_list);
Freq_L = length(testFreq_list);
testTB_list = cell([pro_L,Freq_L]); %测试的表名字
test_data = cell([pro_L*Freq_L,1]); %存储每个品种每个周期下推进出来的对应的资金曲线，第一个元素是品种_周期，第三个元素是周期曲线

%-------若启用数据库，导入数据库配置----------%
if isDB==1
    [ODBCName,user,pwd,dbName] = loadDBConfig();
    %连接数据库
    conna = mysql('open','localhost',user,pwd);
    mysql(['use ',dbName]);
end
%------回测变量-------%
obj = {}; %存放训练的目标值
arg = 0; %存放训练时的每个参数组合
opt_ind_number = 4; %优化指标数量，用于记录过程中产生的临时最优指标
strategy_detail.trainDay_Length = trainDay_Length;
strategy_detail.testDay_Length = testDay_Length;
strategy_detail.begD = begD;
strategy_detail.endD = endD;

%----------策略参数，这一块需根据需要进行修改------------%
strategy = 'CatFX';
Period_Length = input('请输入Period的参数范围，格式为(1:1:3),1为的一个值，中间的1为步长，第三个值为终止值，请输入：\n');
Length_Length = input('请输入Length的参数范围，格式为(1:1:3),1为的一个值，中间的1为步长，第三个值为终止值，请输入：\n');

arg_number = 2; %参数数量

%测试次数计数
test_Times = 0;
%------------推进测试--------------%
for i=1:length(testPro_list)
    if isDB==1
        pinPrefix =  cell2mat(regexp(testPro_list{i},'[^\d]','match'));    %得到商品前缀用于获取商品信息
        sql = ['select * from pro_information where pinPrefix=''',pinPrefix,''';'];
        [pinPrefix,contractUnit,minimumPriceChange,limitUpDown,chargeRate,leverRatio] = mysql(sql);
        pro_information = [pinPrefix,contractUnit,minimumPriceChange,limitUpDown,chargeRate,leverRatio];
    else
        pinPrefix = cell2mat(regexp(testPro_list{i},'[^\d]','match'));
        pro_name = [pinPrefix,'_pro_info'];
        load(pro_name); %导入品种数据
    end
    tic
    for j=1:length(testFreq_list)
        evalin('base','clear'); %每个策略不同品种里的不同周期都必须清空工作空间
        testTB_list(i,j) = {[testPro_list{i},'_',testFreq_list{j}]};
        
        if isDB==1
            sql = ['select Date,Time,Open,High,Low,Close,Vol from ',testPro_list{i},'_','m1',' where date > ''',begD,'''and date < ''',endD,''';'];
            [Date,Time,Open,High,Low,Close,Vol] = mysql(sql);
            minuteData = [Date,Time,Open,High,Low,Close,Vol];
            sql = ['select Date,Time,Open,High,Low,Close,Vol from ',testTB_list{i,j},' where date > ''',begD,'''and date < ''',endD,''';'];
            [Date,Time,Open,High,Low,Close,Vol] = mysql(sql);
            bardata = [Date,Time,Open,High,Low,Close,Vol];
        else
            load(testTB_list{i,j}); %导入品种_周期数据
            Date = bardata(:,1);
            Close = bardata(:,6);
        end
        %======提取出训练数据下标和测试数据下标=====%
        %=========================================%
        temp = diff(day(Date));
        testDayBeg = find(temp~=0)+1;
        testDayBegLength = length(testDayBeg);
        %===========用训练数据得到最优参数=========%
        %========================================%
        for trainDay=trainDay_Length
            if length(testDayBeg) <= trainDay
                error('数据不够所设训练数据');
            end
            for testDay=testDay_Length
                times = 0; %记录每次推进的运行次数
                evalin('base','clear'); %每个不同的训练测试天数组合都必须清空工作空间
                fprintf('正在测试 %s\n',[testTB_list{i,j},'_',num2str(trainDay),'To',num2str(testDay)]);
                %---------创建保存文件所需文件夹--------%
                %创建存放变量的目录并把strategy_detail存放进去
                dir = [strategy,'_',testTB_list{i,j},'_',num2str(trainDay),'To',num2str(testDay),'_',num2str(istrainRandom),'_',num2str(random_down),'To',num2str(random_up)];
                if exist(dir,'dir')
                    rmdir(dir,'s');
                end
                mkdir(dir);
                %创建子文件夹保存参数及目标结果
                arg_object_dir = [dir,'\','arg_object'];
                mkdir(arg_object_dir);
                koffset = []; %记录随机偏移量
                %-------推进模块------%
                for k=trainDay+random_up:testDay:testDayBegLength  %以testDay为步长进行测试、
                    times = times+1;
                    koffset(end+1) = k; %记录随机偏移量
                    %根据是否起点随机来决定每次推进的训练样本
                    if istrainRandom == 1 %开启随机起点
                        offset = random_down + floor((random_up-random_down)*rand(1));
                    else
                        offset = 0;
                    end
                    if times == 1
                        trainBeg = 1;
                    else
                        trainBeg = testDayBeg(k - trainDay - offset);
                    end
                    trainEnd = testDayBeg(k - offset)-1; %不减1数据会取到最后一天的隔天第一根K，需减1
                    trainData = bardata(trainBeg:trainEnd,:);
                    %如果测试天数
                    if (k+testDay) > testDayBegLength 
                        if k == testDayBegLength %如果最后一个测试指针刚好是最后一个数，则跳出
                            break;
                        end
                        testBeg = testDayBeg(k);
                        testEnd = testDayBeg(end)-1;
                        testData = bardata(testBeg:testEnd,:);
                    else
                        testBeg = testDayBeg(k);
                        testEnd = testDayBeg(k+testDay)-1;
                        testData = bardata(testBeg:testEnd,:);
                    end
                    if size(testData,1) < 1
                        disp(1);
                    end
                    temp_P = zeros(1,opt_ind_number); %记录优化的指标
                    opt_temp = 0; %暂时存储最优解
                    temp_P_I = zeros(1,arg_number); %记录最大收益对应的参数
                    %-----初始化，这里需要根据需要进行修改---%
                    %-----根据自己策略的参数进行修改，格式如下-----%
                    arg.Period = [];
                    arg.Length = [];
                    %-----------------------------------------%
                    obj = {};
                    for Length=Length_Length
                        for Period=Period_Length
                            con = CatCon( strategy,bardata,pro_information,Period,Length );
                            con = con(trainBeg:trainEnd);
                            [profitRet,CumNetRetStd,maxDD,LotsWinTotalDLotsTotal,AvgWinLossRet,traderecord,Dy] = ...
                                train_CatFX(trainData,pro_information,con,ConOpenTimes,isMoveOn);
                            %判断最优解
                            %存储目标temp_P和对应的参数
                            obj{end+1} = {profitRet,CumNetRetStd,maxDD,LotsWinTotalDLotsTotal,AvgWinLossRet,traderecord,Dy};
                            %下面的参数需根据需求进行修改
                            arg.Length(end+1) = Length;
                            arg.Period(end+1) = Period;
                            %选择算法，以给出的不同标准选择出最优参数
                            if opt_temp==0 || obj{end}{opt_Way} > opt_temp
                                opt_temp = obj{end}{opt_Way};
                                temp_P_I(1:end) = [Length;Period]; %这里需根据参数进行修改
                            end
                        end
                    end
                    %-------------------------------%
                    %-------------------------------%
                    %---保存中间的参数以及目标变量----%
                    filename = [arg_object_dir,'\',strategy,'_',testTB_list{i,j},'_',num2str(trainDay),'To',num2str(testDay),...
                        '_',num2str(istrainRandom),'_',num2str(random_down),'To',num2str(random_up),'_',num2str(k)];
                    save(filename,'arg','obj','offset');
                    %==========用最优参数运行策略==========%
                    %==========这里需根据需要进行修改==========%
                    bestLength = temp_P_I(1); bestPeriod =  temp_P_I(2); 
                    fprintf('%s%d%s\n','正在测试第',times,'次');
                    fprintf('训练天数为%d，测试天数为%d，最优参数为：%f %f %f %f %f\n',trainDay,testDay,bestLength,bestPeriod);
                    tcon = CatCon( strategy,bardata,pro_information,Period,Length );
                    tcon = tcon(testBeg:testEnd);
                    CatFX(strategy,testData,pro_information,tcon,ConOpenTimes);
                end
                test_Times = test_Times + 1;
                strategy_detail.koffset = koffset;
                dir_flag = [strategy,'_',testTB_list{i,j},'_',num2str(trainDay),'_',num2str(testDay),'_',num2str(istrainRandom),'_',num2str(random_down),'_',num2str(random_up)];
                filename = [dir,'\',strategy,'_',testTB_list{i,j},'_',num2str(trainDay),'To',num2str(testDay),'_',num2str(istrainRandom),'_',num2str(random_down),'To',num2str(random_up)];
                save(filename,'strategy_detail');
                [mytraderecord,openExitRecord,DynamicEquity,obj] = reportVar(strategy,bardata,pro_information);
                writeToFile(dir,openExitRecord,DynamicEquity,obj,dir_flag);
                filename = [dir,'\',strategy,'_',testTB_list{i,j},'_',num2str(trainDay),'To',num2str(testDay),...
                    '_',num2str(istrainRandom),'_',num2str(random_down),'To',num2str(random_up)];
                save(filename,'mytraderecord','openExitRecord','DynamicEquity','obj','-append');
                filename = [dir,'\',strategy,'_',testTB_list{i,j},'_',num2str(trainDay),'To',num2str(testDay),...
                    '_',num2str(istrainRandom),'_',num2str(random_down),'To',num2str(random_up),'_','testTradeRecord'];
                %---保存base工作空间里面的交易记录以便校对----%
                evalin('base',['save ',filename]);
                evalin('base','clear'); %每个策略不同品种里的不同周期不同训练测试配比都必须清空工作空间
                fprintf('测试 %s 完毕\n',[testTB_list{i,j},'_',num2str(trainDay),'To',num2str(testDay)]);
            end
        end
    end
    toc
end

if isDB == 1
    mysql('close');
end

end

