function [xout, llOK] = ParChecker(x0, modelhandle, pcheckerCrit, rew, maxPump, unbounded, know, puffs, pop)
%Parchecker simply checks to see if the parameters give back a log
%likelihood value that is below a criterion (pcheckerCrit). If it is not it
%tries to "shake" or add random noise to the parameter values to get a
%better set. 
%It tries to do this 20 times, llOk is 1 if the set is ok and 0 otherwise

loopCounter = 1;

t0 = clock;
xbegin = x0;
llOK = 0;

xout = [];

while ( loopCounter <=20  & llOK ==0 )
    
    fx = feval(modelhandle,x0, rew, maxPump, unbounded,know, puffs, pop );

    if (fx < pcheckerCrit & ~isinf(fx))
        xout = x0;
        llOK = 1;
    else
        if (fx<3.*pcheckerCrit)
            x0 = shake_startvalues(x0, loopCounter);         
        else
            x0 = shake_startvalues(xbegin,loopCounter);
        end;
        loopCounter = loopCounter+1;
    end;

end;


    