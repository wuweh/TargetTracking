ECV.F =@(T) [1 T   0 0
    0 1   0 0
    0 0   1 T
    0 0   0 1];
ECV.B =@(T) [T^2/2  0
       T      0
    0   T^2/2
    0      T];
ECV.R = @(deta) diag(deta(2:3));
%RadaECV.Q = @(miu) B*diag(miu)*B';
miu =[10 10]';
ECV.Q =@(B) B*diag(miu)*B';
ECV.H = @Jacobi1;