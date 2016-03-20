function TraceVec = TraceManage(nMCSim)
%% 函数说明：
% 功能说明：该函数主要是实现航迹管理的功能，是整个跟踪系统的控制中心以及入口函数
% 参数说明：
%          输入参数：nMCSim ------ 蒙特卡洛仿真次数
%          输出参数：TraceVec ----- 更新航迹集合，数据类型为结构体
%                   TraceVec(i).ID --------- 航迹号
%                   TraceVec(i).Type ------- 航迹类型: 0 --- 临时航迹 1 --- 稳定航迹
%                                                      2 --- 航迹头
%                   TraceVec(i).State ------ 航迹状态
%                   TraceVec(i).StateCov --- 航迹状态协方差
%                   TraceVec(i).Echo ------- 回波信息
%                   TraceVec(i).Time ------- 航迹时标
%                   TraceVec(i).EchoFlag --- 有无回波更新标识

%% 加载仿真数据
clc;
clear;
close all;

load ParamData;
load AlgData;
load ScenarioData;

EchoVec = Echo_G;     % GMTI回波

%% 输入参数控制
if nargin == 0
    nMCSim = 1;
end

%% 航迹初始化
n = size(Echo_G, 2);     % GMTI量测数
TraceVec = cell(0);
TraceEndVec = struct([]);     % 已终结航迹
TraceTotal = cell(1, n);     % 每拍的航迹数据

%% 航迹管理主处理程序
for iStep = 1 : n
    
    % 1、加载每一拍仿真的回波数据
    Echo = EchoVec(iStep);     % 当前拍的回波
    Echo = cell2mat(Echo);
    
    % 绘图
    for i = 1 :size(Echo,2)
        Rhol = Echo(i).Echo(1);     % 径向距离
        Theta1 = Echo(i).Echo(2);     %方位角
        arfa = Echo(i).Echo(3);     % 俯仰角
        plot(Rhol * cos(arfa) * cos(Theta1), Rhol * cos(arfa) * sin(Theta1), 'r*');
        hold on;
        drawnow;
        axis equal;
    end
    
    % 2、首先，对航迹进行终结处理
    [TraceVec, TraceEndVec] = TraceEnd(TraceVec, TraceEndVec);
    
    % 3、其次，对新来的回波数据，进行稳定航迹的更新
    [TraceVec, Echo] = TraceAssociation(Echo, TraceVec, iStep);
    
    % 4、最后，用剩下的回波数据进行航迹起始
    TraceVec = TraceStart(Echo, TraceVec, iStep);
    
    % 5、保存每拍获得的航迹数据
    TraceTotal(iStep) = {TraceVec};
end

%% 对稳定航迹进行保存
indexDel = [];
for iTrace = 1 : size(TraceVec, 2)
    % 找到非稳定航迹
    if TraceVec(iTrace).Type ~= 1
        indexDel = [indexDel iTrace];
    end
end
TraceVec(indexDel) = [];     % 删除非稳定航迹

TraceFinalVec = TraceVec;     % 保存稳定航迹

%% 对航迹号进行重拍
% 断裂航迹
for i = 1 : length(TraceEndVec)
    TraceEndVec(i).ID = i;
end

% 稳定航迹
for j = 1 : length(TraceFinalVec)
    TraceFinalVec(j).ID = length(TraceEndVec) + j;
end

TotalTrace = [TraceEndVec TraceFinalVec];

save TraceData TraceEndVec TraceFinalVec TotalTrace TraceTotal;

%% 绘图
figure;
% 断裂航迹
for iTrace = 1 : size(TraceEndVec, 2)
    
    % 找到断裂航迹终结段之前的最后一个有回波时刻
    index = 0;     % 无回波时刻数
    for i = size(TraceEndVec(iTrace).EchoFlag, 2) : -1 : 1
        j = TraceEndVec(iTrace).EchoFlag(1, i);     % 当前拍有无回波
        if j == 0     % 当前拍无回波
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

% 稳定航迹
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

legend([hnow, hend], '稳定航迹', '断裂航迹');