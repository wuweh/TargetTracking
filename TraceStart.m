 function TraceVec = TraceStart(EchoVec, TraceVecOld, nTime)
%% 函数说明：
% 功能说明：该函数主要是实现航迹起始的功能，采用的航迹起始算法为MNLogic起始
% 参数说明：
%          输入参数：EchoVec ------ 回波集合
%                   TraceVecOld -- 历史航迹集合
%                   nTime -------- 仿真时标
%          输出参数：TraceVec ----- 更新航迹集合
%                   TraceVec(i).ID --------- 航迹号
%                   TraceVec(i).Type ------- 航迹类型: 0 --- 临时航迹 1 --- 稳定航迹 
%                                                      2 --- 航迹头                                                       
%                   TraceVec(i).State ------ 航迹状态
%                   TraceVec(i).StateCov --- 航迹状态协方差
%                   TraceVec(i).Echo ------- 回波信息
%                   TraceVec(i).Time ------- 航迹时标
%                   TraceVec(i).EchoFlag --- 有无回波更新标识

%% 加载常用参数信息
clc;
load AlgData;
load ParamData;

%% 初始化参数
numEcho = length(EchoVec);         % 回波个数
numTrace = size(TraceVecOld, 2);   % 历史航迹个数

%% 航迹起始主算法步骤
% 4、首先，利用回波进行稳定航迹的确认
usedEchoIndex = [];   % 找出所以用过的回波，然后进行删除
for i = 1 : numTrace
    if TraceVecOld(i).Type == 0
        
        bInGate = zeros(1, numEcho);
        dDistance = zeros(1, numEcho);
        
        for j = 1 : numEcho
            % 进行波门判别
            [bInGate(j), dDistance(j)] = GatingJudge(TraceVecOld(i), EchoVec(j));
        end
        
        if sum(bInGate) == 0
            
            % 无回波更新
            [TraceVecOld(i).State, TraceVecOld(i).StateCov] = StateUpdate(TraceVecOld(i));
            TraceVecOld(i).EchoFlag = [TraceVecOld(i).EchoFlag 0];
            TraceVecOld(i).Time = nTime;
            TraceVecOld(i).StateVec = [TraceVecOld(i).StateVec TraceVecOld(i).State];
            TraceVecOld(i).StateCovVec = cat(3, TraceVecOld(i).StateCovVec, TraceVecOld(i).StateCov);
        else
            
            % 此处采用的关联算法是最近邻找到要利用的回波
            [value, index] = min(dDistance);
            EchoKey = EchoVec(index);
            usedEchoIndex = [usedEchoIndex index];
            
            % 用回波EchoKey进行更新
            [TraceVecOld(i).State, TraceVecOld(i).StateCov] = StateUpdate(TraceVecOld(i), EchoKey);
            TraceVecOld(i).Echo = [TraceVecOld(i).Echo EchoKey];
            TraceVecOld(i).EchoFlag = [TraceVecOld(i).EchoFlag 1];
%             TraceVecOld(i).SCov=SCov;
            TraceVecOld(i).Time = EchoKey.Time;
            TraceVecOld(i).StateVec = [TraceVecOld(i).StateVec TraceVecOld(i).State];
            TraceVecOld(i).StateCovVec = cat(3, TraceVecOld(i).StateCovVec, TraceVecOld(i).StateCov);
        end
    end
    
    % 更新过的回波进行清楚，在循环体内书写次代码，表示量测不可复用
    %EchoVec(usedEchoIndex) = [];
    %EchoNum = size(EchoVec, 2);        % 重新计算回波个数
end

% 更新过的回波进行清楚，在循环体外书写次代码，表示量测可复用
EchoVec(usedEchoIndex) = [];
numEcho = length(EchoVec);        % 重新计算回波个数

