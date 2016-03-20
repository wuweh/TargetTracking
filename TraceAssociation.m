 function [TraceVec, EchoRemain] = TraceAssociation(EchoVec, TraceVecOld, nTime)
%% 函数说明：
% 功能说明：该函数主要是实现数据关联的功能，采用的数据关联算法为PDA算法
% 参数说明：
%          输入参数：EchoVec ------ 回波集合，数据类型为矩阵，1列代表一个回波
%                   TraceVecOld -- 历史航迹集合
%                   nTime -------- 仿真时标
%          输出参数：TraceVec ----- 更新航迹集合，数据类型为元胞数组
%                   TraceVec(i).ID --------- 航迹号
%                   TraceVec(i).Type ------- 航迹类型: 0 --- 临时航迹
%                                                     1 --- 稳定航迹 
%                                                     2 --- 航迹头                                                       
%                   TraceVec(i).State ------ 航迹状态
%                   TraceVec(i).StateCov --- 航迹状态协方差
%                   TraceVec(i).Echo ------- 回波信息
%                   TraceVec(i).Time ------- 航迹时标
%                   TraceVec(i).EchoFlag --- 有无回波更新标识
%                   TraceVec(i).StateVec --- 历史状态更新保存
%                   EchoRemain ------------- 剩余回波信息

%% 加载参数数据
clc;
load ParamData;
load AlgData;

%% 定义PDA算法的参数
lamuda = Pf_1;                    % 单位面积的虚假量测数
Pg = 0.99;                      % 波门概率
Pd = Pd_1;     % 检测概率

%% 找出稳定航迹进行数据关联
bSteady = 0;
iTraceDelIndex = [];
for iTrace = 1 : length(TraceVecOld)
    if TraceVecOld(iTrace).Type == 1        
        TraceVec(bSteady + 1) = TraceVecOld(iTrace);
        iTraceDelIndex = [iTraceDelIndex iTrace];
        bSteady = bSteady + 1;
    end
end

TraceVecOld(iTraceDelIndex) = [];

if (bSteady == 0)
    TraceVec = TraceVecOld;
    EchoRemain = EchoVec;
    return 
end

%% 进行航迹关联主算法程序
nTraceNum = size(TraceVec, 2);   % 稳定航迹的个数
nEchoNum = length(EchoVec);     % 回波个数
usedEchoIndex = [];              % 以用回波信息
for iTrace = 1 : nTraceNum
    
    bInGate = zeros(1, nEchoNum);
    dDistance = zeros(1, nEchoNum);
    
    for jEcho = 1 : nEchoNum
        % 找出落入航迹波门的回波集合
         [bInGate(jEcho), dDistance(jEcho)] = GatingJudge(TraceVec(iTrace), EchoVec(jEcho));
    end
    EchoKeyindex = find(bInGate == 1);
    EchoKey = EchoVec(EchoKeyindex);    % 落入航迹波门内的回波集合
    
    % ============== PDA关联处理 ================ %
    % 1、状态的一步预测
    [StatePre, StateCovPre, MeasPre, SCov] = Predict(TraceVec(iTrace).State(:, end), TraceVec(iTrace).StateCov(:, :, end));
    plot(StatePre(1), StatePre(3), '.r');
    H = HLiner(StatePre);
    KGain = StateCovPre * H' * inv(SCov);  % 滤波增益
    
    % 无回波，利用预测进行更新
    if isempty(EchoKey)
        [TraceVec(iTrace).State, TraceVec(iTrace).StateCov] = StateUpdate(TraceVec(iTrace));
        TraceVec(iTrace).StateVec = [TraceVec(iTrace).StateVec TraceVec(iTrace).State];
        TraceVec(iTrace).EchoFlag = [TraceVec(iTrace).EchoFlag 0];
        TraceVec(iTrace).Time = nTime;
        TraceVec(iTrace).StateCovVec = cat(3, TraceVec(iTrace).StateCovVec, TraceVec(iTrace).StateCov);
        hpredict = plot(TraceVec(iTrace).State(1), TraceVec(iTrace).State(3), 'sg');
        legend(hpredict, 'predict');
        continue;
    end
    
    % 否则，利用等效量测进行状态更新
    % 2、 计算BetaK因子
    Bk = lamuda * 10e-3 * sqrt(2 * pi * det(SCov)) * (1-Pd * Pg)/Pd; 
    
    % 3、计算关联概率
    AssPro = zeros(1, length(EchoKey));
    for iAss = 1 : length(AssPro)
        AssPro(iAss) = (EchoKey(iAss).Echo - MeasPre')' * inv(SCov) * (EchoKey(iAss).Echo - MeasPre');
        AssPro(iAss) = exp(- AssPro(iAss) / 2);
    end
    % 关联概率归一化
    Beta0 = Bk ./ (Bk + sum(AssPro));     % 无回波关联概率
    Beta = AssPro ./ (Bk + sum(AssPro));  % 有回波的关联概率
    
    % 4、计算等效量测以及相应的状态协方差    
    MeasSet = [];
    for kEcho = 1 : length(EchoKey);
        MeasSet(:, kEcho) = EchoKey(kEcho).Echo;
    end
    MeasEqual = Beta * MeasSet' + Beta0 * MeasPre;
    MeasEqual = MeasEqual';       % 等效量测
    
    Pzz = zeros(4, 4);   
    Innov = zeros(4, 1);
    for iEcho = 1 : length(EchoKey)
        Pzz = Pzz + Beta(iEcho) * (MeasSet(:, iAss) - MeasPre') * (MeasSet(:, iAss) - MeasPre')';
        Innov = Innov + Beta(iEcho) * (MeasSet(:, iAss) - MeasPre');
    end
    
    % 量测之间的互协方差
    Pzz = KGain * (Pzz - Innov * Innov') * KGain';
    
    % 5、利用回波进行状态更新
    MeasEqualStruct.Echo = MeasEqual;
    [TraceVec(iTrace).State, TraceVec(iTrace).StateCov] = StateUpdate(TraceVec(iTrace), MeasEqualStruct);
    TraceVec(iTrace).EchoFlag = [TraceVec(iTrace).EchoFlag 1];
    TraceVec(iTrace).Time = nTime;
    TraceVec(iTrace).Echo = [TraceVec(iTrace).Echo EchoKey(1)]; % 采用第一个量测信息
    TraceVec(iTrace).StateVec = [TraceVec(iTrace).StateVec TraceVec(iTrace).State];
    TraceVec(iTrace).StateCovVec = cat(3, TraceVec(iTrace).StateCovVec, TraceVec(iTrace).StateCov);
    hupdate = plot(TraceVec(iTrace).State(1), TraceVec(iTrace).State(3), 'sb');
    legend(hupdate, 'update');
    
    % 6、状态协方差更新
    TraceVec(iTrace).StateCov = Beta0 * StateCovPre + (1 - Beta0) * TraceVec(iTrace).StateCov + Pzz;   
    
    % 7、对已用回波进行保存
    usedEchoIndex = [usedEchoIndex EchoKeyindex];
end    

%% 对已用回波进行删除
EchoVec(usedEchoIndex) = []; 
EchoRemain = EchoVec;

%% 航迹更新保存
if isempty(TraceVec)
    TraceVec = [TraceVecOld];
else
    TraceVec = [TraceVec TraceVecOld];
end
