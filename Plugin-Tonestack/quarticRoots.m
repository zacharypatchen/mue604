function x = quarticRoots(polynom);
x = zeros(4,1);

% this is for descending coefficients b0*x^4+b1*x^3+...
b0= polynom(1);
b1= polynom(2);
b2= polynom(3);
b3= polynom(4);
b4= polynom(5);


%{
% this is for ascending coefficients b0+b1*x+...
b0= polynom(5);
b1= polynom(4);
b2= polynom(3);
b3= polynom(2);
b4= polynom(1);
%}

a=(-3*b1^2)/(8*b0^2)+b2/b0;
b=b1^3/(8*b0^3)-(b1*b2)/(2*b0^2)+b3/b0;
c=(-3*b1^4)/(256*b0^4)+(b2*b1^2)/(16*b0^3)-(b1*b3)/(4*b0^2)+b4/b0;

P=-a^2/12-c;
Q=-a^3/108+(a*c)/3-b^2/8;
R=-Q/2+complex(Q^2/4+P^3/27)^(1/2);
R = real(R);

U=complex(R)^(1/3);  % there are 3 complex roots - any of them will do
if (U==0)
    V=-(complex(Q)^(1/3));
else
    V=-P/(3*U);
end

y=(-5/6)*a+U+V;
W=complex(a+2*y)^(1/2);

x(1)=real(-b1/(4*b0)+(W+sqrt(complex(-(3*a+2*y+(2*b)/W))))/2);
x(2)=real(-b1/(4*b0)+(W-sqrt(complex(-(3*a+2*y+(2*b)/W))))/2);
x(3)=real(-b1/(4*b0)+(-W-sqrt(complex(-(3*a+2*y-(2*b)/W))))/2);
x(4)=real(-b1/(4*b0)+(-W+sqrt(complex(-(3*a+2*y-(2*b)/W))))/2);