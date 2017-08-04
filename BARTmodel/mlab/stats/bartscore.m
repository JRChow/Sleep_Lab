function [ adjBART, medBART, stdBART, propPop ] = bartscore( pumpsIn, popIn )
%BARTSCORE calculates summary measures of performance (all based on on
%balloons which ended on stop.
%
%  adjBART = average pumps taken on stopped balloons; medBART = median no.
%  pumps taken on stopped; stdBART = standard deviation of pumps taken on
%  stopped balooon. propPop = proportion ob balloons the person popped

[br, bc] = size(popIn);

propPop = sum(popIn)./br;

bindex = find(popIn == 0);

pumpsStop = pumpsIn(bindex);


if (isempty(pumpsStop))
 adjBART = NaN;   
 stdBART = NaN;
 medBART = NaN;
else
adjBART = mean(pumpsStop);
medBART = median(pumpsStop);
stdBART = std(pumpsStop);
end;