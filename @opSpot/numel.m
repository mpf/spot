function n = numel(op)
%NUMEL  Number of elements in matrix form of operator.

%   Copyright 2009, Ewout van den Berg and Michael P. Friedlander
%   See the file COPYING.txt for full copyright information.
%   Use the command 'spot.gpl' to locate this file.
   
%   http://www.cs.ubc.ca/labs/scl/spot

n = prod(size(op));

