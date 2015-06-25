function ind = gaussian_mutate( ind, prob, domain)
%GAUSSIAN_MUTATE Summary of this function goes here
%   Detailed explanation goes here

if isstruct(ind)
    x = ind.parameter;
else
    x  = ind;
end

   parDim = length(domain);
   for i =1:1:parDim
    gap = domain(i,1);
    gap = cell2mat(gap);
    lowend(i) = gap(1,1);
    highend(i) = gap(1,end);
   end

   highend = highend';
   lowend = lowend';
   
   sigma = (highend-lowend)./20;
   
   newparam = min(max(normrnd(x, sigma), lowend), highend);
   C = rand(parDim, 1)<prob;
   x(C) = newparam(C);
   
if isstruct(ind)
    ind.parameter = x;
else
    ind = x;
end
    