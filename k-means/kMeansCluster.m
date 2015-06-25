function y=kMeansCluster(m,k,isRand)
%%%%%%%%%%%%%%%%
%                                                        
% kMeansCluster - Simple k means clustering algorithm                                                              
% Author: Kardi Teknomo, Ph.D.                                                                  
%                                                                                                                    
% Purpose: classify the objects in data matrix based on the attributes    
% Criteria: minimize Euclidean distance between centroids and object points                    
% For more explanation of the algorithm, see http://people.revoledu.com/kardi/tutorial/kMean/index.html    % Output: matrix data plus an additional column represent the group of each object
%                                                                                                                
% Example: m = [ 1 1; 2 1; 4 3; 5 4]  or in a nice form                         
%          m = [ 1 1;                                                                                     
%                2 1;                                                                                         
%                4 3;                                                                                         
%                5 4]                                                                                         
%          k = 2                                                                                             
% kMeansCluster(m,k) produces m = [ 1 1 1;                                        
%                                   2 1 1;                                                                   
%                                   4 3 2;                                                                   
%                                   5 4 2]                                                                   
% Input:
%   m      - required, matrix data: objects in rows and attributes in columns                                                 
%   k      - optional, number of groups (default = 1)
%   isRand - optional, if using random initialization isRand=1, otherwise input any number (default)
%            it will assign the first k data as initial centroids
%
% Local Variables
%   f      - row number of data that belong to group i
%   c      - centroid coordinate size (1:k, 1:maxCol)
%   g      - current iteration group matrix size (1:maxRow)
%   i      - scalar iterator 
%   maxCol - scalar number of rows in the data matrix m = number of attributes
%   maxRow - scalar number of columns in the data matrix m = number of objects
%   temp   - previous iteration group matrix size (1:maxRow)
%   z      - minimum value (not needed)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if nargin<3,        isRand=0;   end
if nargin<2,        k=1;        end
    
[maxRow, maxCol]=size(m)
if maxRow<=k, 
    y=[m, 1:maxRow]
else
	
	% initial value of centroid
    if isRand,
        p = randperm(size(m,1));      % random initialization
        for i=1:k
            c(i,:)=m(p(i),:)  
    	end
    else
        for i=1:k
           c(i,:)=m(i,:)        % sequential initialization
    	end
    end
    
	temp=zeros(maxRow,1);   % initialize as zero vector
    
	while 1,
        d=DistMatrix(m,c);  % calculate objcets-centroid distances
        [z,g]=min(d,[],2);  % find group matrix g
        if g==temp,
            break;          % stop the iteration
        else
            temp=g;         % copy group matrix to temporary variable
        end
        for i=1:k
            f=find(g==i);
            if f            % only compute centroid if f is not empty
                c(i,:)=mean(m(find(g==i),:),1);
            end
        end
	end
    
	y=[m,g];
    
end