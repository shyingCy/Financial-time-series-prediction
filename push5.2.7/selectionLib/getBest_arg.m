function best_arg = getBest_arg(arg,obj,opt_Way)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

%1.选择前n名并集，然后再选出夏普率最高的为最优
%2.选择前n名并集，然后再选出夏普率居中（n为奇数）的为最优

recCommonLength = [];

%取出放在obj中的每个目标
n = length(obj);
profitRet = obj(:,1);
CumNetRetStdOfTradeRecord = obj(:,2);
maxDDOfTradeRecord = obj(:,3);
maxDDRetOfTradeRecord = obj(:,4);
LotsWinTotalDLotsTotal = obj(:,5);
AvgWinLossRet = obj(:,6);

if opt_Way == 1
    [bestV,bestI] = max(profitRet);
elseif opt_Way == 2
    SharpOfTradeRecord = profitRet./CumNetRetStdOfTradeRecord; %交易记录产生的夏普率
    [bestV,bestI] = max(SharpOfTradeRecord);
elseif opt_Way == 3
    [bestV,bestI] = max(LotsWinTotalDLotsTotal);
elseif opt_Way == 4
    AvgWinLossRet = AvgWinLossRet * (-1);
    [bestV,bestI] = max(AvgWinLossRet);
elseif opt_Way == 5
    X = 22; Y = 22;
    %处理出我们需要的目标
    SharpOfTradeRecord = profitRet./CumNetRetStdOfTradeRecord; %交易记录产生的夏普率
    CumNetRetStdOfTradeRecord = CumNetRetStdOfTradeRecord * (-1);
    maxDDOfTradeRecord = maxDDOfTradeRecord * (-1); %交易记录产生的最大回撤
    maxDDRetOfTradeRecord = maxDDRetOfTradeRecord * (-1); %交易记录产生的最大回撤率
    AvgWinLossRet = AvgWinLossRet * (-1);
    
    %对每个目标均进行降序排序之后输出对应下标
    [profitRetV,profitRetI] = sort(profitRet,'descend');
    [CumNetRetStdOfTradeRecordV,CumNetRetStdOfTradeRecordI] = sort(CumNetRetStdOfTradeRecord,'descend');
    [SharpOfTradeRecordV,SharpOfTradeRecordI] = sort(SharpOfTradeRecord,'descend');
    [maxDDOfTradeRecordV,maxDDOfTradeRecordI] = sort(maxDDOfTradeRecord,'descend');
    [maxDDRetOfTradeRecordV,maxDDRetOfTradeRecordI] = sort(maxDDRetOfTradeRecord,'descend');
    [LotsWinTotalDLotsTotalV,LotsWinTotalDLotsTotalI] = sort(LotsWinTotalDLotsTotal,'descend');
    [AvgWinLossRetV,AvgWinLossRetI] = sort(AvgWinLossRet,'descend');
    
    %收益衡量，取收益率和胜率，平均收益除以平均亏损的前X%或者前X交集commonA
    %若交集大小不满足则不断改变N以满足条件
    iniX = X;
    varT = 0; %变化量
    varB = 1; %变化幅度
    commonMinSize = 1; %交集最小值
    while true
        %对前N%名排名下标进行并集运算
        X = iniX + varT;
        if X > 100
            error('No proper common!');
        end
        X = fix(length(obj)*X*0.01);
        varT = varT + varB;
        disp(['errorT:',num2str(varT)]);
        %取交集
        commonA = intersect(profitRetI(1:X),LotsWinTotalDLotsTotalI(1:X));
        commonA = intersect(commonA,AvgWinLossRetI(1:X));
        
        if length(commonA) > commonMinSize
            fprintf('initial X is %f,final X is %f\n',iniX,iniX+varT);
            break;
        end
        
    end
    
    %风险衡量，从收益衡量得到的集合commonA，再进行取标准差，最大回撤分别排序，然后取前Y%或者前Y交集commonB
    sec_CumNetRetStdOfTradeRecord = CumNetRetStdOfTradeRecord(commonA);
    sec_maxDDOfTradeRecord = maxDDOfTradeRecord(commonA);
    sec_maxDDRetOfTradeRecord = maxDDRetOfTradeRecord(commonA);
    [sec_CumNetRetStdOfTradeRecordV,sec_CumNetRetStdOfTradeRecordI] = sort(sec_CumNetRetStdOfTradeRecord,'descend');
    [sec_maxDDOfTradeRecordV,sec_maxDDOfTradeRecordI] = sort(sec_maxDDOfTradeRecord,'descend');
    [sec_maxDDRetOfTradeRecordV,sec_maxDDRetOfTradeRecordI] = sort(sec_maxDDRetOfTradeRecord,'descend');
    iniY = Y;
    varT = 0; %变化量
    varB = 1; %变化幅度
    commonMinSize = 1; %交集最小值
    %若交集大小不满足则不断改变Y以满足条件
    while true
        %对前N%名排名下标进行并集运算
        Y = iniY + varT;
        if Y > 100
            error('No proper common!');
        end
        Y = fix(length(commonA)*Y*0.01);
        varT = varT + varB;
        %取交集
        commonB = intersect(sec_CumNetRetStdOfTradeRecordI(1:Y),sec_maxDDOfTradeRecordI(1:Y));
        commonB = intersect(commonB,sec_maxDDRetOfTradeRecordI(1:Y));
        
        if length(commonB) > commonMinSize
            fprintf('initial Y is %f,final Y is %f\n',iniY,iniY+varT);
            break;
        end
    end
    
    %对交集commonB取夏普率最高的一个作为最优参数
    %取夏普率最优得出对应的参数
    [bestV,bestI] = max(SharpOfTradeRecord(commonA(commonB)));
    bestI = commonA(bestI); %最优参数对应的下标
    
