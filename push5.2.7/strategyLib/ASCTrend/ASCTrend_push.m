function [ output_args ] = ASCTrend_push( input_args )
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
%2015/01/21

%-----------�ز������������-------------%
%=============��ȡ�û�����Ҫ��===========%
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


%==========��ȡ�û����ý���=============%
%======================================%

pro_L = length(testPro_list);
Freq_L = length(testFreq_list);
testTB_list = cell([pro_L,Freq_L]); %���Եı�����
test_data = cell([pro_L*Freq_L,1]); %�洢ÿ��Ʒ��ÿ���������ƽ������Ķ�Ӧ���ʽ����ߣ���һ��Ԫ����Ʒ��_���ڣ�������Ԫ������������

%-------���������ݿ⣬�������ݿ�����----------%
if isDB==1
    [ODBCName,user,pwd,dbName] = loadDBConfig();
    %�������ݿ�
    conna = mysql('open','localhost',user,pwd);
    mysql(['use ',dbName]);
end
%------�ز����-------%
obj = {}; %���ѵ����Ŀ��ֵ
arg = 0; %���ѵ��ʱ��ÿ���������
opt_ind_number = 4; %�Ż�ָ�����������ڼ�¼�����в�������ʱ����ָ��
strategy_detail.trainDay_Length = trainDay_Length;
strategy_detail.testDay_Length = testDay_Length;
strategy_detail.begD = begD;
strategy_detail.endD = endD;

%----------���Բ�������һ���������Ҫ�����޸�------------%
strategy = 'ASCTrend';
risk_Length = input('������risk�Ĳ�����Χ����ʽΪ(1:1:3),1Ϊ��һ��ֵ���м��1Ϊ������������ֵΪ��ֵֹ�������룺\n');
TrailingStart_Length = input('������TrailingStart�Ĳ�����Χ����ʽΪ(1:1:3),1Ϊ��һ��ֵ���м��1Ϊ������������ֵΪ��ֵֹ�������룺\n');
TrailingStop_Length = input('������TrailingStop�Ĳ�����Χ����ʽΪ(1:1:3),1Ϊ��һ��ֵ���м��1Ϊ������������ֵΪ��ֵֹ�������룺\n');
StopLossSet_Length = input('������StopLossSet�Ĳ�����Χ����ʽΪ(1:1:3),1Ϊ��һ��ֵ���м��1Ϊ������������ֵΪ��ֵֹ�������룺\n');
arg_number = 4; %��������

