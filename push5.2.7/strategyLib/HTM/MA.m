function MAClose = MA( data,Cycle )
%UNTITLED Summary of this function goes here
%移动平均线
%   Detailed explanation goes here
%填充空数据,保持m不变
%  for i=1:Cycle-1
%  MAminuteClose(i)=0;
%  end
% for i=Cycle:m
Close = data(:,6);

m=length(data);
MAClose=Close;
for t=Cycle:m
 MAClose(t) = mean(Close(t-Cycle+1:t));
end
end

