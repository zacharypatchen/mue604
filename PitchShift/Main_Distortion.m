Fs = 48000; Ts = 1/Fs;

f = 2;

t = [0:Ts:1].';

in = sin(2*pi*f*t);
out = infiniteClip(in);

sound(out, Fs);