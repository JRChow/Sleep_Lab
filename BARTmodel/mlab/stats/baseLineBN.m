function [LL_stop, q_stop, LL_all, q_all] = baseLineBN(puffs, pop)
%the baseline model. See wallsten, pleskac, and lejuez (2005) for
%description.
%
%basically uses the prop. of pumping on an opportunity to estimate the
%prob. of pumping on an opportunity...and estimates the likelihood of the
%data based on that data. We can get 2 different estimates. One where prop.
%is estimated only on the stop balloons and one where the estimate is based
%on all. The all is a tougher criterion so generally use that one.

 stop = ~pop;
 
 whereStop = find(pop == 0);
 
 puffstop = puffs(whereStop);
 
 [r, c] = size(puffstop);
 
 q_stop = sum(puffstop)./(sum(puffstop) + r);
 
 q_all = sum(puffs)./(sum(puffs)+sum(stop));
 
 like_balloon_stop = puffs.*log(q_stop) + stop.*log(1-q_stop);
 
 LL_stop = sum(like_balloon_stop);
 
 like_balloon_all = puffs.*log(q_all) + stop.*log(1-q_all);
 
 LL_all = sum(like_balloon_all);
 
