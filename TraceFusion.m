%%初始化参数
%ESM参数
ESMInfo.deta = [5;0.1*pi/180;0.1*pi/180;5];
ESMInfo.ClutterD = 0;
ESMInfo.Pd = 1;
ESMInfo.T = 1;
ESMInfo.Type = 200;
ESMInfo.ID = 2;
%Radar参数
RadarInfo.deta = [1;0.1*pi/180;0.1*pi/180;1];
RadarInfo.ClutterD = 0;
RadarInfo.Pd = 1;
RadarInfo.T = 1;
RadarInfo.Type = 100;
RadarInfo.ID = 1;
%仿真参数
N = 50;%拍数
T = 1;%数据产生周期
RadarCV;
ESMCV;
%%开始仿真
%GenerateCircle;
TrueTrace =GenerateXTrace( [5 -5], [5000 5000] ,[100 100]);
%ObserveTrace = GenerateTrace( [1000 100 0 1000 100 0 800 0 0]', 0, T, N);
ObserveTrace = GenerateTrace( [0 0 0 0 0 0 800 0 0]', 0, T, N);
ObserveTrace = ObserveTrace{1};
GenerateRadarMeasure;
GenerateESMMeasure;
for i =1:length(TrueTrace)
    InitState(i).XInit = TrueTrace{i}.Data([1 2 4 5],1);
    InitState(i).PInit = eye(4);
end

RadarTraceVec = GenerateState(RadarMeasure, RadarInfo, ObserveTrace, RCV, InitState);
ESMTraceVec = GenerateState(ESMMeasure, ESMInfo, ObserveTrace, ECV, InitState);
