function [ TrueTrace ] = GenerateXTrace( Angle, CrossPoint ,v , N ,num, T)
%生成俩条交叉航迹
%Example:
%   GenerateXTrace( [5 -5], [5000 5000] ,[100 100])
% CrossPoint 交叉点
% v 总速度[v1,v2]
% Angle 与X轴方向夹角[a1,a2] 角度
%可选输入：
% N 拍数 50
% num 航迹编号[1 2]
% T 每拍时间 1
if length(CrossPoint)==2;
    CrossPoint(3) = 0;
end
CrossPointt.x = CrossPoint(1);
CrossPointt.y = CrossPoint(2);
CrossPointt.z = CrossPoint(3);
if nargin < 6
    T=1;
end
if nargin < 5
    num=[1 2];
end
if nargin < 4
    N = 50;
end
vx = v .* cosd(Angle);
vy = v .* sind(Angle);
NH = ceil(N/2);
x1 = CrossPointt.x - NH * vx(1);
y1 = CrossPointt.y - NH * vy(1);
x2 = CrossPointt.x - NH * vx(2);
y2 = CrossPointt.y - NH * vy(2);
TrueTrace  = GenerateTrace( [x1 vx(1) 0 y1 vy(1) 0 CrossPointt.z 0 0;x2 vx(2) 0 y2 vy(2) 0 CrossPointt.z 0 0]', 0, T, N, [], num );
hold on
 plot(TrueTrace{2}.Data(1,:),TrueTrace{2}.Data(4,:));
 plot(TrueTrace{1}.Data(1,:),TrueTrace{1}.Data(4,:));
end

