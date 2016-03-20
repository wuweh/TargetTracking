function Jac=Jacobi2(X_Prediction,x0)
%X_Prediction = [x;vx;y;vy]
x = X_Prediction(1)-x0(1);
vx = X_Prediction(2);
y = X_Prediction(3)-x0(3);
vy = X_Prediction(4);
z = 0 - x0(5);


rxy=sqrt(x^2+y^2);
r=sqrt(rxy^2+z^2);

dfa1x = x/r;
dfa1y = y/r;
dfa2x = (z*x)/(rxy*(r^2));
dfa2y = (z*y)/(rxy*(r^2));
dfa3x = -y/(rxy^2);
dfa3y = x/(rxy^2);
dfa4x = vx / r - x * (vx * x + vy * y) / (r^3);
dfa4vx = x/r;
dfa4y = vy / r - y * (vx * x + vy * y) / (r^3);
dfa4vy = y/r;
Jac =[dfa1x 0 dfa1y 0;
      dfa2x 0 dfa2y 0;
      dfa3x 0 dfa3y 0;
      dfa4x dfa4vx dfa4y dfa4vy];