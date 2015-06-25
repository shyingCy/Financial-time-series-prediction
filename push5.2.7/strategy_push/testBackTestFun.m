function [ output_args ] = testBackTestFun()
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
%2015.05.26

%% ��ʼ��
evalin('base','clear');
begD = '2010-04-16';
endD = '2015-02-01';

%-----------�ز������������?------------%
%=============��ȡ�û�����Ҫ��===========%
user_Config = loadTestInfoConfig();
isMoveOn = user_Config.isMoveOn;
ConOpenTimes = user_Config.ConOpenTimes;
testDay_Length = user_Config.testDay_Length;
optMethod = user_Config.opt_Way;

isRunnedAgain = 0;

%% ���»ز�


%% �г���ز��ļ����µ������ļ�?
fileDir = 'I:\panew';
files = dir(fileDir);   %����ļ����������ļ���?
files = struct2cell(files);
files = files';
filesnum = size(files,1);
filesname = cell(filesnum,1);  %ȥ�������쳣���ֵ��ļ���

for i = 3:1:filesnum
    filesname(i-2) = {files{i,1}};
end

%% ��ÿ���ļ����м�Ⲣ�Է�������ļ��н��лز�
for  index = 1:1:filesnum
    
    for optI = 1:1:length(optMethod)
        
        opt_Way = optMethod(optI);
        taskFile = filesname{index,1};
        if isempty(taskFile)
            continue;
        end
        taskFile = [fileDir,filesep,taskFile];
        %% ����ļ����ļ���?
        taskBackFileDir = [taskFile,'_Back','_',num2str(opt_Way)];
        if exist(taskBackFileDir,'dir') && isRunnedAgain == 1
            rmdir(taskBackFileDir,'s');
            mkdir(taskBackFileDir);
        elseif ~exist(taskBackFileDir,'dir')
            mkdir(taskBackFileDir);
        else
            continue;
        end
        files = dir(taskFile);   %����ļ���������txt�ĵ�
        files = struct2cell(files);
        files = files';
        trainFilesnum = size(files,1);
        trainFilesname = cell(trainFilesnum,1);  %ȥ�������쳣���ֵ��ļ���
        
        for i = 3:1:trainFilesnum
            trainFilesname(i-2) = {files{i,1}};
        end
        for trainIndex = 1:1:trainFilesnum
            
            trainFile = trainFilesname{trainIndex,1};
            if isempty(trainFile)
                continue;
            end
            tempfile1=strrep(trainFile,'_',' ');  %ȥ���»���
            S = regexp(tempfile1, '\s+', 'split');   %�ÿո�ָ��ÿ���ַ�
            if length(S) < 2
                continue;
            end
            %% �ж��ļ����Ƿ���������ļ�?1.����ѭ�������ڶ� 2.����ѭ�������ڲ��� 3.��ѭ�������ڶ� 4.��ѭ�������ڲ���
            datafile = [taskFile,filesep,trainFile,filesep,'train_detail'];
            isOK = 0;
            
            if exist([datafile,'.mat'],'file')== 2   %�Ƿ������Ϣ�ļ�?
                trainD = load (datafile);
                strategy_detail = trainD.strategy_detail;
                arg = strategy_detail.strategyArg;  %���ԵĲ������?
                isMoead = strategy_detail.isMoead; %�����Ƿ��Ƕ�Ŀ�����?
                standardBegNum = datenum(begD);
                dataBegNum = datenum(strategy_detail.begD);
                if dataBegNum >= standardBegNum %������ȷ
                    isOK = 1;
                else %���ڴ���
                    fprintf(fileID1,'%s\n',trainFile);
                end
            else %handle the old version data
                datafile = [taskFile,filesep,trainFile,filesep,'trainDetail'];
                if exist([datafile,'.mat'],'file')== 2
                    trainD = load (datafile);
                    strategy_detail = trainD.strategy_detail;
                    arg = strategy_detail.task.serialPara; %���ԵĲ������?
                    isMoead = 0;
                    standardBegNum = datenum(begD);
                    dataBegNum = datenum(strategy_detail.begD);
                    if dataBegNum >= standardBegNum  %������ȷ
                        isOK = 1;
                    else %���ڴ���
                        fprintf(fileID1,'%s\n',trainFile);
                    end
                end
            end
            
            %��������ת���������Ϊ����һ����ʽ���ȹ̶���һ����������������?
            %���ж��Ƿ����°汾��ݣ�����ת��?
            if isMoead == 0
                if size(arg,1) > 1 && arg(1,1) ~= arg(2,1)
                    n = length(strategy_detail.task.arg);
                    for i=1:n
                        tempArg(i) = strategy_detail.task.arg(n);
                        n = n - 1;
                    end
                    n = length(strategy_detail.task.arg);
                    [comp{1:n}] = ndgrid(tempArg{:});
                    para = cell2mat(cellfun(@(a)a(:),comp,'un',0));
                    
                    %%
                    n = size(para,2);
                    for i=1:n
                        arg(:,i) = para(:,n);
                        n = n - 1;
                    end
                end
            end
            
            
            %% �Է�ϵ��ļ��н������»ز�?
            if isOK == 1
                %% ����Ʒ����Ϣ
                pinPrefix = cell2mat(regexp(S{1,2},'[^\d]','match'));
                pro_name = [pinPrefix,'_pro_info'];
                temp = load(pro_name); %����Ʒ�����?
                pro_information = temp.pro_information;
                %% ��������
                pro = S{1,2};
                Freq = S{1,3};
                testTB = [pro,'_',Freq];
                temp = load(testTB);
                bardata = temp.bardata;
                minuteData = temp.minuteData;
                %======��ȡ���?======%
                %�����ⲿ�ֽ�ȡ������ȡ����
                begNum = datenum(begD); endNum = datenum(endD);
                %��ȡminuteData
                Date = minuteData(:,1);
                dbeg = find(Date>=begNum,1); %�ҵ���ȡ��ݵ���ʼ�±�?
                dend = find(Date<=endNum); %�����±�
                dend = dend(end);
                minuteData = minuteData(dbeg:dend,:);
                %��ȡbardata
                Date = bardata(:,1);
                dbeg = find(Date>=begNum,1); %�ҵ���ȡ��ݵ���ʼ�±�?
                dend = find(Date<=endNum); %�����±�
                dend = dend(end);
                bardata = bardata(dbeg:dend,:);
                %��ȡ������Ϣ
                Date = bardata(:,1); Time = bardata(:,2);
                Open = bardata(:,3); High = bardata(:,4);
                Low = bardata(:,5); Close = bardata(:,6);
                Vol = bardata(:,7);
                %=====��ȡ��ݽ���?=======%
                %======��ȡ��ѵ������±�Ͳ�������±�?====%
                %=========================================%
                if sum(Time) ~= 0 %����������Ϊ�����֮��?
                    temp = find(hour(Time)==9); %��˼����ȡ9��֮ǰ���Ϊǰһ�����
                    a=diff(temp);
                    b=find(a~=1)+1;
                    testDayBeg=temp(b(1:end-1));
                    testDayBegLength = length(testDayBeg);
                else %����������Ϊ�����֮�ϣ�������ݣ�����ݵȵ�?
                    temp = diff(day(Date));
                    testDayBeg = find(temp~=0)+1; %����+1����Ϊdiff�����ǰ��һλ������?,1,2.�����õ�0,1��������������Ҫ2���±�
                    testDayBegLength = length(testDayBeg);
                end
                
                strategy = S{1,1};
                trainDay = str2double(S{1,4}(1:strfind(S{1,4},'T')-1));
                stdtestDay = str2double(S{1,4}(strfind(S{1,4},'o')+1:end));
                istrainRandom = str2double(S{1,5});
                random_up = str2double(S{1,6}(strfind(S{1,6},'o')+1:end));
                
                %% �ж��Ƿ���ԭ����Ǻ�?
                %�����ʼ����ȷ����Լ���
                if istrainRandom == 1
                    k = trainDay+random_up;
                else
                    k = trainDay;
                    %�������������random_up��0
                    random_up = 0;
                end
                arg_dir = [taskFile,filesep,trainFile,filesep,trainFile,'_','arg_object'];
                arg_file = [arg_dir,filesep,trainFile,'_',num2str(k)];
                %�жϵ�һ��k�Ƿ���ڣ���������˵��������㲻һ�����?
                if exist([arg_file,'.mat'],'file') == 2 %�����һ���ܳ������
                    isRight = 1;
                else
                    continue;
                end
                %�Բ�ͬ�Ĳ������ڽ��в���
                if isRight == 1
                    for testDay = testDay_Length
                        isRight = 1;
                        %��ѵ���������ڲ����������?
                        if testDay > trainDay
                            isRight = 0;
                            break;
                        end
                        %��ԭ��ѵ��ʱ������������ڲ�������������?
                        %��Ϊ�����ڲ�������󣬻ᵼ�µ�ʱ��ѵ����ݲ���
                        if stdtestDay > testDay
                            isRight = 0;
                            break;
                        end
                        
                        %���k��ֵ
                        k_value = trainDay+random_up:testDay:testDayBegLength; %��testDayΪ�������в���
                        k_nums = 1:1:length(k_value);
                        koffset = zeros(length(k_value),1); %��¼���ƫ����?
                        
                        testEntryRec = cell(length(k_nums),1); %�洢���ԵĿ��ּ�¼
                        testExitRec = cell(length(k_nums),1); %�洢���Ե�ƽ�ּ�¼
                        
                        singleTaskName = [strategy,'_',pro,'_',Freq,'_',num2str(trainDay),'To',num2str(testDay),'_',S{5},'_',S{6},'_',S{7},'_',S{8},'_Back','_',num2str(opt_Way)];
                        fprintf('��ʼ���� %s\n',singleTaskName);
                        best_arg = [];
                        
                        for kNum = k_nums  %��testDayΪ�������в���
                            if kNum == 16
                                disp(16);
                            end
                            dataPre(strategy,pro,Freq);
                            k = k_value(kNum);
                            koffset(kNum) = k; %��¼���ƫ����?
                            fprintf('%s%d%s\n','���ڲ��Ե�',kNum,'��');
                            %�����������ʣ��������ôȡʣ�����������Ϊ�������?
                            if (k+testDay) > testDayBegLength
                                testBeg = testDayBeg(k);
                                testEnd = length(bardata);
                            else
                                testBeg = testDayBeg(k);
                                testEnd = testDayBeg(k+testDay)-1;
                            end
                            datestr(Date(testBeg))
                            datestr(Date(testEnd))
                            arg_dir = [taskFile,filesep,trainFile,filesep,trainFile,'_','arg_object'];
                            arg_file = [arg_dir,filesep,trainFile,'_',num2str(k)];
                            if exist([arg_file,'.mat'],'file') ~= 2
                                isRight = 0;
                                break;
                            end
                            %���ﵼ��ʱ����?��ʱ��������
                            try
                                trainDetail = load(arg_file);
                            catch
                                isRight = 0;
                                break;
                            end
                            
                            obj = trainDetail.obj;
                            %��k����testDayBegLength��ʱ�򲻽����ƽ�
                            if k ~= testDayBegLength
                                my_currentcontracts = 0;
                                %��ݲ�����ϺͶ�Ӧ��Ŀ����Ż�����õ����Ų���
                                if isMoead == 0
                                    tempbest_arg = getBest_arg(arg,obj,opt_Way);
                                else
                                    temp_arg = arg{kNum};
                                    tempbest_arg = getBest_arg(temp_arg,obj,opt_Way);
                                    %��Ϊpareto�⼯�洢�������������������������Ӧ����ȡ����?
                                    for argL = 1:length(strategy_detail.task.arg)-3
                                        tempbest_arg(argL) = strategy_detail.task.arg{argL}(floor(tempbest_arg(argL)));
                                    end
                                    
                                end
                                
                                best_arg(end+1,:) = tempbest_arg;
                                tempbest_arg = num2cell(tempbest_arg);
                                
                                %����Ϊѵ��
                                isTrain = 0;
                                %==========�����Ų������в���==========%
                                [test_entryRecord,test_exitRecord] = train_Strategy(strategy,bardata,pro_information,ConOpenTimes,isMoveOn,testBeg,testEnd,tempbest_arg,isTrain,my_currentcontracts);
                                %��ͬ��ĺ�������ּ�¼��ƽ�ּ�¼���ٷŵ�һ��cell���飬�Ȳ���������ٺϲ�����?
                                testEntryRec(kNum) = {test_entryRecord};
                                testExitRec(kNum) = {test_exitRecord};
                            end
                        end
                        if isRight == 1
                            %% ���ÿ���ز��ļ����ļ���?
                            singleTaskBackFileDir = [taskBackFileDir,filesep,singleTaskName];
                            if exist(singleTaskBackFileDir,'dir')
                                rmdir(singleTaskBackFileDir,'s');
                            end
                            mkdir(singleTaskBackFileDir);
                            %������Ų��������±�ԵƵ��?
                            %����Ƿ��Ƕ�Ŀ����ȡ������?
                            if isMoead == 1
                                ori_arg = strategy_detail.task.serialPara(:,1:end-3);
                            else
                                ori_arg = arg;
                            end
                            [ upperFreq,lowerFreq] = paraRange_Statistics(ori_arg,best_arg);
                            %% ������Բ���ı�����
                            test_entryRecord = cell2mat(testEntryRec);
                            test_exitRecord = cell2mat(testExitRec);
                            isTrain = 0;
                            [test_obj,~,~,mytraderecord,openExitRecord,DynamicEquity] = train_reportVar(bardata,test_entryRecord,test_exitRecord,0,pro_information,isMoveOn,isTrain);
                            writeToFile(singleTaskBackFileDir,openExitRecord,DynamicEquity,test_obj,singleTaskName);
                            filename = [singleTaskBackFileDir,filesep,singleTaskName];
                            save(filename,'mytraderecord','openExitRecord','DynamicEquity','test_obj','arg','best_arg','upperFreq','lowerFreq','strategy_detail');
                            filename = [singleTaskBackFileDir,filesep,singleTaskName,'_','testTradeRecord'];
                            %---����base�����ռ�����Ľ��׼�¼�Ա�У��?---%
                            save( filename,'test_entryRecord','test_exitRecord');
                            fprintf('���� %s ���\n',singleTaskName);
                        end
                    end
                end
            end
        end
    end
end
end

