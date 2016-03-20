 function [TraceVec, EchoRemain] = TraceAssociation(EchoVec, TraceVecOld, nTime)
%% ����˵����
% ����˵�����ú�����Ҫ��ʵ�����ݹ����Ĺ��ܣ����õ����ݹ����㷨ΪPDA�㷨
% ����˵����
%          ���������EchoVec ------ �ز����ϣ���������Ϊ����1�д���һ���ز�
%                   TraceVecOld -- ��ʷ��������
%                   nTime -------- ����ʱ��
%          ���������TraceVec ----- ���º������ϣ���������ΪԪ������
%                   TraceVec(i).ID --------- ������
%                   TraceVec(i).Type ------- ��������: 0 --- ��ʱ����
%                                                     1 --- �ȶ����� 
%                                                     2 --- ����ͷ                                                       
%                   TraceVec(i).State ------ ����״̬
%                   TraceVec(i).StateCov --- ����״̬Э����
%                   TraceVec(i).Echo ------- �ز���Ϣ
%                   TraceVec(i).Time ------- ����ʱ��
%                   TraceVec(i).EchoFlag --- ���޻ز����±�ʶ
%                   TraceVec(i).StateVec --- ��ʷ״̬���±���
%                   EchoRemain ------------- ʣ��ز���Ϣ

%% ���ز�������
clc;
load ParamData;
load AlgData;

%% ����PDA�㷨�Ĳ���
lamuda = Pf_1;                    % ��λ��������������
Pg = 0.99;                      % ���Ÿ���
Pd = Pd_1;     % ������

%% �ҳ��ȶ������������ݹ���
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

%% ���к����������㷨����
nTraceNum = size(TraceVec, 2);   % �ȶ������ĸ���
nEchoNum = length(EchoVec);     % �ز�����
usedEchoIndex = [];              % ���ûز���Ϣ
for iTrace = 1 : nTraceNum
    
    bInGate = zeros(1, nEchoNum);
    dDistance = zeros(1, nEchoNum);
    
    for jEcho = 1 : nEchoNum
        % �ҳ����뺽�����ŵĻز�����
         [bInGate(jEcho), dDistance(jEcho)] = GatingJudge(TraceVec(iTrace), EchoVec(jEcho));
    end
    EchoKeyindex = find(bInGate == 1);
    EchoKey = EchoVec(EchoKeyindex);    % ���뺽�������ڵĻز�����
    
    % ============== PDA�������� ================ %
    % 1��״̬��һ��Ԥ��
    [StatePre, StateCovPre, MeasPre, SCov] = Predict(TraceVec(iTrace).State(:, end), TraceVec(iTrace).StateCov(:, :, end));
    plot(StatePre(1), StatePre(3), '.r');
    H = HLiner(StatePre);
    KGain = StateCovPre * H' * inv(SCov);  % �˲�����
    
    % �޻ز�������Ԥ����и���
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
    
    % �������õ�Ч�������״̬����
    % 2�� ����BetaK����
    Bk = lamuda * 10e-3 * sqrt(2 * pi * det(SCov)) * (1-Pd * Pg)/Pd; 
    
    % 3�������������
    AssPro = zeros(1, length(EchoKey));
    for iAss = 1 : length(AssPro)
        AssPro(iAss) = (EchoKey(iAss).Echo - MeasPre')' * inv(SCov) * (EchoKey(iAss).Echo - MeasPre');
        AssPro(iAss) = exp(- AssPro(iAss) / 2);
    end
    % �������ʹ�һ��
    Beta0 = Bk ./ (Bk + sum(AssPro));     % �޻ز���������
    Beta = AssPro ./ (Bk + sum(AssPro));  % �лز��Ĺ�������
    
    % 4�������Ч�����Լ���Ӧ��״̬Э����    
    MeasSet = [];
    for kEcho = 1 : length(EchoKey);
        MeasSet(:, kEcho) = EchoKey(kEcho).Echo;
    end
    MeasEqual = Beta * MeasSet' + Beta0 * MeasPre;
    MeasEqual = MeasEqual';       % ��Ч����
    
    Pzz = zeros(4, 4);   
    Innov = zeros(4, 1);
    for iEcho = 1 : length(EchoKey)
        Pzz = Pzz + Beta(iEcho) * (MeasSet(:, iAss) - MeasPre') * (MeasSet(:, iAss) - MeasPre')';
        Innov = Innov + Beta(iEcho) * (MeasSet(:, iAss) - MeasPre');
    end
    
    % ����֮��Ļ�Э����
    Pzz = KGain * (Pzz - Innov * Innov') * KGain';
    
    % 5�����ûز�����״̬����
    MeasEqualStruct.Echo = MeasEqual;
    [TraceVec(iTrace).State, TraceVec(iTrace).StateCov] = StateUpdate(TraceVec(iTrace), MeasEqualStruct);
    TraceVec(iTrace).EchoFlag = [TraceVec(iTrace).EchoFlag 1];
    TraceVec(iTrace).Time = nTime;
    TraceVec(iTrace).Echo = [TraceVec(iTrace).Echo EchoKey(1)]; % ���õ�һ��������Ϣ
    TraceVec(iTrace).StateVec = [TraceVec(iTrace).StateVec TraceVec(iTrace).State];
    TraceVec(iTrace).StateCovVec = cat(3, TraceVec(iTrace).StateCovVec, TraceVec(iTrace).StateCov);
    hupdate = plot(TraceVec(iTrace).State(1), TraceVec(iTrace).State(3), 'sb');
    legend(hupdate, 'update');
    
    % 6��״̬Э�������
    TraceVec(iTrace).StateCov = Beta0 * StateCovPre + (1 - Beta0) * TraceVec(iTrace).StateCov + Pzz;   
    
    % 7�������ûز����б���
    usedEchoIndex = [usedEchoIndex EchoKeyindex];
end    

%% �����ûز�����ɾ��
EchoVec(usedEchoIndex) = []; 
EchoRemain = EchoVec;

%% �������±���
if isempty(TraceVec)
    TraceVec = [TraceVecOld];
else
    TraceVec = [TraceVec TraceVecOld];
end
