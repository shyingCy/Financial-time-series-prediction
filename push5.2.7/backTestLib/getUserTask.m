function [ Task_Config ] = getUserTask()
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here

seperator = filesep; %获取当前系统的文件分隔符
%% 测试策略的任务列表读入
filename = ['Config',seperator,'strategy_taskTable.txt'];
[fid,message] = fopen(filename,'r');
if fid==-1
    error(message);
end

%设置换行格式
line_Format = '\n';

%读入策略数量
fscanf(fid,'Strategy Number:');
strategyNumber = fscanf(fid,['%d',line_Format]);

fscanf(fid,['Strategy:',line_Format]);

%存放要运行的策略
strategy = cell(strategyNumber,1);
%读入要运行的策略
for i=1:strategyNumber
    temp = '%d';
    temp = fscanf(fid,temp);
    temp = ['.','%s',line_Format];
    temp = fscanf(fid,temp);
    strategy(i) = {temp};
end

fscanf(fid,['Please choose the strategy to run:']);
strategyNum = fscanf(fid,['%d%*c',line_Format]);

fclose(fid);

%% 测试读入每个策略任务的详细信息
taskNum = 1;
for strNum = 1:length(strategyNum)
    fileDir = ['Config',seperator,strategy{strategyNum(strNum)},'_Config'];
    a = what(fileDir); %搜出fileDir所在绝对路径，若set Path系统中存在两个，则选择第一个
    if isempty(a)
        errorMsg = ['strategy ',strategy{strategyNum(strNum)},'''s config directory not exists!'];
        error(errorMsg);
    end
    if length(a) > 1
        warning('There are more than one Push vision in your computer');
    end
    fileDir = a.path;
    files = dir(fileDir);   %获得文件夹下所有文件夹
    files = struct2cell(files);
    files = files';
    filesnum = size(files,1); %文件夹数量
    trueFilesnum = filesnum - 2; %去掉父级文件夹和本文件夹的文件夹数量
    filesname = cell(filesnum-2,1);
    
    for i = 3:1:filesnum
        filesname(i-2) = {files{i,1}};
    end
    %对每个Config文件夹下的文件读入每个任务的配置
    for  index = 1:1:(trueFilesnum)
        filename = fullfile(fileDir,filesname{index},'taskDetail.txt');
        [ strategy_Config,user_Config ] = loadTaskDetail( filename );
        Task_Config(taskNum) = getTaskConfig(strategy_Config,user_Config,filesname{index});
        taskNum = taskNum + 1;
    end
end


end

