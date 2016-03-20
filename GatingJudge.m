function [bInGate dDistance] = GatingJudge(Trace, Echo)
%% ����˵��
% ����˵�����ú�����Ҫ���жϺ�����Ŀ���Ƿ����
%����˵����
%         ���������Trace --------- ������Ϣ
%                  Echo ---------- �ز���Ϣ
%         ���������bInGate ------- �жϻز��Ƿ��ں���������
%                  dDistance ----- �������

%% ���ز�������
clc
load ParamData
load AlgData;

%% ���ò�������
Gating = Gate;

%% ������һ��Ԥ��
[statePre, stateCovPre, MearPre, SCov] = Predict(Trace.State(:, end), Trace.StateCov(:, :, end));

%% �в����
Echo = Echo.Echo;
innov = Echo' - MearPre;   % �в�

dDistance = innov * inv(SCov) * innov';  % ��һ������

%% �����б�
if dDistance <= Gating
    bInGate = 1;
else
    bInGate = 0;
end
