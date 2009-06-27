function y = plus(A,B)

%   Copyright 2009, Ewout van den Berg and Michael P. Friedlander
%   http://www.cs.ubc.ca/labs/scl/sparco
%   $Id: plus.m 7 2008-07-21 01:14:08Z ewout78 $

if nargin ~= 2
   error('Exactly two operators must be specified.')
end

y = opSum(A,B);
