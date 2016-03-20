function [ TrueTrace ] = GenerateTrace( StateInit, StartTime, T, N, Param, Num, ProcessNoise, Flag )
%根据给定输入生成一条航迹的真实数据
%out:
%TrueTrace真实数据结构体
    %TrueTrace.Time 数据时间戳
    %TrueTrace.ID 所属目标编号
    %TrueTrace.Data 数据值

%in:
%StateInit 初始状态前
%StartTime 起始前一时刻，0
%T数据周期
%N数据拍数
%Num航迹编号，从1开始
%Flag 运动状态标志，0 直线运动（默认） 1 协调转弯
%ProcessNoise 过程噪声
%%参数设置
if nargin  <  8
    Flag = 0;
end
[m, n] = size(StateInit);
if nargin <6
    Num = 1:n;
end
if nargin < 7
    ProcessNoise =zeros(3,n);
end
if nargin < 5
    Param =[];
end
switch Flag
%%直线运动
    case 0
        
        FCA = [ 1 T 0.5*T^2  0 0 0       0 0 0 
                0 1 T        0 0 0       0 0 0
                0 0 1        0 0 0       0 0 0
                0 0 0        1 T 0.5*T^2 0 0 0
                0 0 0        0 1 T       0 0 0
                0 0 0        0 0 1       0 0 0
                0 0 0        0 0 0       1 T 0.5*T^2
                0 0 0        0 0 0       0 1 T
                0 0 0        0 0 0       0 0 1];
        BCA = [(T^2)/2      0      0
                T           0      0
                1           0      0
                0          (T^2)/2 0
                0           T      0
                0           1      0
                0           0     (T^2)/2
                0           0      T 
                0           0      1];
        for jj=1:n
                temp.Data(:,1) = FCA*StateInit(:,jj) + BCA * ProcessNoise(:,jj);
                temp.Time(1) = StartTime+T;
                temp.ID(1) = Num(jj);
            for ii=2:N
                temp.Data(:,ii) = FCA*temp.Data(:,ii-1) + BCA * ProcessNoise(:,jj);
                temp.Time(ii) = StartTime+ii*T;
                temp.ID(ii) = Num(jj);
            end
            TrueTrace{jj} = temp;
        end
%%水平转弯
    case 1
        for jj=1:n
            w = Param(1, jj);
            FCT = [ 1 sin(w * T) / w 0        0 (cos(w * T) - 1) / w 0       0 0 0 
                    0 cos(w*T) 0        0 -sin(w * T) 0       0 0 0
                    0 0 0        0 0 0       0 0 0
                    0 (1 - cos(w * T)) / w  0        1 sin(w * T) / w 0       0 0 0
                    0 sin(w * T) 0        0 cos(w * T) 0       0 0 0
                    0 0 0        0 0 0       0 0 0
                    0 0 0        0 0 0       1 0 0
                    0 0 0        0 0 0       0 0 0
                    0 0 0        0 0 0       0 0 0];
            BCT = [ T^2/2 0 0;
                    T 0 0;
                    0 0 0;
                    0 T^2/2 0;
                    0 T 0
                    0 0 0 
                    0 0 0
                    0 0 0
                    0 0 0];

                    temp.Data(:,1) = FCT*StateInit(:,jj) + BCT * ProcessNoise(:,jj);
                    temp.Time(1) = StartTime+T;
                    temp.ID(1) = Num(jj);
            for ii=2:N
                temp.Data(:,ii) = FCT*temp.Data(:,ii-1) + BCT * ProcessNoise(:,jj);
                temp.Time(ii) = StartTime+ii*T;
                temp.ID(ii) = Num(jj);
            end
            TrueTrace{jj} = temp;
         end
    otherwise
end    
end

