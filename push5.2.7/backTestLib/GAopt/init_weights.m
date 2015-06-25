function subp=init_weights(popsize, niche, objDim)
% init_weights function initialize a pupulation of subproblems structure
% with the generated decomposition weight and the neighbourhood
% relationship.
subp=[];

%         if objDim==2
%             p=struct('weight',[],'neighbour',[],'optimal', Inf, 'optpoint',[], 'curpoint', []);
%             weight=zeros(2,1);
%             weight(1)=i/popsize;
%             weight(2)=(popsize-i)/popsize;
%             p.weight=weight;
%             subp=[subp p];
%         elseif
%
%             p=struct('weight',[],'neighbour',[],'optimal', Inf, 'optpoint',[], 'curpoint', []);
%             weight=zeros(2,1);
%             weight(1)=i/popsize;
%             weight(2)=(popsize-i)/popsize;
%             p.weight=weight;
%             subp=[subp p];
%
%
%
%         end;
%     end
start_obj_index = objDim;
coordinate = zeros(objDim,1);
lambda = [];
temppop = 0;
H = 0;
while(temppop<popsize)
    temppop = nchoosek(objDim+H-1,objDim-1);
    H = H+1;
end
H = H+1;
max_value_left = H;
lambda = gen_uniformweight(start_obj_index, max_value_left, coordinate, H, lambda,objDim);
lambda = lambda';
sizeLambda = size(lambda,1);

for i = 2:1:(sizeLambda+1)
    if (mod((i-1),objDim) == 0 )
        weight=zeros(objDim,1);
        for j = objDim:-1:1
            weight(j) = lambda(i-j);
        end
        p.weight=weight;
        subp=[subp p];
    end
end

m = length(subp);
idx = ceil(m*rand(1,popsize));
subp = subp(idx);
% weight = lhsdesign(popsize, objDim, 'criterion','maximin', 'iterations', 1000)';
% p=struct('weight',[],'neighbour',[],'optimal', Inf, 'optpoint',[], 'curpoint', []);
% subp = repmat(p, popsize, 1);
% cells = num2cell(weight);
% [subp.weight]=cells{:};

%Set up the neighbourhood.
leng=length(subp);
distanceMatrix=zeros(leng, leng);
for i=1:leng
    for j=i+1:leng
        A=subp(i).weight;B=subp(j).weight;
        distanceMatrix(i,j)=(A-B)'*(A-B);
        distanceMatrix(j,i)=distanceMatrix(i,j);
    end
    [s,sindex]=sort(distanceMatrix(i,:));
    subp(i).neighbour=sindex(1:niche)';
end

end