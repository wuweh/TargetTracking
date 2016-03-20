function [XE,PE,SS,LH] = KalamFilter(x,P,H,R,z,z0)

XP = x;
PP = P;
SS = H*PP*H'+R;
KK = PP*H'*inv(SS);
XE = XP+KK*(z-z0);
PE = PP-KK*H*PP;
LH = exp(-0.5*(z-z0)'*inv(SS)*(z-z0))/sqrt(det(2*pi*SS));