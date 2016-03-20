function [ TraceVec ] = GenerateState(Measure, RadarInfo, ObserveTrace, Filter, InitState)
%不跟踪，直接生成航迹
T = RadarInfo.T;
F = Filter.F(T);
B = Filter.B(T);
Q = Filter.Q(B);
% if RadarInfo.Type ~=200
%     R = Filter.R(RadarInfo.deta);
% else
%     R = Filter.R(RadarInfo.deta(2:3));
% end
R = Filter.R(RadarInfo.deta);
N = size(Measure,2);%量测时刻数目

for i=1:size(InitState,2)
    Xpre = zeros(4,N);
    Ppre = zeros(4,4,N);
    TraceVec(i).ID = i;
    TraceVec(i).Type =1;
    TraceVec(i).State =  InitState(i).XInit;
    TraceVec(i).StateCov = InitState(i).PInit;
    if isempty(Measure{1})
        Z=[];
        t1 = 1;
    else
        Z = Measure{1}([Measure{1}.ID] == i);
        t1 = Measure{1}(1).Time;
    end
    if isempty(Z)
        TraceVec(i).Echo(:,1) = [0 0 0 0]';
        TraceVec(i).Time = [t1];
    else
        TraceVec(i).Echo(:,1) = Z.Echo;
        TraceVec(i).Time = [Z.Time];
    end
    Xpre(:,1) = InitState(i).XInit;
    Ppre(:,:,1) = InitState(i).PInit;
    for j = 2:N
        [Xyuce,Pyuce] = OnePredict(Xpre(:,j-1), Ppre(:,:,j-1), F , Q);
        H = Filter.H(Xyuce, ObserveTrace.Data([1 2 4 5 7 8],T*j-T+1));
        Xxiangdui = Xyuce-[ObserveTrace.Data(1,T*j-T+1);0;ObserveTrace.Data(4,T*j-T+1);0];
        z0 = GetRadar(Xxiangdui ,-ObserveTrace.Data(7,T*j-T+1));
        if RadarInfo.Type ==200
            z0([1,4]) = [];
        end
        if isempty(Measure{j})
            Z=[];
            t1 = 1+RadarInfo.T*(j-1);
        else
            Z = Measure{j}([Measure{j}.ID] == i);
            t1 = Measure{j}(1).Time;
        end
        if isempty(Z)
            xE = Xyuce;
            PE = Pyuce;
            TraceVec(i).State(:,j)=xE;
            TraceVec(i).StateCov(:,:,j)=PE;
            TraceVec(i).Echo(:,j) = [0 0 0 0]';
            TraceVec(i).Time = [TraceVec(i).Time t1];
        else
            [xE,PE] = KalamFilter(Xyuce,Pyuce,H,R,Z.Echo,z0);
            TraceVec(i).State(:,j)=xE;
            TraceVec(i).StateCov(:,:,j)=PE;
            TraceVec(i).Echo(:,j) = Z.Echo;
            TraceVec(i).Time = [TraceVec(i).Time Z.Time];
        end
        
        Xpre(:,j)= xE;
        Ppre(:,:,j)=PE;
    end
end
for i =1:length(TraceVec)
    plot(TraceVec(i).State(1,:),TraceVec(i).State(3,:),'*');
end
end


