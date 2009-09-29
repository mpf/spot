function M = double(A)
%double  Converts a Spot operator to matrix.
%
%   double(A) converts a Spot operator to an explicit matrix.

%   Copyright 2009, Ewout van den Berg and Michael P. Friedlander
%   See the file COPYING.txt for full copyright information.
%   Use the command 'spot.gpl' to locate this file.

%   http://www.cs.ubc.ca/labs/scl/spot

if size(A,1) < size(A,2)
   M = (A'*speye(size(A,1)))';
else
   M = A*speye(size(A,2));
end
