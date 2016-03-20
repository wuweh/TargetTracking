function [State, StateCov] = StateUpdate(Trace, Echo)
%% ����˵��
% �������ܣ��ú�����Ҫ��Ϊ��ʵ�ֺ�����״̬����
% ����˵����
%          ��������� Trace ------- ���µĺ���
%                    Echo -------- ���µĻز�
%          ��������� State ------- ״̬����ֵ
%                    StateCov ---- ״̬Э�������

%% ���Ƚ���״̬��һ��Ԥ��
[StatePre, StateCovPre, MeasPre, SCov] = Predict(Trace.State, Trace.StateCov);

%% ����״̬ѡ��
if nargin == 1
    
    % �޻ز���Ϣ����Ԥ�����
    State = StatePre;
    StateCov = StateCovPre;
else
    
    % �лز���Ϣ�����ûز�����
    innov = Echo.Echo - MeasPre';    % ��Ϣ
    H = HLiner(StatePre);     % ����������Ի�
    K =  StateCovPre * H' * inv(SCov);     % �˲�����
    
    State = StatePre + K * innov;     % ״̬����
    StateCov = (eye(4) - K * H) * StateCovPre;     % ״̬Э�������
end