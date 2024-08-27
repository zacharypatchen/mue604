function H = JamesTS2TF(RCvalues)


syms H ZT1 ZB1 ZB2 ZT2 Zi Zj Zk Zx s B T

syms R1 C2 C1 C3 R2 C4 R3 RT RB

% our ckt
C1 = 6.8e-9;
C2 = 33e-9;
R1 = 12e3;
C3 = 10.e-9;
R2 = 1200;
C4 = 100e-9;
R3  = 3300;
RT = 47e3;
RB = 47e3;


% lumping elements together
ZB1 = R1 + (1-B)*RB/(1+s*(1-B)*RB*C3);
ZB2 = R2 + RB*B/(1+s*RB*B*C4);
ZT1 = 1/(s*C1) + RT*(1-T);
ZT2 = 1/(s*C2) + RT*T;

% delta-Y conversion
Zi = ZB1*ZT1/(R3 + ZB1 + ZT1);
Zj = R3*ZT1/(R3 + ZB1 + ZT1);
Zk = ZB1*R3/(R3 + ZB1 + ZT1);

% output impedance at Vx
Zx = (Zj+ZT2)*(Zk+ZB2)/(ZB2+Zk+Zj+ZT2);

%transfer functions
H = (Zx/(Zi+Zx))*(ZT2/(ZT2+Zj));


