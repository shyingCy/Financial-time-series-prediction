function [ Freq ] = getTestFreq(strategy )
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here

exp = [strategy,'_2'];
Freq = evalin('base',exp);

end

