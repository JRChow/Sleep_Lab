function [ L ] = likelihood_pesc( x, rew, maxPump, unbounded, know, puffs, pop )
%LIKELIHOOD_PESC This is the Bayesian model developed in Wallsten, Pleskac,
%& Lejuez (2005). It was the best fitting model. It assumes DMs evaluate
%their potential options of stopping or pumping before each balloon and
%select the pump that will maximize their earnings. After each balloon they
%can learn (know = 0) about the balloon. However, they assume the
%probability of an explosion is a stationary sample-with-replacement
%structure. 
%
%There are 4 parameters:
%beta: response sensitivity
%gamma: sensitivity to gains
%a0: learning parameter1
%b0: learnibng parameter2
%the learning parameters can also be reformatted into more meaningful
%parameters:
%qhat_0 = a0/(a0+b0): this is the subject's initial estimate of the
%likelihood that the balloon will not explode. An optimistic DM will have a
%higher qhat_0.
%var(qhat) = a0*b0/((a0 + b0 + 1)*(a0+b0)^2): the variance sclaes the
%subject's confidence in their initial estimate. It can be interepreted as
%a learning rate parameter. High variance subjects will be more sensitive
%to the data from the balloon, while low variance subjects will be less
%sensitive and stick to their initial estimates.

[rounds, cdata]=size(puffs); %get the number of rounds (balloons) passed in the data.


if (unbounded) % set up the parameters, if optimizing typically send reals so need to scale them into their appropriate boundaries.
   beta = parameter_bounder(x(1),1,0,10); %response sensitivity
   gamma = parameter_bounder(x(2),1,0,1.35); %evaluation sensitivity
   if (know == 0)
       a0 = parameter_bounder(x(3),1,0,1000);%learning parameter 1
       b0 = parameter_bounder(x(4),1,0,1000);%learning parameter 2
       n0 = a0 + b0;
   end;
else
   %if not sending reals
   beta = x(1);
   gamma = x(2);
   if (know == 0)
       a0 = x(3);
       b0 = x(4);
       n0 = a0 + b0;
   end;
end;

Like = [];

cps = (puffs + 1 - pop);%the number of considered pumps...if DM stops then considered 1 + puffs.
a = 0;
n = 0;

for h = 1:rounds
    
    if (know ==1)
        qhat = 127./128;%if no learning set qhat to initial set up of the balloon before pump 1.
    else
        qhat = .00001 + .99998.*((a0 + a)./(n0 + n));%update qhat based on past observed pumps
    end;
    
    Goal = round(-gamma/log(qhat)); %the goal is a function of gamma and qhat, rounded
        
    dis = zeros(1,cps(h)); % a vector to represent distance from the goal...only done for considered puffs

    dis(1:cps(h))= (1:cps(h)) -Goal; % the distance from the goal

    exponentDis = exp(beta.*dis); %the probability of pumping calculation
    
    probPump = 1./(1+exponentDis);
        
    probPump = .00001 + .99998.*probPump; %scale the probability so that between .00001 and .99998
        
    thePump = ones(1, cps(h));%did the DM pump on this considered pump?
        
    thePump(cps(h)) = pop(h);%where did the DM STOP?
            
    log_like_pump = thePump.*log(probPump); %log likelihood of pumping on each pump given they pumped
    
    log_like_stop = (1-thePump).*log(1-probPump); %log likelihood of stopping on each pump given they stopped
    
    logLikeChoice = log_like_pump + log_like_stop; %log likelihood vector
    
    infCheck = abs(logLikeChoice) == inf;%check for infinity...some weird parameter values...maybe old
    
    if (sum(infCheck)>0)
        Like = -inf;
        break, break;
    end;
        
    Like = [Like logLikeChoice];   %build a likelihood vector for the entire balloon
    
    if (know == 0)%learn about the balloons assuming the observed data is binomial
        a =  a + puffs(h) - pop(h);
        n = n + puffs(h);
    end;
end;

min = sum(Like); 

%%right now taking the opposite for minimization routines to find the max...but need to change for graphing purposes.
L = -min;