% 3、其次，利用回波进行滤波器的起始
usedEchoIndex = [];
for iTrace = 1 : numTrace
    
    if TraceVecOld(iTrace).Type == 2
        for jEcho = 1 : numEcho
            
            % 对于满足速度约束的回波，进行滤波器的起始
            if ((EchoVec(jEcho).Echo(1) - TraceVecOld(iTrace).Echo.Echo(1)) / T_1 < MaxVel &&...
                (EchoVec(jEcho).Echo(1) - TraceVecOld(iTrace).Echo.Echo(1)) / T_1 > MinVel &&...
                (EchoVec(jEcho).Echo(2) * TraceVecOld(iTrace).Echo.Echo(2)) > 0 )     % 同方位
                
                % 由于转换量测后，引起笛卡尔坐标下的误差，故在此加以约束
                EchoSet = [TraceVecOld(iTrace).Echo EchoVec(jEcho)];
                [State, StateCov] = FilterStart(EchoSet);
                if max(norm(State(2:2:end), 2)) > MaxVel
                    continue;
                end
                
                iIndex = length(TraceVecOld) + 1;
                
                TraceVecOld(iIndex).Type = 0;
                TraceVecOld(iIndex).Echo = [TraceVecOld(iTrace).Echo EchoVec(:, jEcho)];
                TraceVecOld(iIndex).State = State;
                TraceVecOld(iIndex).StateCov = StateCov;          
                TraceVecOld(iIndex).Time = nTime;
                TraceVecOld(iIndex).EchoFlag = [1 1];
                TraceVecOld(iIndex).StateVec = [TraceVecOld(iTrace).StateVec TraceVecOld(iIndex).State];
                TraceVecOld(iIndex).StateCovVec(:, :, 1) = TraceVecOld(iIndex).StateCov;
                TraceVecOld(iIndex).StateCovVec(:, :, 2) = TraceVecOld(iIndex).StateCov;
                                
                % 对以用回波进行标记
                usedEchoIndex = [usedEchoIndex jEcho];
                
            end
        end
    end
end

EchoVec(:, usedEchoIndex) = [];
numEcho = size(EchoVec, 2);        % 重新计算回波个数
numTrace = size(TraceVecOld, 2);   % 重新计算航迹个数

% 2、再次，进行虚假航迹的删除
IndexDel = [];
for i = 1 : numTrace
    if TraceVecOld(i).Type == 2
        IndexDel = [IndexDel i];      
    end
end
TraceVecOld(IndexDel) = [];
numTrace = size(TraceVecOld, 2);

% 1、对航迹属性进行更新
iTraceDel = [];
for iTrace = 1 : numTrace
    if TraceVecOld(iTrace).Type == 0
        if size(TraceVecOld(iTrace).EchoFlag, 2) >= StartParamN
            if sum(TraceVecOld(iTrace).EchoFlag(1, end - StartParamN + 1 : end)) < StartParamM
               iTraceDel = [iTraceDel iTrace];    % 不满足MN逻辑的临时航迹删除，该条航迹起始不成功
            else
                TraceVecOld(iTrace).Type = 1;    % 满足MN逻辑的临时航迹变为稳定航迹
            end
        end
    end
end

TraceVecOld(iTraceDel) = [];

%% 历史航迹更新
TraceVec = TraceVecOld;            % 历史航迹加载

% 利用剩余的回波进行航迹头的建立
nTraceNum = size(TraceVec, 2);
for i = 1 : numEcho
    % 量测转换为状态
    MeasXYZ = zeros(4, 1);
    MeasXYZ(1, 1) = EchoVec(i).Echo(1) * cos(EchoVec(i).Echo(3)) * cos(EchoVec(i).Echo(2));
    MeasXYZ(2, 1) = EchoVec(i).Echo(3) * cos(EchoVec(i).Echo(3)) * cos(EchoVec(i).Echo(2));
    MeasXYZ(3, 1) = EchoVec(i).Echo(1) * cos(EchoVec(i).Echo(3)) * sin(EchoVec(i).Echo(2));
    MeasXYZ(4, 1) = EchoVec(i).Echo(3) * cos(EchoVec(i).Echo(3)) * sin(EchoVec(i).Echo(2));
    
    TraceVec(nTraceNum + i).Type = 2;
    TraceVec(nTraceNum + i).State = MeasXYZ;
    TraceVec(nTraceNum + i).StateCov = [];
    TraceVec(nTraceNum + i).Echo = EchoVec(i);
    TraceVec(nTraceNum + i).Time = nTime;
    TraceVec(nTraceNum + i).EchoFlag = 1;
    
    TraceVec(nTraceNum + i).StateVec = TraceVec(nTraceNum + i).State;
    TraceVec(nTraceNum + i).StateCovVec(:, :, 1) = TraceVec(nTraceNum + i).StateCov;
end   

% 航迹号更新
for i = 1 : length(TraceVec)
    TraceVec(i).ID = i;
end
