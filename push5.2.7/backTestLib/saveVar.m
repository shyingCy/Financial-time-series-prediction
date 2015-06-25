function [ output_args ] = saveVar( filename,varargin )
%UNTITLED12 Summary of this function goes here
%   Detailed explanation goes here
%This function is used to save the data that 
%produced by the train strategy
%2015.03.09

%保存第一个变量
exp = [inputname(2),'=','varargin{1};'];
eval(exp);
save(filename,inputname(2));

%保存接下来的所有变量
for i=2:length(varargin)
    exp = [inputname(i+1),'=','varargin','{',num2str(i),'};'];
    eval(exp);
    save(filename,inputname(i+1),'-append');
end

end

