function [ output_args ] = setRange_Strategy()

%%
%训练得出参数版本
%2015.03.25

%%

%-----------回测所需变量设置-------------%
%=============获取用户测试要求===========%
task = getUserTask();
for taskNum=1:length(task)
    singleTask = task(taskNum);
    taskName = singleTask.taskName;
    strategy = singleTask.strategyName;
    strategyArg = singleTask.arg; %策略的每个参数的范围
    arg = singleTask.serialPara; %策略的所有参数的遍历组合
    testPro_list = singleTask.testPro_list;
    testFreq_list = singleTask.testFreq_list;
    begD = singleTask.begD;
    endD = singleTask.endD;
    isMoveOn = singleTask.isMoveOn;
    ConOpenTimes = singleTask.ConOpenTimes;
    trainDay_Length = singleTask.trainDay_Length;
    testDay_Length = singleTask.testDay_Length;
    istrainRandom = singleTask.istrainRandom;
    random_down = singleTask.random_down;
    random_up = singleTask.random_up;
    isDB = singleTask.isDB;
    isProDupliTask = singleTask.isProDupliTask; %防重跑设置，0为开启防重跑，1为不开启
    
    seperator = filesep; %文件分隔符
    
    %==========获取用户配置结束=============%
    %======================================%
    
    pro_L = length(testPro_list);
    Freq_L = length(testFreq_list);
    testTB_list = cell([pro_L,Freq_L]); %测试的表名字
    
    %-------若启用数据库，导入数据库配置----------%
    if isDB==1
        [ODBCName,user,pwd,dbName] = loadDBConfig();
        %连接数据库
        conna = mysql('open','localhost',user,pwd);
        mysql(['use ',dbName]);
    end
    %------回测变量-------%
    
    strategy_detail.trainDay_Length = trainDay_Length;
    strategy_detail.testDay_Length = testDay_Length;
    strategy_detail.begD = begD;
    strategy_detail.endD = endD;
    strategy_detail.strategyArg = strategyArg;
    strategy_detail.task = singleTask;
    
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
                sql = ['select Date,Time,Open,High,Low,Close,Vol from ',testPro_list{i},'_','m1',' where date >= ''',begD,'''and date <= ''',endD,''';'];
                [Date,Time,Open,High,Low,Close,Vol] = mysql(sql);
                minuteData = [Date,Time,Open,High,Low,Close,Vol];
                sql = ['select Date,Time,Open,High,Low,Close,Vol from ',testTB_list{i,j},' where date >= ''',begD,'''and date <= ''',endD,''';'];
                [Date,Time,Open,High,Low,Close,Vol] = mysql(sql);
                bardata = [Date,Time,Open,High,Low,Close,Vol];
            else
                load(testTB_list{i,j}); %导入品种_周期数据
                %下面这部分截取可以提取出来
                begNum = datenum(begD); endNum = datenum(endD);
                %提取minuteData
                Date = minuteData(:,1);
                dbeg = find(Date>=begNum,1); %找到截取数据的起始下标
                dend = find(Date<=endNum); %结束下标
                dend = dend(end);
                minuteData = minuteData(dbeg:dend,:);
                %提取bardata
                Date = bardata(:,1);
                dbeg = find(Date>=begNum,1); %找到截取数据的起始下标
                dend = find(Date<=endNum); %结束下标
                dend = dend(end);
                bardata = bardata(dbeg:dend,:);
                %提取各种价格
                Date = bardata(:,1); Time = bardata(:,2);
                Open = bardata(:,3); High = bardata(:,4);
                Low = bardata(:,5); Close = bardata(:,6);
                Vol = bardata(:,7);
            end
            %======检查数据是否提取到=================%
            if isempty(minuteData) || isempty(bardata)
                error('Config error!the begining of test day or the ending of the test day not right!');
            end
            %======提取出训练数据下标和测试数据下标=====%
            %=========================================%
            if sum(Time) ~= 0 %如果数据周期为日数据之下
                temp = find(hour(Time)==9); %基本思想是取9点之前数据为前一天数据
                a=diff(temp);
                b=find(a~=1)+1;
                testDayBeg=temp(b(1:end-1));
                testDayBegLength = length(testDayBeg);
            else %如果数据周期为日数据之上，即日数据，周数据等等
                temp = diff(day(Date));
                testDayBeg = find(temp~=0)+1; %这里+1是因为diff函数会前移一位，比如1,1,2.作差会得到0,1，在这里我们是要2的下标
                testDayBegLength = length(testDayBeg);
            end
            
            %===========用训练数据得到最优参数=========%
            %========================================%
            for trainDay=trainDay_Length
                if length(testDayBeg) <= trainDay
                    error('数据不够所设训练数据');
                end
                for testDay=testDay_Length
                    evalin('base','clear'); %每个不同的训练测试天数组合都必须清空工作空间
                    %=========存储全局变量到base工作空间=======%
                    
                    %========================================%
                    
                    %---------创建保存文件所需文件夹--------%
                    %创建任务文件夹
                    task_dir = [taskName,'_File'];
                    %！！！关闭所有文件操作，以防访问正在被访问的文件夹
                    %若此处并行，则需注意
                    fclose('all');
                    %创建每一个训练文件夹
                    dir_flag = [strategy,'_',testTB_list{i,j},'_',num2str(trainDay),'To',num2str(testDay),...
                        '_',num2str(istrainRandom),'_',num2str(random_down),'To',num2str(random_up),'_',begD,'_','setRange'];
                    totalDir = [task_dir,seperator,dir_flag];
                    fprintf('正在测试 %s\n',totalDir);
                    %创建子文件夹保存参数及目标结果
                    arg_object_dir = [totalDir,seperator,dir_flag,'_','arg_object'];
                    k_value = trainDay+random_up:testDay:testDayBegLength; %以testDay为步长进行测试
                    k_nums = 1:1:length(k_value);
                    koffset = zeros(length(k_value),1); %记录随机偏移量
                    %% 文件夹创建
                    %检测此任务是否已经运行过
                    isRunned = (exist(totalDir,'dir') == 7);
                    %跑过且想重跑，则删除此任务文件夹重建文件夹
                    if isRunned == 1 && isProDupliTask == 0
                        rmdir(totalDir,'s');
                        mkdir(totalDir);
                    end
                    
                    %跑过且不想重跑，则跳过此任务
                    if isRunned == 1 && isProDupliTask == 1
                        fprintf('The task %s has been runned!Pass!\n',totalDir);
                        continue;
                    end
                    
                    %没跑过，则创建文件夹
                    if isRunned == 0;
                        mkdir(task_dir);
                        mkdir(totalDir);
                    end
                    %% 开始训练
                    %保存一次任务所保存的所有目标
                    pro = testPro_list{i};
                    Freq = testFreq_list{j};
                    evalin('base','clear');
                    %-------推进模块------%
                    dataPre(strategy,pro,Freq);
                    trainBeg = 1;
                    trainEnd = size(bardata,1);
                    isTrain = 1;
                    my_currentcontracts = 0;
                    %训练策略
                    [~,~,~,temp_obj] = train_Strategy(strategy,bardata,pro_information,ConOpenTimes,isMoveOn,trainBeg,trainEnd,strategyArg,isTrain,my_currentcontracts);
                    paraRangeDeatil = getParaRange(arg,temp_obj);
                    filename = [totalDir,seperator,'train_detail'];
                    saveVar(filename,strategy_detail,paraRangeDeatil);
                    fprintf('测试 %s 完毕\n',totalDir);
                end
            end
        end
        toc
    end
    
    if isDB == 1
        mysql('close');
    end
    
end

end

