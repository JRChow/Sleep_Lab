function [minxout, minfout, minflag] = minFinder(xin, fin, flagin)

    [minVal, indVal] = min(fin);
    minfout = minVal;
    minxout = xin(indVal,:);
    minflag = flagin(indVal);