elseif opt_Way == 6
    N = 33;
    %处理出我们需要的目标
    SharpOfTradeRecord = profitRet./CumNetRetStdOfTradeRecord; %交易记录产生的夏普率
    CumNetRetStdOfTradeRecord = CumNetRetStdOfTradeRecord * (-1);
    maxDDOfTradeRecord = maxDDOfTradeRecord * (-1); %交易记录产生的最大回撤
    maxDDRetOfTradeRecord = maxDDRetOfTradeRecord * (-1); %交易记录产生的最大回撤率
    AvgWinLossRet = AvgWinLossRet * (-1); %平均收益/平均亏损，因为亏损是负的，所以必须变为正
    
    %对每个目标均进行降序排序之后输出对应下标
    [profitRetV,profitRetI] = sort(profitRet,'descend');
    [CumNetRetStdOfTradeRecordV,CumNetRetStdOfTradeRecordI] = sort(CumNetRetStdOfTradeRecord,'descend');
    [SharpOfTradeRecordV,SharpOfTradeRecordI] = sort(SharpOfTradeRecord,'descend');
    [maxDDOfTradeRecordV,maxDDOfTradeRecordI] = sort(maxDDOfTradeRecord,'descend');
    [maxDDRetOfTradeRecordV,maxDDRetOfTradeRecordI] = sort(maxDDRetOfTradeRecord,'descend');
    [LotsWinTotalDLotsTotalV,LotsWinTotalDLotsTotalI] = sort(LotsWinTotalDLotsTotal,'descend');
    [AvgWinLossRetV,AvgWinLossRetI] = sort(AvgWinLossRet,'descend');
    
    iniN = N;
    varT = 0; %变化量
    varB = 1; %变化幅度
    commonMinSize = 1; %交集最小值
    %若交集大小不满足则不断改变N以满足条件
    while true
        %对前N%名排名下标进行并集运算
        N = iniN + varT;
        if N > 100
            error('No proper common!');
        end
        N = fix(length(obj)*N*0.01);
        varT = varT + varB;
        %取交集
        common = intersect(profitRetI(1:N),CumNetRetStdOfTradeRecordI(1:N));
        common = intersect(common,maxDDOfTradeRecordI(1:N));
        common = intersect(common,maxDDRetOfTradeRecordI(1:N));
        common = intersect(common,LotsWinTotalDLotsTotalI(1:N));
        common = intersect(common,AvgWinLossRetI(1:N));
        
        if length(common) > commonMinSize
            fprintf('initial Y is %f,final Y is %f\n',iniN,iniN+varT);
            break;
        end
    end
    
    %取夏普最优得出对应的参数
    [bestV,bestI] = max(SharpOfTradeRecord(common));
    bestI = common(bestI); %最优参数对应的下标

end

if iscell(arg)
    arg = cell2mat(arg);
end

best_arg = arg(bestI,:);

end

