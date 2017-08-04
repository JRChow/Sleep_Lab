function [ xout, fout, exitflag] = neldermead_checker(modelhandle, x0, pcheckerCrit, options, rew, maxPump, unbounded,  know, puffs, pop  )    
%neldermead_checker is a intermediary program that 1.) uses ParChecker to checks to see if the
%initial start values chosen by the program are plausible (above a preset log likelihood criterion)
%. Parchecker checks and also tries to fiddle with the parameters if they are not plausible
%2.) if the set or some form of the set are plausible then passes to
%fminsearch.

%%time saving checker...useless to search a model that sucks right off thebat
[x0, llOK] = ParChecker(x0, modelhandle, pcheckerCrit, rew, maxPump, unbounded, know, puffs, pop );

xout = [];
fout = [];
exitflag = 0;

%if the parameter produces a likelihood above a minimum then passed to
%fminsearch
if (llOK == 1)
    [xout, fout, exitflag, output] = fminsearch(modelhandle,x0, options, rew, maxPump, unbounded,  know, puffs, pop );

end;