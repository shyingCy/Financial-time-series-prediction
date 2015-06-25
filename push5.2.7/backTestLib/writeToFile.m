function [ output_args ] = writeToFile(dir,openExitRecord,DynamicEquity,test_obj,dir_flag)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

[m1,n1] = size(openExitRecord);
[m2,n2] = size(DynamicEquity);

seperator = filesep; %ÎÄ¼þ·Ö¸ô·û

filename1 = [dir,seperator,dir_flag,'_EntryExitReocrd.txt'];
filename2 = [dir,seperator,dir_flag,'_DynamicEquityList.txt'];
filename3 = [dir,seperator,dir_flag,'_testObj.txt'];

fid = fopen(filename1,'w');
for i=1:m1
    %dlmwrite(filenmae,data(:,i));
    fprintf(fid,'%s%s%s%s%f%s%f%s%d%s%f%s%f\n',openExitRecord{i,:});
end

fclose(fid);

fid = fopen(filename2,'w');
for i=1:m2
    %dlmwrite(filenmae,data(:,i));
    fprintf(fid,'%s%s%f%s%d\n',DynamicEquity{i,:});
end

fclose(fid);

for i=1:length(test_obj)
    dlmwrite(filename3,test_obj(i),'-append');
end

end

