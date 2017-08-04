function [xout] = shake_startvalues(xin, iter)
%randlomly shakes start values as some function between 0 and the value of
%the unscaled parameter (tried scaled...but a real pain in the ass...try
%some other day).

[r, c] = size(xin);

thePert = rand(r,c);

xmid = xin.*(1+((thePert.*2)-1).*exp(-1/iter));
[r, c] = size(xmid);

xout = xmid;
