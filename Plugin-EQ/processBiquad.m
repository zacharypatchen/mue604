function [y, w] = processBiquad(x, filt, ch)

   [y,w] = filter([filt.a0, filt.a1, filt.a2], [filt.b0, filt.b1, filt.b2],x,filt.w(:,ch));

   
   %w=(1/filt.b0)*(x-filt.b1*filt.wnm1-filt.b2*filt.wnm2);
   %y=filt.a0*w+filt.a1*filt.wnm1+filt.a2*filt.wnm2;
 
   %filt.wnm2=filt.wnm1;
   %filt.wnm1=w;
   