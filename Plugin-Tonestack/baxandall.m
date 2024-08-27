function [a1, b1, a2, b2] = baxandall(num_c, den_c, FS, gain)

% reduce to pole-zero form using ferrari

% calculate gain, poles, and zeros 
k=gain*(num_c(1)/den_c(1));
p=real(roots(den_c));
z=real(roots(num_c));


% bilinear transform

num1=k*[(2*FS-z(1)) -(2*FS+z(1))];
num2=[(2*FS-z(2)) -(2*FS+z(2))];
num3=[(2*FS-z(3)) -(2*FS+z(3))];
num4=[(2*FS-z(4)) -(2*FS+z(4))];

den1=[(2*FS-p(1)) -(2*FS+p(1))];
den2=[(2*FS-p(2)) -(2*FS+p(2))];
den3=[(2*FS-p(3)) -(2*FS+p(3))];
den4=[(2*FS-p(4)) -(2*FS+p(4))];


%scaling
num1=num1/den1(1);
den1=den1/den1(1);
num2=num2/den2(1);
den2=den2/den2(1);
num3=num3/den3(1);
den3=den3/den3(1);
num4=num4/den4(1);
den4=den4/den4(1);



%%
a1 = zeros(3,1);
b1 = zeros(3,1);
a2 = zeros(3,1);
b2 = zeros(3,1);

% now it is in the form of 4 single pole TFs, lets transform it into 2 SOS
a1(1)=num1(1)*num2(1);
a1(2)=num1(1)*num2(2)+num1(2)*num2(1);
a1(3)=num1(2)*num2(2);
b1(1)=1;
b1(2)=den1(2)+den2(2);
b1(3)=den1(2)*den2(2);

a2(1)=num3(1)*num4(1);
a2(2)=num3(1)*num4(2)+num3(2)*num4(1);
a2(3)=num3(2)*num4(2);
b2(1)=1;
b2(2)=den3(2)+den4(2);
b2(3)=den3(2)*den4(2);

