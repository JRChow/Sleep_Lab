function [sector] = ParSectors(numSectors, intervalWidth, intervalBottom)
%this function generates random "parameter values" that fall in the
%specific sectors with the specified interval width (intervalWidth) and
%starting at the specified bottom boundary (intervalBottom)

r = rand(1,numSectors);

sector = r.*intervalWidth + intervalBottom;