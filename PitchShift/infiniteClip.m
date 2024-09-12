function [out] = infiniteClip(n)
N = length(in);
out = zeros(N,1);
for n = 1:N

    if in(n,1) >= 0;
    else
        out(n,1) = -1;
    end
end