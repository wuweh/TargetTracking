function [StatePre, StateCovPre, MeasPre, SCov] = Predict(State, StateCov)
%% 函数说明
% 功能说明：该函数主要是为了实现状态的一步预测
% 参数说明：
%          输入参数：State ------- 状态估计值
%                   StateCov ---- 状态估计协方差
%          输出参数：StatePre ---- 状态预测值
%                   StateCovPre - 状态预测协方差
%                   MeasPre ----- 量测预测
%                   SCov -------- 新息协方差

%% 加载参数数据
clc;

load ParamData;
load AlgData;

R = R_1;
T = T_1;

[Fcv, Gcv] = CVModel(T);

%% 进行卡尔曼的一步预测
StatePre = Fcv * State;
StateCovPre = Fcv * StateCov * Fcv' + Gcv * Q * Gcv';

MeasPre(1) = sqrt(StatePre(1)^2 + StatePre(3)^2 + (h1 - h2).^2);
MeasPre(2) = atan2(StatePre(3), StatePre(1));
MeasPre(3) = atan2(h2-h1, sqrt(StatePre(1)^2 + StatePre(3)^2));
MeasPre(4) = (StatePre(1) * StatePre(2) + StatePre(3) * StatePre(4)) / MeasPre(1);

H = HLiner(StatePre);
SCov = H * StateCovPre * H' + R;

