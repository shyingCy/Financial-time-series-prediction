function [ output_args ] = dataPre(strategy,pro,Freq)
%UNTITLED5 Summary of this function goes here
%   Detailed explanation goes here

proName = [strategy,'_1'];
if isExistInWork(proName)
    evalin('base',['clear ',proName,';']);
end
FreqName = [strategy,'_2'];
if isExistInWork(proName)
    evalin('base',['clear ',FreqName,';']);
end

assignin('base',proName,pro);
assignin('base',FreqName,Freq);

end

