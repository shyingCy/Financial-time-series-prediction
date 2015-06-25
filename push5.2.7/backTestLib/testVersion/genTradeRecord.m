function [tradeRecord,isExitLeft] = genTradeRecord(entryRecord,exitRecord)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

%此函数生成交易记录,遗传算法接口的下单记录
%isExitLeft记录是否有未平掉的仓，0没有，1有，用于后面处理

%sprintf('\n%s\n','generating trade record...');

entrylots = entryRecord(:,5);
exitlots = exitRecord(:,5);

entryLength = size(entryRecord,1);
exitLength = size(exitRecord,1);
recLength = max(entryLength,exitLength);

tradeRecord = [];    %存放交易记录,改进：行数可以初始化为最长的那个，列数是确定的
isExitLeft = 0;

entrypos = 1;   %记录开仓被处理的位置
exitpos = 1;    %记录平仓被处理的位置
i = 1;

while i <= recLength
    if entrypos > entryLength
%         disp('index out of entry record''s length');
%         disp('Please check the trade record is right or not');
        break ;
    end
    if exitpos > exitLength
%         disp('index out of entry record''s length');
%         disp('Please check the trade record whether is there are entry records which haven''t been exited');
        leftNum = entryLength - entrypos; %算出剩下的开仓记录有多少
        exitRecClom = size(exitRecord,2); %求平仓记录列数
        tradeRecord(i:i+leftNum,:) = [entryRecord(entrypos:end,1:end-1),zeros(leftNum+1,exitRecClom-2),entryRecord(entrypos:end,end)];
        isExitLeft = 1;
        break ;
    end
    if entrylots(entrypos)==exitlots(exitpos)
        tradeRecord(i,:) = [entryRecord(entrypos,1:end-1),exitRecord(exitpos,2:end)]; %改进：可以改为[tradeRecord;temp]
        %openExitLength = openExitLength + 1;
        %openExitRecord(openExitLength,:) = [entryRecord(entrypos,1),entryRecord(entrypos,2)+entryRecord(entrypos,3),entryRecord(entrypos,4)];
        entrypos = entrypos+1;
        exitpos = exitpos+1;
    elseif entrylots(entrypos) > exitlots(exitpos)
        tradeRecord(i,:) = [entryRecord(entrypos,1:end-1),exitRecord(exitpos,2:end)];
        entrylots(entrypos) = entrylots(entrypos)-exitlots(exitpos);
        exitpos = exitpos+1;
    elseif entrylots(entrypos) < exitlots(exitpos)
        for j=entrypos:length(entryRecord(:,1))
            if sum(entrylots(entrypos:j)) == exitlots(exitpos)
                tradeRecord(i,:) = [entryRecord(j,1:end-1),exitRecord(exitpos,2:end-1),entryRecord(j,end)];
                entrypos = j+1;
                exitpos = exitpos+1;
                break;
            elseif sum(entrylots(entrypos:j)) > exitlots(exitpos)
                leftlots = sum(entrylots(entrypos:j)) - exitlots(exitpos);   %剩余没平的仓
                entrypos = j;
                entrylots(entrypos) = leftlots; %记录剩余未平的仓
                tradeRecord(i,:) = [entryRecord(j,1:end-1),exitRecord(exitpos,2:end-1),entryRecord(j,end)-leftlots];
                exitpos = exitpos + 1;
                break;
            end
            tradeRecord(i,:) = [entryRecord(j,1:end-1),exitRecord(exitpos,2:end-1),entryRecord(j,end)];
            i = i+1;
        end
    end
    i = i+1;
end
% sprintf('\n%s\n','ending generating trade record...\n');

end

