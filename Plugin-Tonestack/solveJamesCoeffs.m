
function [num4, den4] = solveJamesCoeffs(Bass, Treb, C1,C2,R1,C3,R2,C4,R3,RT,RB)
 
% tone controls (in db)
B=0.1275*10^(Bass/20);
T=0.1625*10^(Treb/20);


num4 =[B^2*C1*C2*C3*C4*R2*RB^2*RT^2*T^2 - B^2*C1*C2*C3*C4*R2*RB^2*RT^2*T -...
    B*C1*C2*C3*C4*R2*RB^2*RT^2*T^2 + B*C1*C2*C3*C4*R2*RB^2*RT^2*T - ...
    B^2*C1*C2*C3*C4*R1*R2*RB^2*RT*T - B^2*C1*C2*C3*C4*R1*R3*RB^2*RT*T - ...
    B^2*C1*C2*C3*C4*R2*R3*RB^2*RT*T + B*C1*C2*C3*C4*R1*R2*RB^2*RT*T + ...
    B*C1*C2*C3*C4*R1*R3*RB^2*RT*T + B*C1*C2*C3*C4*R2*R3*RB^2*RT*T, ...
    B*C1*C2*C3*RB^2*RT^2*T - B^2*C1*C3*C4*R1*R3*RB^2 - B^2*C1*C3*C4*R2*R3*RB^2 - ...
    B^2*C1*C3*C4*R2*RB^2*RT - B^2*C1*C3*C4*R1*R2*RB^2 - C1*C2*C3*R2*RB*RT^2*T^2 - ...
    B*C1*C2*C3*RB^2*RT^2*T^2 - B^2*C1*C2*C3*RB^2*RT^2*T + B*C1*C3*C4*R1*R2*RB^2 + ...
    B*C1*C3*C4*R1*R3*RB^2 + B*C1*C3*C4*R2*R3*RB^2 + B*C1*C3*C4*R2*RB^2*RT + ...
    C1*C2*C3*R2*RB*RT^2*T + B^2*C1*C2*C3*RB^2*RT^2*T^2 + B*C1*C2*C3*R1*RB^2*RT*T - ...
    B*C1*C2*C3*R2*RB*RT^2*T + B*C1*C2*C3*R3*RB^2*RT*T + B*C1*C2*C4*R2*RB*RT^2*T + ...
    B*C1*C2*C4*R2*RB^2*RT*T + B*C1*C2*C4*R3*RB^2*RT*T - B*C1*C3*C4*R2*RB^2*RT*T + ...
    B*C2*C3*C4*R2*RB^2*RT*T - B^2*C1*C2*C3*R1*RB^2*RT*T + B*C1*C2*C3*R2*RB*RT^2*T^2 - ...
    B*C1*C2*C4*R2*RB*RT^2*T^2 - B^2*C1*C2*C3*R3*RB^2*RT*T - B^2*C1*C2*C4*R2*RB^2*RT*T - ...
    B^2*C1*C2*C4*R3*RB^2*RT*T + B^2*C1*C3*C4*R2*RB^2*RT*T - B^2*C2*C3*C4*R2*RB^2*RT*T + ...
    C1*C2*C3*R1*R2*RB*RT*T + C1*C2*C3*R1*R3*RB*RT*T + C1*C2*C3*R2*R3*RB*RT*T - ...
    B*C1*C2*C3*R1*R2*RB*RT*T - B*C1*C2*C3*R1*R3*RB*RT*T + B*C1*C2*C4*R1*R2*RB*RT*T - ...
    B*C1*C2*C3*R2*R3*RB*RT*T + B*C1*C2*C4*R1*R3*RB*RT*T + B*C1*C2*C4*R2*R3*RB*RT*T, ...
    B*C1*C3*R1*RB^2 + B*C1*C3*R3*RB^2 + B*C1*C4*R2*RB^2 + B*C1*C4*R3*RB^2 + ...
    B*C3*C4*R2*RB^2 + B*C1*C3*RB^2*RT + C1*C2*R2*RT^2*T - B^2*C1*C3*R1*RB^2 - ...
    B^2*C1*C3*R3*RB^2 - B^2*C1*C4*R2*RB^2 - B^2*C1*C4*R3*RB^2 - B^2*C3*C4*R2*RB^2 - ...
    B^2*C1*C3*RB^2*RT - C1*C2*R2*RT^2*T^2 + C1*C3*R1*R2*RB + C1*C3*R1*R3*RB + ...
    C1*C3*R2*R3*RB + C1*C3*R2*RB*RT - B*C1*C3*R1*R2*RB - B*C1*C3*R1*R3*RB + ...
    B*C1*C4*R1*R2*RB - B*C1*C3*R2*R3*RB + B*C1*C4*R1*R3*RB + B*C1*C4*R2*R3*RB - ...
    B*C1*C3*R2*RB*RT + B*C1*C4*R2*RB*RT + C1*C2*R1*R2*RT*T + C1*C2*R1*R3*RT*T + ...
    C1*C2*R2*R3*RT*T + C1*C2*R2*RB*RT*T + C1*C2*R3*RB*RT*T - C1*C3*R2*RB*RT*T + ...
    C2*C3*R2*RB*RT*T + B*C1*C2*RB*RT^2*T + B*C1*C2*RB^2*RT*T - B*C1*C3*RB^2*RT*T + ...
    B*C2*C3*RB^2*RT*T - B*C1*C2*RB*RT^2*T^2 - B^2*C1*C2*RB^2*RT*T + B^2*C1*C3*RB^2*RT*T - ...
    B^2*C2*C3*RB^2*RT*T + B*C1*C2*R1*RB*RT*T - B*C1*C2*R2*RB*RT*T + B*C1*C3*R2*RB*RT*T - ...
    B*C1*C4*R2*RB*RT*T - B*C2*C3*R2*RB*RT*T + B*C2*C4*R2*RB*RT*T, ...
    C1*R1*R2 + C1*R1*R3 + C1*R2*R3 + C1*R2*RB + C1*R3*RB + C3*R2*RB + C1*R2*RT + ...
    B*C1*RB^2 + B*C3*RB^2 - B^2*C1*RB^2 - B^2*C3*RB^2 + B*C1*R1*RB - B*C1*R2*RB - ...
    B*C3*R2*RB + B*C4*R2*RB + B*C1*RB*RT - C1*R2*RT*T + C2*R2*RT*T - B*C1*RB*RT*T + ...
    B*C2*RB*RT*T, R2 + B*RB];


