function ind = randompoint(prob, n)
%RANDOMNEW to generate n new point randomly from the mop problem given.

if (nargin==1)
    n=1;
end

%变量个数
paranum = prob.pd;

randarray = rand(paranum, n);

for i =1:1:paranum
gap = prob.domain(i,1);
gap = cell2mat(gap);
lowend(i) = gap(1,1);
highend(i) = gap(1,end);
end

highend = highend';
lowend = lowend';
span =  highend - lowend;
point = randarray.*(span(:,ones(1, n)))+ lowend(:,ones(1,n));
cellpoints = num2cell(point, 1);

indiv = struct('parameter',[],'objective',[], 'estimation', []);
ind = repmat(indiv, 1, n);
[ind.parameter] = cellpoints{:};

% estimation = struct('obj', NaN ,'std', NaN);
% [ind.estimation] = deal(repmat(estimation, prob.od, 1));
end
