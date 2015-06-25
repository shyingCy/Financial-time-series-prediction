function [ pro ] = getTestPro(strategy )
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here

exp = [strategy,'_1'];
pro = evalin('base',exp);

end

