function [ TrueTrace ] = GenerateTrace( StateInit, StartTime, T, N, Param, Num, ProcessNoise, Flag )
%���ݸ�����������һ����������ʵ����
%out:
%TrueTrace��ʵ���ݽṹ��
    %TrueTrace.Time ����ʱ���
    %TrueTrace.ID ����Ŀ����
    %TrueTrace.Data ����ֵ

%in:
%StateInit ��ʼ״̬ǰ
%StartTime ��ʼǰһʱ�̣�0
%T��������
%N��������
%Num������ţ���1��ʼ
%Flag �˶�״̬��־��0 ֱ���˶���Ĭ�ϣ� 1 Э��ת��
%ProcessNoise ��������
%%��������
if nargin  <  8
    Flag = 0;
end
[m, n] = size(StateInit);
if nargin <6
    Num = 1:n;
end
if nargin < 7
    ProcessNoise =zeros(3,n);
end
if nargin < 5
    Param =[];
end
switch Flag
%%ֱ���˶�
    case 0
        
        FCA = [ 1 T 0.5*T^2  0 0 0       0 0 0 
                0 1 T        0 0 0       0 0 0
                0 0 1        0 0 0       0 0 0
                0 0 0        1 T 0.5*T^2 0 0 0
                0 0 0        0 1 T       0 0 0
                0 0 0        0 0 1       0 0 0
                0 0 0        0 0 0       1 T 0.5*T^2
                0 0 0        0 0 0       0 1 T
                0 0 0        0 0 0       0 0 1];
        BCA = [(T^2)/2      0      0
                T           0      0
                1           0      0
                0          (T^2)/2 0
                0           T      0
                0           1      0
                0           0     (T^2)/2
                0           0      T 
                0           0      1];
        for jj=1:n
                temp.Data(:,1) = FCA*StateInit(:,jj) + BCA * ProcessNoise(:,jj);
                temp.Time(1) = StartTime+T;
                temp.ID(1) = Num(jj);
            for ii=2:N
                temp.Data(:,ii) = FCA*temp.Data(:,ii-1) + BCA * ProcessNoise(:,jj);
                temp.Time(ii) = StartTime+ii*T;
                temp.ID(ii) = Num(jj);
            end
            TrueTrace{jj} = temp;
        end
%%ˮƽת��
    case 1
        for jj=1:n
            w = Param(1, jj);
            FCT = [ 1 sin(w * T) / w 0        0 (cos(w * T) - 1) / w 0       0 0 0 
                    0 cos(w*T) 0        0 -sin(w * T) 0       0 0 0
                    0 0 0        0 0 0       0 0 0
                    0 (1 - cos(w * T)) / w  0        1 sin(w * T) / w 0       0 0 0
                    0 sin(w * T) 0        0 cos(w * T) 0       0 0 0
                    0 0 0        0 0 0       0 0 0
                    0 0 0        0 0 0       1 0 0
                    0 0 0        0 0 0       0 0 0
                    0 0 0        0 0 0       0 0 0];
            BCT = [ T^2/2 0 0;
                    T 0 0;
                    0 0 0;
                    0 T^2/2 0;
                    0 T 0
                    0 0 0 
                    0 0 0
                    0 0 0
                    0 0 0];

                    temp.Data(:,1) = FCT*StateInit(:,jj) + BCT * ProcessNoise(:,jj);
                    temp.Time(1) = StartTime+T;
                    temp.ID(1) = Num(jj);
            for ii=2:N
                temp.Data(:,ii) = FCT*temp.Data(:,ii-1) + BCT * ProcessNoise(:,jj);
                temp.Time(ii) = StartTime+ii*T;
                temp.ID(ii) = Num(jj);
            end
            TrueTrace{jj} = temp;
         end
    otherwise
end    
end

