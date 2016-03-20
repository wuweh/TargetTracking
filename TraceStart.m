 function TraceVec = TraceStart(EchoVec, TraceVecOld, nTime)
%% ����˵����
% ����˵�����ú�����Ҫ��ʵ�ֺ�����ʼ�Ĺ��ܣ����õĺ�����ʼ�㷨ΪMNLogic��ʼ
% ����˵����
%          ���������EchoVec ------ �ز�����
%                   TraceVecOld -- ��ʷ��������
%                   nTime -------- ����ʱ��
%          ���������TraceVec ----- ���º�������
%                   TraceVec(i).ID --------- ������
%                   TraceVec(i).Type ------- ��������: 0 --- ��ʱ���� 1 --- �ȶ����� 
%                                                      2 --- ����ͷ                                                       
%                   TraceVec(i).State ------ ����״̬
%                   TraceVec(i).StateCov --- ����״̬Э����
%                   TraceVec(i).Echo ------- �ز���Ϣ
%                   TraceVec(i).Time ------- ����ʱ��
%                   TraceVec(i).EchoFlag --- ���޻ز����±�ʶ

%% ���س��ò�����Ϣ
clc;
load AlgData;
load ParamData;

%% ��ʼ������
numEcho = length(EchoVec);         % �ز�����
numTrace = size(TraceVecOld, 2);   % ��ʷ��������

%% ������ʼ���㷨����
% 4�����ȣ����ûز������ȶ�������ȷ��
usedEchoIndex = [];   % �ҳ������ù��Ļز���Ȼ�����ɾ��
for i = 1 : numTrace
    if TraceVecOld(i).Type == 0
        
        bInGate = zeros(1, numEcho);
        dDistance = zeros(1, numEcho);
        
        for j = 1 : numEcho
            % ���в����б�
            [bInGate(j), dDistance(j)] = GatingJudge(TraceVecOld(i), EchoVec(j));
        end
        
        if sum(bInGate) == 0
            
            % �޻ز�����
            [TraceVecOld(i).State, TraceVecOld(i).StateCov] = StateUpdate(TraceVecOld(i));
            TraceVecOld(i).EchoFlag = [TraceVecOld(i).EchoFlag 0];
            TraceVecOld(i).Time = nTime;
            TraceVecOld(i).StateVec = [TraceVecOld(i).StateVec TraceVecOld(i).State];
            TraceVecOld(i).StateCovVec = cat(3, TraceVecOld(i).StateCovVec, TraceVecOld(i).StateCov);
        else
            
            % �˴����õĹ����㷨��������ҵ�Ҫ���õĻز�
            [value, index] = min(dDistance);
            EchoKey = EchoVec(index);
            usedEchoIndex = [usedEchoIndex index];
            
            % �ûز�EchoKey���и���
            [TraceVecOld(i).State, TraceVecOld(i).StateCov] = StateUpdate(TraceVecOld(i), EchoKey);
            TraceVecOld(i).Echo = [TraceVecOld(i).Echo EchoKey];
            TraceVecOld(i).EchoFlag = [TraceVecOld(i).EchoFlag 1];
%             TraceVecOld(i).SCov=SCov;
            TraceVecOld(i).Time = EchoKey.Time;
            TraceVecOld(i).StateVec = [TraceVecOld(i).StateVec TraceVecOld(i).State];
            TraceVecOld(i).StateCovVec = cat(3, TraceVecOld(i).StateCovVec, TraceVecOld(i).StateCov);
        end
    end
    
    % ���¹��Ļز������������ѭ��������д�δ��룬��ʾ���ⲻ�ɸ���
    %EchoVec(usedEchoIndex) = [];
    %EchoNum = size(EchoVec, 2);        % ���¼���ز�����
end

% ���¹��Ļز������������ѭ��������д�δ��룬��ʾ����ɸ���
EchoVec(usedEchoIndex) = [];
numEcho = length(EchoVec);        % ���¼���ز�����

% 3����Σ����ûز������˲�������ʼ
usedEchoIndex = [];
for iTrace = 1 : numTrace
    
    if TraceVecOld(iTrace).Type == 2
        for jEcho = 1 : numEcho
            
            % ���������ٶ�Լ���Ļز��������˲�������ʼ
            if ((EchoVec(jEcho).Echo(1) - TraceVecOld(iTrace).Echo.Echo(1)) / T_1 < MaxVel &&...
                (EchoVec(jEcho).Echo(1) - TraceVecOld(iTrace).Echo.Echo(1)) / T_1 > MinVel &&...
                (EchoVec(jEcho).Echo(2) * TraceVecOld(iTrace).Echo.Echo(2)) > 0 )     % ͬ��λ
                
                % ����ת�����������ѿ��������µ������ڴ˼���Լ��
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
                                
                % �����ûز����б��
                usedEchoIndex = [usedEchoIndex jEcho];
                
            end
        end
    end
end

EchoVec(:, usedEchoIndex) = [];
numEcho = size(EchoVec, 2);        % ���¼���ز�����
numTrace = size(TraceVecOld, 2);   % ���¼��㺽������

% 2���ٴΣ�������ٺ�����ɾ��
IndexDel = [];
for i = 1 : numTrace
    if TraceVecOld(i).Type == 2
        IndexDel = [IndexDel i];      
    end
end
TraceVecOld(IndexDel) = [];
numTrace = size(TraceVecOld, 2);

% 1���Ժ������Խ��и���
iTraceDel = [];
for iTrace = 1 : numTrace
    if TraceVecOld(iTrace).Type == 0
        if size(TraceVecOld(iTrace).EchoFlag, 2) >= StartParamN
            if sum(TraceVecOld(iTrace).EchoFlag(1, end - StartParamN + 1 : end)) < StartParamM
               iTraceDel = [iTraceDel iTrace];    % ������MN�߼�����ʱ����ɾ��������������ʼ���ɹ�
            else
                TraceVecOld(iTrace).Type = 1;    % ����MN�߼�����ʱ������Ϊ�ȶ�����
            end
        end
    end
end

TraceVecOld(iTraceDel) = [];

%% ��ʷ��������
TraceVec = TraceVecOld;            % ��ʷ��������

% ����ʣ��Ļز����к���ͷ�Ľ���
nTraceNum = size(TraceVec, 2);
for i = 1 : numEcho
    % ����ת��Ϊ״̬
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

% �����Ÿ���
for i = 1 : length(TraceVec)
    TraceVec(i).ID = i;
end
