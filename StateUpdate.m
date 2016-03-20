function [State, StateCov] = StateUpdate(Trace, Echo)
%% 函数说明
% 函数功能：该函数主要是为了实现航迹的状态更新
% 参数说明：
%          输入参数： Trace ------- 更新的航迹
%                    Echo -------- 更新的回波
%          输出参数： State ------- 状态更新值
%                    StateCov ---- 状态协方差更新

%% 首先进行状态的一步预测
[StatePre, StateCovPre, MeasPre, SCov] = Predict(Trace.State, Trace.StateCov);

%% 更新状态选择
if nargin == 1
    
    % 无回波信息，用预测更新
    State = StatePre;
    StateCov = StateCovPre;
else
    
    % 有回波信息，采用回波更新
    innov = Echo.Echo - MeasPre';    % 新息
    H = HLiner(StatePre);     % 量测矩阵线性化
    K =  StateCovPre * H' * inv(SCov);     % 滤波增益
    
    State = StatePre + K * innov;     % 状态更新
    StateCov = (eye(4) - K * H) * StateCovPre;     % 状态协方差更新
end