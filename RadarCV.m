RCV.F =@(T) [1 T   0 0
    0 1   0 0
    0 0   1 T
    0 0   0 1];
RCV.B =@(T) [T^2/2  0
       T      0
    0   T^2/2
    0      T];
RCV.R = @(deta) diag(deta(1:4));
%RadarCV.Q = @(miu) B*diag(miu)*B';
miu =[15 15]';
RCV.Q =@(B) B*diag(miu)*B';
RCV.H = @Jacobi2;