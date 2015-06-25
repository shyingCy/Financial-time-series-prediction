function [ newDiff ] = tran( curDate,tarDate,tarDiff )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

[C,curI,tarI] = intersect(curDate,tarDate);
totalSize = length(curDate);
curSize = length(curI);
tarSize = length(tarI);
newDiff = zeros(totalSize,1);

if curSize<tarSize  %小转大
    newDiff(1:curSize) = tarDiff(1:tarSize);
    if totalSize ~= curSize
        k = totalSize-curSize;
        a = ones(1,k);
        newDiff(curSize+1:curSize+k) = tarDiff(tarSize)*a;
    end
else     %大转小
    sum = 1;
    for i = 1:curSize
        if i==1 && curI(1)>1
            newDiff(sum:sum+curI(1)-2) = ones(1,curI(1)-1)*tarDiff(1);
            sum = sum+curI(1);
        elseif i==curSize
            newDiff(sum) = tarDiff(i);
        else
            k = curI(i+1)-curI(i);
            a = ones(1,k);
            newDiff(sum:sum+k-1) = a*tarDiff(i);
            sum = sum+k;
        end
    end
    if totalSize~=sum
        j=totalSize-sum;
        newDiff(sum+1:sum+j)=newDiff(sum)*ones(1,j);
    end
end



% k = curP/tarP;
% switch tarP
%     case 1
%         Diff = diffm1;
%     case 5
%         Diff = diffm5;
%     case 15
%         Diff = diffm15;
%     case 30
%         Diff = diffm30;
%     case 60
%         Diff = diffh1;
%     case 240
%         Diff = diffh4;
%     case 14400
%         Diff = diffd1;
% end
% j=1;      %目标周期序列的索引
% for i=1:curSize       %当前周期序列的索引
%     if(timeofDiff(j)==timeofcurDiff(i))     %如果当前周期时间等于目标周期序列，则取与目标周期相等时间点数据作新的Diff
%         newDiff(i)=Diff(j);
%         continue;
%     else
%         j=j+1;    %不相等时则目标周期索引向后移，继续判断
%     end
% end

end

        

