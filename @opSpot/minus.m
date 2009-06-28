function y = minus(A,B)

%   Copyright 2009, Ewout van den Berg and Michael P. Friedlander
%   http://www.cs.ubc.ca/labs/scl/sparco
%   $Id$

if nargin ~= 2
   error('Exactly two operators must be specified.')
end

y = opMinus(A,B);
