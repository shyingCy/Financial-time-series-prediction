function dist = Distance(A,B,Distance_mark)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
%A,B are  Matrixs,no matter the dimensions
%Attention: the dimensions of A and B must be the same except the dtw
%method
%here we commpute the distanece of one from A to one from B
%the result is a matrix that is the same rows as A and B and has only one
%columns
%Distance_mark is the distance's kind,now the methods includes 'euclid','dtw','L1',L2','Cos'.
%euclid is Euclidean,dtw is dynamic time wrapping,Cos is Cosine distance
%I will increase the methods as soon.

if nargin < 2
    error('Not enought arguments!');
elseif nargin < 3
    Distance_mark='L2';
end

[m1 n1] = size(A);
[m2, n2] = size(B);
if m1~=m2
    error('The rows of A and B must be the same!');
end

if ~strcmpi(Distance_mark,'dtw') && n1~=n2
    error('The method is not dynamic time wrapping,the columns of A and B must be the same!');
end

% Normalize each feature
% If you need the following two rows,you can uncomment them.
%A = mapminmax(A);
%B= mapminmax(B);

dist = zeros(m1,1);
switch Distance_mark
    case {'euclid', 'L2'}
        for i=1:m1
            dist(i,1) = VectorDis(A(i,:),B(i,:),Distance_mark); % Euclead (L2) distance
        end
    case 'L1'
        for i=1:m1
            dist(i,1) = VectorDis(A(i,:),B(i,:),Distance_mark); % Euclead (L2) distance
        end
    case 'Cos'
        for i=1:m1
            dist(i,1) = VectorDis(A(i,:),B(i,:),Distance_mark); % Euclead (L2) distance
        end
    otherwise
        for i=1:m1
            dist(i,1) = VectorDis(A(i,:),B(i,:),'L2'); % Euclead (L2) distance
        end
end

%子函数计算单个向量间距离
    function d = VectorDis(A,B,Distance_mark)
        V = A-B;
        switch Distance_mark
            case {'euclid', 'L2'}
                d=norm(V,2); % Euclead (L2) distance
            case 'L1'
                d=norm(V,1); % L1 distance
            case 'Cos'
                d=acos(A*B'/(norm(A,2)*norm(B,2)));     % cos distance
            otherwise
                d=norm(V,2); % Default distance
        end
    end
end

