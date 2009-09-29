function result = isreal(A)
%ISREAL  True for real operator.
%
%   isreal(A) returns true if A is a real operator.
%
%   See also opSpot.real.

%   Copyright 2009, Ewout van den Berg and Michael P. Friedlander
%   See the file COPYING.txt for full copyright information.
%   Use the command 'spot.gpl' to locate this file.

%   http://www.cs.ubc.ca/labs/scl/spot

% Get size information
result = ~A.cflag;