function [StatePre, StateCovPre, MeasPre, SCov] = Predict(State, StateCov)
%% ����˵��
% ����˵�����ú�����Ҫ��Ϊ��ʵ��״̬��һ��Ԥ��
% ����˵����
%          ���������State ------- ״̬����ֵ
%                   StateCov ---- ״̬����Э����
%          ���������StatePre ---- ״̬Ԥ��ֵ
%                   StateCovPre - ״̬Ԥ��Э����
%                   MeasPre ----- ����Ԥ��
%                   SCov -------- ��ϢЭ����

%% ���ز�������
clc;

load ParamData;
load AlgData;

R = R_1;
T = T_1;

[Fcv, Gcv] = CVModel(T);

%% ���п�������һ��Ԥ��
StatePre = Fcv * State;
StateCovPre = Fcv * StateCov * Fcv' + Gcv * Q * Gcv';

MeasPre(1) = sqrt(StatePre(1)^2 + StatePre(3)^2 + (h1 - h2).^2);
MeasPre(2) = atan2(StatePre(3), StatePre(1));
MeasPre(3) = atan2(h2-h1, sqrt(StatePre(1)^2 + StatePre(3)^2));
MeasPre(4) = (StatePre(1) * StatePre(2) + StatePre(3) * StatePre(4)) / MeasPre(1);

H = HLiner(StatePre);
SCov = H * StateCovPre * H' + R;

