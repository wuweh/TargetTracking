function [ TrueTrace ] = GeneratellTrace( d, v ,InitPoint1, Angle ,Tracenum, N ,num, T)
%生成平行航迹
%Example:
%   [ TrueTrace ] = GeneratellTrace( 500, 100 ,[3000 3000], 10 ,5)
%InitPoint1 一条航迹的起始点
% d 俩直线距离
% v 总速度
% Angle 与X轴方向夹角 角度
%可选输入：
%Tracenum 平行航迹数
% N 拍数 50
% num 航迹编号[1 2]
% T 每拍时间 1

if nargin < 8
    T=1;
end

if nargin < 6
    N = 50;
end
if nargin < 5
    Tracenum = 2;
end
if nargin < 7
    num=1:Tracenum;
end
vx = v .* cosd(Angle);
vy = v .* sind(Angle);
x1 = InitPoint1(1);
y1 = InitPoint1(2);
if length(InitPoint1)>2
    z1 = InitPoint1(3);
else
    z1 = 0;
end
temp = [x1 vx 0 y1 vy 0 z1 0 0];

state = repmat(temp,Tracenum,1);
state(:,4) = state(:,4)-(0:(Tracenum-1))'*d;

TrueTrace  = GenerateTrace( state', 0, T, N, [], num );
hold on
for i =1: length(TrueTrace)
 plot(TrueTrace{i}.Data(1,:),TrueTrace{i}.Data(4,:));
end

