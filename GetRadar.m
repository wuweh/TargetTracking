function [ms] = GetRadar(X,z)
ms(1) = sqrt(X(1)^2+X(3)^2+z^2);
ms(2) = atan(z/sqrt(X(1)^2+X(3)^2));
ms(3) = atan(X(3)/X(1));
ms(4) = (X(1)*X(2)+X(3)*X(4))/ms(1);
ms=ms';
end