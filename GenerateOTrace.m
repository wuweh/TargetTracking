function [ TrueTrace ] = GenerateOTrace( d, v ,NearPoint1, Angle ,a, N ,num, T)
%生成平行航迹
%Example:
%   [ TrueTrace ] = GenerateOTrace( 50, 100 ,[3000 3000], 90 )
%NearPoint1 一条航迹的圆弧最近点
% d 俩直线距离，可为负，即交叉
% v 总速度
% Angle 圆弧转过的角度 角度
% a 转弯过载 m/s^2
%可选输入：
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
    a = 10;
end
if nargin < 7
    num=1:2;
end
w = a/v;%角速度
R =v^2/a;%半径
N2 = floor(Angle/180*pi/w);

x1 = NearPoint1(1);
y1 = NearPoint1(2);
if length(NearPoint1)>2
    z1 = NearPoint1(3);
else
    z1 = 0;
end
x1temp = x1-R*(1-cosd(Angle/2));
y1temp = y1+R*sind(Angle);
x2temp = x1+d+R*(1-cosd(Angle/2));
y2temp = y1+R*sind(Angle);
N1 =ceil((N-N2)/2);
v1x = v .* cosd(Angle/2-90);
v1y = v .* sind(Angle/2-90);
v2x = v .* cosd(-Angle/2-90);
v2y = v .* sind(-Angle/2-90);
x11 = x1temp-v1x*N1;
y11 = y1temp -v1y*N1;
x22 =x2temp -v2x*N1;
y22 =y2temp -v2y*N1;
state = [x11 v1x 0 y11 v1y 0 z1 0 0;x22 v2x 0 y22 v2y  0 z1 0 0]';
TrueTrace1 = GenerateTrace( state, 0, 1, N1, num);
TrueTrace2 = GenerateTrace( [TrueTrace1{1}.Data(:,N1),TrueTrace1{2}.Data(:,N1)], N1, 1, N2,[-w w], num,[0 0 0;0 0 0]',1);
TrueTrace3 = GenerateTrace( [TrueTrace2{1}.Data(:,N2),TrueTrace2{2}.Data(:,N2)], N1+N2, 1, 50-N2-N1, num);
TrueTrace{1}.Data =[TrueTrace1{1}.Data TrueTrace2{1}.Data TrueTrace3{1}.Data];
TrueTrace{1}.Time =[TrueTrace1{1}.Time TrueTrace2{1}.Time TrueTrace3{1}.Time];
TrueTrace{1}.ID =[TrueTrace1{1}.ID TrueTrace2{1}.ID TrueTrace3{1}.ID];

TrueTrace{2}.Data =[TrueTrace1{2}.Data TrueTrace2{2}.Data TrueTrace3{2}.Data];
TrueTrace{2}.Time =[TrueTrace1{2}.Time TrueTrace2{2}.Time TrueTrace3{2}.Time];
TrueTrace{2}.ID =[TrueTrace1{2}.ID TrueTrace2{2}.ID TrueTrace3{2}.ID];

hold on
for i =1: length(TrueTrace)
    plot(TrueTrace{i}.Data(1,:),TrueTrace{i}.Data(4,:));
end
axis equal
legend('1','2');