den4 = [B*C1*C2*C3*C4*R1*R2*RB^2*RT - B^2*C1*C2*C3*C4*R1*RB^2*RT^2*T - ...
    B*C1*C2*C3*C4*R2*RB^2*RT^2*T^2 - B^2*C1*C2*C3*C4*R2*RB^2*RT^2*T - ...
    B*C1*C2*C3*C4*R1*RB^2*RT^2*T^2 + B*C1*C2*C3*C4*R1*R3*RB^2*RT + ...
    B*C1*C2*C3*C4*R2*R3*RB^2*RT + B^2*C1*C2*C3*C4*R1*RB^2*RT^2*T^2 + ...
    B^2*C1*C2*C3*C4*R2*RB^2*RT^2*T^2 - B^2*C1*C2*C3*C4*R1*R2*RB^2*RT - ...
    B^2*C1*C2*C3*C4*R1*R3*RB^2*RT - B^2*C1*C2*C3*C4*R2*R3*RB^2*RT + ...
    B*C1*C2*C3*C4*R1*RB^2*RT^2*T + B*C1*C2*C3*C4*R2*RB^2*RT^2*T, ...
    B*C1*C2*C3*RB^2*RT^2*T - B^2*C1*C3*C4*R1*R3*RB^2 - B^2*C2*C3*C4*R1*R2*RB^2 - ...
    B^2*C1*C3*C4*R2*R3*RB^2 - B^2*C2*C3*C4*R1*R3*RB^2 - B^2*C2*C3*C4*R2*R3*RB^2 - ...
    B^2*C1*C2*C3*R1*RB^2*RT - B^2*C1*C2*C3*R3*RB^2*RT - B^2*C1*C2*C4*R2*RB^2*RT - ...
    B^2*C1*C3*C4*R1*RB^2*RT - B^2*C1*C2*C4*R3*RB^2*RT - B^2*C1*C3*C4*R2*RB^2*RT - ...
    B^2*C1*C3*C4*R1*R2*RB^2 + B*C1*C2*C4*RB^2*RT^2*T - C1*C2*C3*R1*RB*RT^2*T^2 - ...
    C1*C2*C3*R2*RB*RT^2*T^2 + C1*C2*C3*R1*R2*RB*RT + C1*C2*C3*R1*R3*RB*RT + ...
    C1*C2*C3*R2*R3*RB*RT - B*C1*C2*C3*RB^2*RT^2*T^2 - B^2*C1*C2*C3*RB^2*RT^2*T - ...
    B*C1*C2*C4*RB^2*RT^2*T^2 - B^2*C1*C2*C4*RB^2*RT^2*T + B*C1*C3*C4*R1*R2*RB^2 + ...
    B*C1*C3*C4*R1*R3*RB^2 + B*C2*C3*C4*R1*R2*RB^2 + B*C1*C3*C4*R2*R3*RB^2 + ...
    B*C2*C3*C4*R1*R3*RB^2 + B*C2*C3*C4*R2*R3*RB^2 + B*C1*C2*C3*R1*RB^2*RT + ...
    B*C1*C2*C3*R3*RB^2*RT + B*C1*C2*C4*R2*RB^2*RT + B*C1*C3*C4*R1*RB^2*RT + ...
    B*C1*C2*C4*R3*RB^2*RT + B*C1*C3*C4*R2*RB^2*RT + C1*C2*C3*R1*RB*RT^2*T + ...
    C1*C2*C3*R2*RB*RT^2*T + B^2*C1*C2*C3*RB^2*RT^2*T^2 + B^2*C1*C2*C4*RB^2*RT^2*T^2 - ...
    B*C1*C2*C3*R1*RB*RT^2*T - B*C1*C2*C3*R2*RB*RT^2*T + B*C1*C2*C4*R1*RB*RT^2*T + ...
    B*C1*C2*C4*R2*RB*RT^2*T - B*C1*C3*C4*R1*RB^2*RT*T - B*C1*C3*C4*R2*RB^2*RT*T + ...
    B*C2*C3*C4*R1*RB^2*RT*T + B*C2*C3*C4*R2*RB^2*RT*T + B*C1*C2*C3*R1*RB*RT^2*T^2 + ...
    B*C1*C2*C3*R2*RB*RT^2*T^2 - B*C1*C2*C4*R1*RB*RT^2*T^2 - B*C1*C2*C4*R2*RB*RT^2*T^2 + ...
    B^2*C1*C3*C4*R1*RB^2*RT*T + B^2*C1*C3*C4*R2*RB^2*RT*T - B^2*C2*C3*C4*R1*RB^2*RT*T - ...
    B^2*C2*C3*C4*R2*RB^2*RT*T - B*C1*C2*C3*R1*R2*RB*RT - B*C1*C2*C3*R1*R3*RB*RT + ...
    B*C1*C2*C4*R1*R2*RB*RT - B*C1*C2*C3*R2*R3*RB*RT + B*C1*C2*C4*R1*R3*RB*RT + ...
    B*C1*C2*C4*R2*R3*RB*RT, ...
    B*C1*C3*R1*RB^2 + B*C2*C3*R1*RB^2 + B*C1*C3*R3*RB^2 + B*C1*C4*R2*RB^2 + ...
    B*C1*C4*R3*RB^2 + B*C2*C3*R3*RB^2 + B*C2*C4*R2*RB^2 + B*C3*C4*R1*RB^2 + ...
    B*C2*C4*R3*RB^2 + B*C3*C4*R2*RB^2 + B*C1*C2*RB^2*RT + B*C1*C3*RB^2*RT + ...
    B*C1*C4*RB^2*RT + C1*C2*R1*RT^2*T + C1*C2*R2*RT^2*T + C1*C2*RB*RT^2*T - ...
    B^2*C1*C3*R1*RB^2 - B^2*C2*C3*R1*RB^2 - B^2*C1*C3*R3*RB^2 - B^2*C1*C4*R2*RB^2 - ...
    B^2*C1*C4*R3*RB^2 - B^2*C2*C3*R3*RB^2 - B^2*C2*C4*R2*RB^2 - B^2*C3*C4*R1*RB^2 - ...
    B^2*C2*C4*R3*RB^2 - B^2*C3*C4*R2*RB^2 - B^2*C1*C2*RB^2*RT - B^2*C1*C3*RB^2*RT - ...
    B^2*C1*C4*RB^2*RT - C1*C2*R1*RT^2*T^2 - C1*C2*R2*RT^2*T^2 - C1*C2*RB*RT^2*T^2 + ...
    C1*C3*R1*R2*RB + C1*C3*R1*R3*RB + C2*C3*R1*R2*RB + C1*C3*R2*R3*RB + C2*C3*R1*R3*RB + ...
    C2*C3*R2*R3*RB + C1*C2*R1*R2*RT + C1*C2*R1*R3*RT + C1*C2*R2*R3*RT + C1*C2*R2*RB*RT + ...
    C1*C3*R1*RB*RT + C1*C2*R3*RB*RT + C1*C3*R2*RB*RT - B*C1*C3*R1*R2*RB - B*C1*C3*R1*R3*RB + ...
    B*C1*C4*R1*R2*RB - B*C2*C3*R1*R2*RB - B*C1*C3*R2*R3*RB + B*C1*C4*R1*R3*RB - ...
    B*C2*C3*R1*R3*RB + B*C2*C4*R1*R2*RB + B*C1*C4*R2*R3*RB - B*C2*C3*R2*R3*RB + ...
    B*C2*C4*R1*R3*RB + B*C2*C4*R2*R3*RB + B*C1*C2*R1*RB*RT - B*C1*C2*R2*RB*RT - ...
    B*C1*C3*R1*RB*RT - B*C1*C3*R2*RB*RT + B*C1*C4*R1*RB*RT + B*C1*C4*R2*RB*RT - ...
    C1*C3*R1*RB*RT*T - C1*C3*R2*RB*RT*T + C2*C3*R1*RB*RT*T + C2*C3*R2*RB*RT*T - ...
    B*C1*C3*RB^2*RT*T - B*C1*C4*RB^2*RT*T + B*C2*C3*RB^2*RT*T + B*C2*C4*RB^2*RT*T + ...
    B^2*C1*C3*RB^2*RT*T + B^2*C1*C4*RB^2*RT*T - B^2*C2*C3*RB^2*RT*T - B^2*C2*C4*RB^2*RT*T + ...
    B*C1*C3*R1*RB*RT*T + B*C1*C3*R2*RB*RT*T - B*C1*C4*R1*RB*RT*T - B*C2*C3*R1*RB*RT*T - ...
    B*C1*C4*R2*RB*RT*T - B*C2*C3*R2*RB*RT*T + B*C2*C4*R1*RB*RT*T + B*C2*C4*R2*RB*RT*T,...
    C1*R1*R2 + C1*R1*R3 + C2*R1*R2 + C1*R2*R3 + C2*R1*R3 + C2*R2*R3 + C1*R2*RB + ...
    C1*R3*RB + C2*R2*RB + C3*R1*RB + C2*R3*RB + C3*R2*RB + C1*R1*RT + C1*R2*RT + ...
    C1*RB*RT + B*C1*RB^2 + B*C2*RB^2 + B*C3*RB^2 + B*C4*RB^2 - B^2*C1*RB^2 - ...
    B^2*C2*RB^2 - B^2*C3*RB^2 - B^2*C4*RB^2 + B*C1*R1*RB - B*C1*R2*RB + B*C2*R1*RB - ...
    B*C2*R2*RB - B*C3*R1*RB - B*C3*R2*RB + B*C4*R1*RB + B*C4*R2*RB - C1*R1*RT*T - ...
    C1*R2*RT*T + C2*R1*RT*T + C2*R2*RT*T - C1*RB*RT*T + C2*RB*RT*T,...
    R1 + R2 + RB];
 
 

