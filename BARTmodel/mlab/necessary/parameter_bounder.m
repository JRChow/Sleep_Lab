function xout = parameter_bounder( xin, realsIn, lower, upper)
%this little program is useful for putting parameters into bounded or
%reals . Bounded between upper and lower
%
%xin = the parameter
%realisIn = 1 if passing reals in and need the parameter to be
%bounded
%   realsIn = 0 if passing bounded and need parameter in reals
%upper is the value of the upperbound, lower is lower bound

if (realsIn)

       xmid = (upper-lower)/(1+exp(-xin))+lower; 
            
else
       xmid = -log((upper-lower)/(xin-lower) - 1);
    
end;

xout = xmid;