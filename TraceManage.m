function TraceVec = TraceManage(nMCSim)
%% ����˵����
% ����˵�����ú�����Ҫ��ʵ�ֺ�������Ĺ��ܣ�����������ϵͳ�Ŀ��������Լ���ں���
% ����˵����
%          ���������nMCSim ------ ���ؿ���������
%          ���������TraceVec ----- ���º������ϣ���������Ϊ�ṹ��
%                   TraceVec(i).ID --------- ������
%                   TraceVec(i).Type ------- ��������: 0 --- ��ʱ���� 1 --- �ȶ�����
%                                                      2 --- ����ͷ
%                   TraceVec(i).State ------ ����״̬
%                   TraceVec(i).StateCov --- ����״̬Э����
%                   TraceVec(i).Echo ------- �ز���Ϣ
%                   TraceVec(i).Time ------- ����ʱ��
%                   TraceVec(i).EchoFlag --- ���޻ز����±�ʶ

%% ���ط�������
clc;
clear;
close all;

load ParamData;
load AlgData;
load ScenarioData;

EchoVec = Echo_G;     % GMTI�ز�

%% �����������
if nargin == 0
    nMCSim = 1;
end

%% ������ʼ��
n = size(Echo_G, 2);     % GMTI������
TraceVec = cell(0);
TraceEndVec = struct([]);     % ���սẽ��
TraceTotal = cell(1, n);     % ÿ�ĵĺ�������

%% �����������������
for iStep = 1 : n
    
    % 1������ÿһ�ķ���Ļز�����
    Echo = EchoVec(iStep);     % ��ǰ�ĵĻز�
    Echo = cell2mat(Echo);
    
    % ��ͼ
    for i = 1 :size(Echo,2)
        Rhol = Echo(i).Echo(1);     % �������
        Theta1 = Echo(i).Echo(2);     %��λ��
        arfa = Echo(i).Echo(3);     % ������
        plot(Rhol * cos(arfa) * cos(Theta1), Rhol * cos(arfa) * sin(Theta1), 'r*');
        hold on;
        drawnow;
        axis equal;
    end
    
    % 2�����ȣ��Ժ��������սᴦ��
    [TraceVec, TraceEndVec] = TraceEnd(TraceVec, TraceEndVec);
    
    % 3����Σ��������Ļز����ݣ������ȶ������ĸ���
    [TraceVec, Echo] = TraceAssociation(Echo, TraceVec, iStep);
    
    % 4�������ʣ�µĻز����ݽ��к�����ʼ
    TraceVec = TraceStart(Echo, TraceVec, iStep);
    
    % 5������ÿ�Ļ�õĺ�������
    TraceTotal(iStep) = {TraceVec};
end

%% ���ȶ��������б���
indexDel = [];
for iTrace = 1 : size(TraceVec, 2)
    % �ҵ����ȶ�����
    if TraceVec(iTrace).Type ~= 1
        indexDel = [indexDel iTrace];
    end
end
TraceVec(indexDel) = [];     % ɾ�����ȶ�����

TraceFinalVec = TraceVec;     % �����ȶ�����

%% �Ժ����Ž�������
% ���Ѻ���
for i = 1 : length(TraceEndVec)
    TraceEndVec(i).ID = i;
end

% �ȶ�����
for j = 1 : length(TraceFinalVec)
    TraceFinalVec(j).ID = length(TraceEndVec) + j;
end

TotalTrace = [TraceEndVec TraceFinalVec];

save TraceData TraceEndVec TraceFinalVec TotalTrace TraceTotal;

%% ��ͼ
figure;
% ���Ѻ���
for iTrace = 1 : size(TraceEndVec, 2)
    
    % �ҵ����Ѻ����ս��֮ǰ�����һ���лز�ʱ��
    index = 0;     % �޻ز�ʱ����
    for i = size(TraceEndVec(iTrace).EchoFlag, 2) : -1 : 1
        j = TraceEndVec(iTrace).EchoFlag(1, i);     % ��ǰ�����޻ز�
        if j == 0     % ��ǰ���޻ز�
            index = index + 1;
            if index == EndParamM
                omit = i;
                break;
            end
        end
    end
    
    StateVec =TraceEndVec(iTrace).StateVec(:, 1:omit-1);
    XData = StateVec(1, :);
    YData = StateVec(3, :);

    hend = plot(XData, YData, 'k-', 'LineWidth', 2);
    hold on;
    
    xlabel('x(m)');
    ylabel('y(m)');
    
    axis equal;
end

% �ȶ�����
for iTrace = 1 : size(TraceFinalVec, 2)
    
    StateVec =TraceFinalVec(iTrace).StateVec;
    XData = StateVec(1, :);
    YData = StateVec(3, :);
    
    hnow = plot(XData, YData, 'r-', 'LineWidth', 2);
    hold on;
    
    xlabel('x(m)');
    ylabel('y(m)');
    
    axis equal;
end

legend([hnow, hend], '�ȶ�����', '���Ѻ���');