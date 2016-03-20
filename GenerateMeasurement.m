function [Measure,Vol] = GenerateMeasurement( TrueTrace, ObserveTrace, RadarInfo, N)
%根据真实航迹生产量测
%out:
% Measure生成的量测元胞数组，每个时刻一个元胞，每个量测一个结构体
% Measure{1}[1].Echo 量测值
% Measure{1}[1].Time 时间戳
% Measure{1}[1].radarno 传感器编号
% Measure{1}[1].Property ESM属性（预留）
% Measure{1}[1].ID 所属航迹（计算指标用）

%in:
% N 采样时常
% TrueTrace 真实航迹数据
%TrueTrace.Time 数据时间戳
%TrueTrace.ID 所属航迹编号
%TrueTrace.Data 数据值

% ObserveTrace 观察者坐标，默认原点
% RadarInfo 传感器信息
% RadarInfo.deta 传感器量测噪声
% RadarInfo.ClutterD杂波密度，默认0
% RadarInfo.Pd检测概率，默认1
% RadarInfo.T 传感器的采样周期
% RadarInfo.Type 传感器类型,100 GMTI 200 ESM
% RadarInfo.ID 传感器编号

if nargin < 3
    RadarInfo.deta = [0;0;0;0];
    RadarInfo.ClutterD = 0;
    RadarInfo.Pd = 1;
    RadarInfo.T = 1;
    RadarInfo.Type = 100;
    RadarInfo.ID = 1;
end
if nargin < 4
    N = size(TrueTrace{1}.Data,2);%采样时常
    warning('采样拍数可能错误');
end
if nargin < 2
    ObserveTrace.Data = zeros(9,N);
end

xmin=min(TrueTrace{1}.Data(1,:)); xmax=max(TrueTrace{1}.Data(1,:));
ymin=min(TrueTrace{1}.Data(4,:)); ymax=max(TrueTrace{1}.Data(4,:));
zmin=min(TrueTrace{1}.Data(7,:)); zmax=max(TrueTrace{1}.Data(7,:));

Width  = xmax-xmin;
Length = ymax-ymin;
Hight = zmax-zmin;
Vol=Width*Length;
M = length(TrueTrace);%航迹条数
curentno = ones(1,N);
for i = 1:M
    time = min(size(TrueTrace{i}.Data,2),N);
    for j =1:floor(time/RadarInfo.T)
        target = TrueTrace{i}.Data(1:3:7,1+(j-1)*RadarInfo.T);
        velocity = TrueTrace{i}.Data(2:3:8,1+(j-1)*RadarInfo.T);
        if rand() < RadarInfo.Pd
            Measuretemp = getmeasure(target, velocity, ObserveTrace.Data(1:3:7,1+(j-1)*RadarInfo.T), RadarInfo.deta);
%             hold on
%             plot(Measuretemp(1)*cos(Measuretemp(2))*cos(Measuretemp(3)),Measuretemp(1)*cos(Measuretemp(2))*sin(Measuretemp(3)),'o')
            Measure{j}(curentno(j)).Echo = Measuretemp;
            Measure{j}(curentno(j)).Time = TrueTrace{i}.Time(1+(j-1)*RadarInfo.T);
            Measure{j}(curentno(j)).RadarNo = RadarInfo.ID+RadarInfo.Type;
            %  Measure{j}(curentno(j)).Property
            Measure{j}(curentno(j)).ID = i;
            curentno(j) = curentno(j)+1;
        end
    end
end
for j = 1:RadarInfo.T:N
    ClutterN=poissrnd(RadarInfo.ClutterD*Vol/1e6);
    for i=1:ClutterN
        z=[xmin,ymin,zmin]'+rand(3,1).*[Width,Length,Hight]';
        z(4) = 0;
        z = getmeasure(z, [0,0,0],ObserveTrace.Data(1:3:7,j),RadarInfo.deta);
        Measure{j}(curentno(j)).Echo = z;
        Measure{j}(curentno(j)).Time = TrueTrace{1}.Time(j);
        Measure{j}(curentno(j)).RadarNo = RadarInfo.ID+RadarInfo.Type;
        %  Measure{j}(curentno(j)).Property
        Measure{j}(curentno(j)).ID = 0;
        curentno(j) = curentno(j)+1;
    end
end

end
function [measuretemp] = getmeasure(Target, velocity, Observer, deta)
target = Target(1:3);
abscoo = target - Observer;
x = abscoo(1);y = abscoo(2);z = abscoo(3);
xv = velocity(1);yv = velocity(2);zv = velocity(3);
measuretemp(1) = sqrt(x^2 + y^2 + z^2)+deta(1)*randn();%径向距
measuretemp(2) = atan(z/sqrt(x^2 + y^2))+deta(2)*randn();%俯仰角
measuretemp(3) = atan(y/x)+deta(3)*randn();%方位角
measuretemp(4) = (x*xv+y*yv+z*zv)/sqrt(x^2+y^2+z^2)+deta(4)*randn();%多普勒速率
measuretemp = measuretemp';
end

