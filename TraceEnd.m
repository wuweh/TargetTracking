 function [TraceVec, TraceEndVec] = TraceEnd(TraceVecOld, TraceEndVec)
%% 函数说明：
% 功能说明：该函数主要是实现航迹终结的功能，采用的航迹起始算法为MNLogic终结
% 参数说明：
%          输入参数：TraceVecOld -- 历史航迹集合
%                   TraceEndVec -- 历史断裂的稳定航迹集合
%          输出参数：TraceVec ----- 更新航迹集合，数据类型为元胞数组
%                   TraceVec(i).ID --------- 航迹号
%                   TraceVec(i).Type ------- 航迹类型: 0 --- 临时航迹 1 --- 稳定航迹 
%                                                      2 --- 航迹头                                                   
%                   TraceVec(i).State ------ 航迹状态
%                   TraceVec(i).StateCov --- 航迹状态协方差
%                   TraceVec(i).Echo ------- 回波信息
%                   TraceVec(i).Time ------- 航迹时标
%                   TraceVec(i).EchoFlag --- 有无回波更新标识

%                   TraceEndVec -- 断裂的稳定航迹集合更新
%% 设置航迹终结的参数信息
load AlgData;

%% 进行航迹终结算法
nTraceNum = size(TraceVecOld, 2);     % 航迹个数
IDelIndex = [];
for iTrace = 1 : nTraceNum
    
    if size(TraceVecOld(iTrace).EchoFlag, 2) >= EndParamN
        if (EndParamN - sum(TraceVecOld(iTrace).EchoFlag(1, end -EndParamN + 1: end)) >= EndParamM)
        
            % 终结判断成功
            IDelIndex = [IDelIndex iTrace];
                    
        end
    else
        if (length(TraceVecOld(iTrace).EchoFlag(1, 1: end)) - sum(TraceVecOld(iTrace).EchoFlag(1, 1: end)) >= EndParamM)
             
            % 终结判断成功
            IDelIndex = [IDelIndex iTrace];
        end
    end
end

%% 对终结的稳定航迹进行保存
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

%% 航迹更新
TraceVec = TraceVecOld;
