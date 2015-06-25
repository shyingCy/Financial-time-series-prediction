function d=DistMatrix(A,B)
%%%%%%%%%%%%%%%%%%%%%%%%%
% DISTMATRIX return distance matrix between point A=[x1 y1] and B=[x2 y2]
% Author: Kardi Teknomo, Ph.D.
% see http://people.revoledu.com/kardi/
%
% Number of point in A and B are not necessarily the same.
% It can be use for distance-in-a-slice (Spacing) or distance-between-slice (Headway),
%
% A and B must contain two column,
% first column is the X coordinates
% second column is the Y coordinates
% The distance matrix are distance between points in A as row
% and points in B as column.
% example: Spacing= dist(A,A)
% Headway = dist(A,B), with hA ~= hB or hA=hB
% A=[1 2; 3 4; 5 6]; B=[4 5; 6 2; 1 5; 5 8]
% dist(A,B)= [ 4.24 5.00 3.00 7.21;
% 1.41 3.61 2.24 4.47;
% 1.41 4.12 4.12 2.00 ]
%%%%%%%%%%%%%%%%%%%%%%%%%%%
[hA,wA]=size(A);
[hB,wB]=size(B);
if hA==1& hB==1
d=sqrt(dot((A-B),(A-B)));
else
C=[ones(1,hB);zeros(1,hB)];
D=flipud(C);
E=[ones(1,hA);zeros(1,hA)];
F=flipud(E);
G=A*C;
H=A*D;
I=B*E;
J=B*F;
d=sqrt((G-I').^2+(H-J').^2);
end