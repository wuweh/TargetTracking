function [bInGate dDistance] = GatingJudge(Trace, Echo)
%% 函数说明
% 功能说明：该函数主要是判断航迹与目标是否关联
%参数说明：
%         输入参数：Trace --------- 航迹信息
%                  Echo ---------- 回波信息
%         输出参数：bInGate ------- 判断回波是否在航迹波门内
%                  dDistance ----- 相隔距离

%% 加载参数数据
clc
load ParamData
load AlgData;

%% 设置波门门限
Gating = Gate;

%% 航迹的一步预测
[statePre, stateCovPre, MearPre, SCov] = Predict(Trace.State(:, end), Trace.StateCov(:, :, end));

%% 残差计算
Echo = Echo.Echo;
innov = Echo' - MearPre;   % 残差

dDistance = innov * inv(SCov) * innov';  % 归一化距离

%% 波门判别
if dDistance <= Gating
    bInGate = 1;
else
    bInGate = 0;
end
