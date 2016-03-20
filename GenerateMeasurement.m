function [Measure,Vol] = GenerateMeasurement( TrueTrace, ObserveTrace, RadarInfo, N)
%������ʵ������������
%out:
% Measure���ɵ�����Ԫ�����飬ÿ��ʱ��һ��Ԫ����ÿ������һ���ṹ��
% Measure{1}[1].Echo ����ֵ
% Measure{1}[1].Time ʱ���
% Measure{1}[1].radarno ���������
% Measure{1}[1].Property ESM���ԣ�Ԥ����
% Measure{1}[1].ID ��������������ָ���ã�

%in:
% N ����ʱ��
% TrueTrace ��ʵ��������
%TrueTrace.Time ����ʱ���
%TrueTrace.ID �����������
%TrueTrace.Data ����ֵ

% ObserveTrace �۲������꣬Ĭ��ԭ��
% RadarInfo ��������Ϣ
% RadarInfo.deta ��������������
% RadarInfo.ClutterD�Ӳ��ܶȣ�Ĭ��0
% RadarInfo.Pd�����ʣ�Ĭ��1
% RadarInfo.T �������Ĳ�������
% RadarInfo.Type ����������,100 GMTI 200 ESM
% RadarInfo.ID ���������

if nargin < 3
    RadarInfo.deta = [0;0;0;0];
    RadarInfo.ClutterD = 0;
    RadarInfo.Pd = 1;
    RadarInfo.T = 1;
    RadarInfo.Type = 100;
    RadarInfo.ID = 1;
end
if nargin < 4
    N = size(TrueTrace{1}.Data,2);%����ʱ��
    warning('�����������ܴ���');
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
M = length(TrueTrace);%��������
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
measuretemp(1) = sqrt(x^2 + y^2 + z^2)+deta(1)*randn();%�����
measuretemp(2) = atan(z/sqrt(x^2 + y^2))+deta(2)*randn();%������
measuretemp(3) = atan(y/x)+deta(3)*randn();%��λ��
measuretemp(4) = (x*xv+y*yv+z*zv)/sqrt(x^2+y^2+z^2)+deta(4)*randn();%����������
measuretemp = measuretemp';
end

