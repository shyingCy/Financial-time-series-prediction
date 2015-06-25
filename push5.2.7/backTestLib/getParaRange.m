function [ paraRangeDeatil ] = getParaRange( arg,obj )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

arg_obj = [arg,obj];
arg_Num = 4;
range = 20;
iniRange = range;
add_range = 0;
temp = abs(diff(arg));
temp(temp==0) = Inf;
sort_step = sort(temp);
argStep = sort_step(1,:);
sort_arg_obj = sortrows(arg_obj,-(arg_Num+1));  %降序排列 ，按照收益率
while true
    range = iniRange + add_range;
    if range > 100
        error('Out of range!');
    end
    add_range = add_range + 1; %范围扩展
    range = floor(length(sort_arg_obj)*range*0.01);
    min_Range = min(sort_arg_obj(1:range,1:arg_Num));
    max_Range = max(sort_arg_obj(1:range,1:arg_Num));
    difMaxMin = max_Range - min_Range;
    isRational = find((difMaxMin - argStep)==0);
    if isempty(isRational) == 1 %如果全不为0
        fprintf('initial range is %f,final range is %f\n',iniRange,iniRange+add_range);
        break;
    end
end

paraRangeDeatil.min_Range = min_Range;
paraRangeDeatil.max_Range = max_Range;
paraRangeDeatil.iniRange = iniRange;
paraRangeDeatil.range = range;
paraRangeDeatil.add_range = add_range;
paraRangeDeatil.argStep = argStep;

end

