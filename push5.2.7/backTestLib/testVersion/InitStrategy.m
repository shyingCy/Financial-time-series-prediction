function [ output_args ] = InitStrategy(strategy,table_Name)
%UNTITLED8 Summary of this function goes here
%   Detailed explanation goes here
%调用策略的时候初始化函数，用于report能从base工作空间知道当前运行的是什么策略以及对应的数据库表
%strategy是策略名，必须是字符串，talbe_Name是表名，必须是字符串

%先清空base工作空间
evalin('base', 'clear');
assignin('base','My_strategy',strategy);
assignin('base','My_table_Name',table_Name);

end

