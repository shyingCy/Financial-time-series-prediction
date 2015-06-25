function result = isExistInWork(varname)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

%判断一个变量是否存在基本工作空间中，输入为一个变量名

all_var = evalin('base', 'who');

if ismember(varname,all_var)
    result = true;
else
    result = false;
end

end

