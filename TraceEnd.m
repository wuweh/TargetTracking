 function [TraceVec, TraceEndVec] = TraceEnd(TraceVecOld, TraceEndVec)
%% ����˵����
% ����˵�����ú�����Ҫ��ʵ�ֺ����ս�Ĺ��ܣ����õĺ�����ʼ�㷨ΪMNLogic�ս�
% ����˵����
%          ���������TraceVecOld -- ��ʷ��������
%                   TraceEndVec -- ��ʷ���ѵ��ȶ���������
%          ���������TraceVec ----- ���º������ϣ���������ΪԪ������
%                   TraceVec(i).ID --------- ������
%                   TraceVec(i).Type ------- ��������: 0 --- ��ʱ���� 1 --- �ȶ����� 
%                                                      2 --- ����ͷ                                                   
%                   TraceVec(i).State ------ ����״̬
%                   TraceVec(i).StateCov --- ����״̬Э����
%                   TraceVec(i).Echo ------- �ز���Ϣ
%                   TraceVec(i).Time ------- ����ʱ��
%                   TraceVec(i).EchoFlag --- ���޻ز����±�ʶ

%                   TraceEndVec -- ���ѵ��ȶ��������ϸ���
%% ���ú����ս�Ĳ�����Ϣ
load AlgData;

%% ���к����ս��㷨
nTraceNum = size(TraceVecOld, 2);     % ��������
IDelIndex = [];
for iTrace = 1 : nTraceNum
    
    if size(TraceVecOld(iTrace).EchoFlag, 2) >= EndParamN
        if (EndParamN - sum(TraceVecOld(iTrace).EchoFlag(1, end -EndParamN + 1: end)) >= EndParamM)
        
            % �ս��жϳɹ�
            IDelIndex = [IDelIndex iTrace];
                    
        end
    else
        if (length(TraceVecOld(iTrace).EchoFlag(1, 1: end)) - sum(TraceVecOld(iTrace).EchoFlag(1, 1: end)) >= EndParamM)
             
            % �ս��жϳɹ�
            IDelIndex = [IDelIndex iTrace];
        end
    end
end

%% ���ս���ȶ��������б���
nLength = length(TraceEndVec);
for iEnd = 1 : length(IDelIndex)
    
    if TraceVecOld(IDelIndex(iEnd)).Type == 1
        
        TraceEndVec(nLength + 1).ID = TraceVecOld(IDelIndex(iEnd)).ID;
        TraceEndVec(nLength + 1).Type = TraceVecOld(IDelIndex(iEnd)).Type;
        TraceEndVec(nLength + 1).State = TraceVecOld(IDelIndex(iEnd)).State;
        TraceEndVec(nLength + 1).StateCov = TraceVecOld(IDelIndex(iEnd)).StateCov;
        TraceEndVec(nLength + 1).Echo = TraceVecOld(IDelIndex(iEnd)).Echo;
        TraceEndVec(nLength + 1).Time = TraceVecOld(IDelIndex(iEnd)).Time;
        TraceEndVec(nLength + 1).EchoFlag = TraceVecOld(IDelIndex(iEnd)).EchoFlag;
        TraceEndVec(nLength + 1).StateVec = TraceVecOld(IDelIndex(iEnd)).StateVec;
        TraceEndVec(nLength + 1).StateCovVec = TraceVecOld(IDelIndex(iEnd)).StateCovVec;
        
        nLength = nLength + 1;
    end
end
TraceVecOld(IDelIndex) = [];

%% ��������
TraceVec = TraceVecOld;
