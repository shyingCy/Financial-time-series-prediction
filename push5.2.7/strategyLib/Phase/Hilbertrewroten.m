function z = Hilbertrewroten(M,x)
%UNTITLED Summary of this function goes here
%M为希尔伯特变换的窗口长度
%x为原信号
%此版本为整段数据处理
%   Detailed explanation goes here
%12.15 基本正确 函数编写
m=length(x);
for n=1:M
    y(n)=0;
end
for n=M+1:m-M
    y(n)=0;
for r=1:2*M+1
    if (r==M+1)
        u=0;
    else
        u=(1-(-1)^(r-M-1))/(pi*(r-M-1));
    end
    y(n)=y(n)+u*x(n-M-1+r);
end
end
%统一成Z变量
for n=1:m-2*M %总数m,减去前后m个数据
    z(n)=x(M+n)+y(M+n)*i;
end
end