%���Դ�������
test_Times = 0;
%------------�ƽ�����--------------%
for i=1:length(testPro_list)
    if isDB==1
        pinPrefix =  cell2mat(regexp(testPro_list{i},'[^\d]','match'));    %�õ���Ʒǰ׺���ڻ�ȡ��Ʒ��Ϣ
        sql = ['select * from pro_information where pinPrefix=''',pinPrefix,''';'];
        [pinPrefix,contractUnit,minimumPriceChange,limitUpDown,chargeRate,leverRatio]  = mysql(sql);
        pro_information = [pinPrefix,contractUnit,minimumPriceChange,limitUpDown,chargeRate,leverRatio];
    else
        pinPrefix = cell2mat(regexp(testPro_list{i},'[^\d]','match'));
        pro_name = [pinPrefix,'_pro_info'];
        load(pro_name); %����Ʒ������
    end
    tic
    for j=1:length(testFreq_list)
        evalin('base','clear'); %ÿ�����Բ�ͬƷ����Ĳ�ͬ���ڶ�������չ����ռ�
        testTB_list(i,j) = {[testPro_list{i},'_',testFreq_list{j}]};
        
        if isDB==1
            sql = ['select Date,Time,Open,High,Low,Close,Vol from ',testPro_list{i},'_','m1',' where date > ''',begD,'''and date < ''',endD,''';'];
            [Date,Time,Open,High,Low,Close,Vol] = mysql(sql);
            minuteData = [Date,Time,Open,High,Low,Close,Vol];
            sql = ['select Date,Time,Open,High,Low,Close,Vol from ',testTB_list{i,j},' where date > ''',begD,'''and date < ''',endD,''';'];
            [Date,Time,Open,High,Low,Close,Vol] = mysql(sql);
            bardata = [Date,Time,Open,High,Low,Close,Vol];
        else
            load(testTB_list{i,j}); %����Ʒ��_��������
            Date = bardata(:,1);
        end
        %======��ȡ��ѵ�������±�Ͳ��������±�=====%
        %=========================================%
        temp = diff(day(Date));
        testDayBeg = find(temp~=0)+1;
        testDayBegLength = length(testDayBeg);
        %===========��ѵ�����ݵõ����Ų���=========%
        %========================================%
        for trainDay=trainDay_Length
            if length(testDayBeg) <= trainDay
                error('���ݲ�������ѵ������');
            end
            for testDay=testDay_Length
                times = 0; %��¼ÿ���ƽ������д���
                evalin('base','clear'); %ÿ����ͬ��ѵ������������϶�������չ����ռ�
                fprintf('���ڲ��� %s\n',[testTB_list{i,j},'_',num2str(trainDay),'To',num2str(testDay)]);
                %---------���������ļ������ļ���--------%
                %������ű�����Ŀ¼����strategy_detail��Ž�ȥ
                dir = [strategy,'_',testTB_list{i,j},'_',num2str(trainDay),'To',num2str(testDay),'_',num2str(istrainRandom),'_',num2str(random_down),'To',num2str(random_up)];
                if exist(dir,'dir')
                    rmdir(dir,'s');
                end
                mkdir(dir);
                %�������ļ��б��������Ŀ����
                arg_object_dir = [dir,'\','arg_object'];
                mkdir(arg_object_dir);
                koffset = []; %��¼���ƫ����
                %-------�ƽ�ģ��------%
                for k=trainDay+random_up:testDay:testDayBegLength  %��testDayΪ�������в��ԡ�
                    times = times+1;
                    koffset(end+1) = k; %��¼���ƫ����
                    %�����Ƿ�������������ÿ���ƽ���ѵ������
                    if istrainRandom == 1 %����������
                        offset = random_down + floor((random_up-random_down)*rand(1));
                    else
                        offset = 0;
                    end
                    if times == 1
                        trainBeg = 1;
                    else
                        trainBeg = testDayBeg(k - trainDay - offset);
                    end
                    trainEnd = testDayBeg(k - offset)-1; %����1���ݻ�ȡ�����һ��ĸ����һ��K�����1
                    trainData = bardata(trainBeg:trainEnd,:);
                    %�����������
                    if (k+testDay) > testDayBegLength
                        if k == testDayBegLength %������һ������ָ��պ������һ������������
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
                    temp_P = zeros(1,opt_ind_number); %��¼�Ż���ָ��
                    opt_temp = 0; %��ʱ�洢���Ž�
                    temp_P_I = zeros(1,arg_number); %��¼��������Ӧ�Ĳ���
                    %-----��ʼ����������Ҫ������Ҫ�����޸�---%
                    %-----�����Լ����ԵĲ��������޸ģ���ʽ����-----%
                    arg.risk = [];
                    arg.TrailingStart = [];
                    arg.TrailingStop = [];
                    arg.StopLossSet = [];
                    %-----------------------------------------%
                    obj = {};
                    for risk=risk_Length
                        value10 = 3 + risk*2;
                        if trainBeg > value10
                            data = bardata(trainBeg-value10:trainEnd,:);
                            value2 = ASC(strategy,data,pro_information,risk);
                            value2 = value2(value10+1:value10+length(trainData));
                        else
                            data = trainData;
                            value2 = ASC(strategy,data,pro_information,risk);
                        end
                        for TrailingStart=TrailingStart_Length
                            for TrailingStop=TrailingStop_Length
                                for StopLossSet=StopLossSet_Length
                                    [profitRet,CumNetRetStd,maxDD,LotsWinTotalDLotsTotal,AvgWinLossRet,traderecord,Dy] = ...
                                        train_ASCTrend(trainData,pro_information,risk,TrailingStart,TrailingStop,StopLossSet,value2,ConOpenTimes,isMoveOn);
                                    %�ж����Ž�
                                    %�洢Ŀ��temp_P�Ͷ�Ӧ�Ĳ���
                                    obj{end+1} = {profitRet,CumNetRetStd,maxDD,LotsWinTotalDLotsTotal,AvgWinLossRet,traderecord,Dy};
                                    %����Ĳ����������������޸�
                                    arg.risk(end+1) = risk;
                                    arg.TrailingStart(end+1) = TrailingStart;
                                    arg.TrailingStop(end+1) = TrailingStop;
                                    arg.StopLossSet(end+1) = StopLossSet;
                                    %ѡ���㷨���Ը����Ĳ�ͬ��׼ѡ������Ų���
                                    if opt_temp==0 || obj{end}{opt_Way} > opt_temp
                                        opt_temp = obj{end}{opt_Way};
                                        temp_P_I(1:end) = [risk;TrailingStart;TrailingStop;StopLossSet]; %��������ݲ��������޸�
                                    end
                                end
                            end
                        end
                    end
                    
                    %-------------------------------%
                    %-------------------------------%
                    %---�����м�Ĳ����Լ�Ŀ�����----%
                    filename = [arg_object_dir,'\',strategy,'_',testTB_list{i,j},'_',num2str(trainDay),'To',num2str(testDay),...
                        '_',num2str(istrainRandom),'_',num2str(random_down),'To',num2str(random_up),'_',num2str(k)];
                    save(filename,'arg','obj','offset');
                    %==========�����Ų������в���==========%
                    %==========�����������Ҫ�����޸�==========%
                    bestrisk = temp_P_I(1); TrailingStart = temp_P_I(2); TrailingStop = temp_P_I(3); StopLossSet = temp_P_I(4);
                    fprintf('%s%d%s\n','���ڲ��Ե�',times,'��');
                    fprintf('ѵ������Ϊ%d����������Ϊ%d�����Ų���Ϊ: %f %f %f %f\n',trainDay,testDay,bestrisk,TrailingStart,TrailingStop,StopLossSet);
                    testvalue10 = 3 + bestrisk*2;
                    if testBeg>testvalue10
                        tdata = bardata(testBeg-testvalue10:testEnd,:);
                        value2 = ASC(strategy,tdata,pro_information,bestrisk);
                        value2 = value2(value10+1:value10+length(testData));
                    else
                        tdata = testData;
                        value2 = ASC(strategy,tdata,pro_information,bestrisk);
                    end
                    ASCTrend(strategy,testData,pro_information,bestrisk,TrailingStart,TrailingStop,StopLossSet,value2,ConOpenTimes);
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
                %---����base�����ռ�����Ľ��׼�¼�Ա�У��----%
                evalin('base',['save ',filename]);
                evalin('base','clear'); %ÿ�����Բ�ͬƷ����Ĳ�ͬ���ڲ�ͬѵ��������ȶ�������չ����ռ�
                fprintf('���� %s ���\n',[testTB_list{i,j},'_',num2str(trainDay),'To',num2str(testDay)]);
            end
        end
    end
    toc
end

if isDB == 1
    mysql('close');
end

end
