function y = mpower(A,B)
%^   Matrix power.
%
%   A^y is A to the y power.
%
%   See also opPower.

%   Copyright 2009, Ewout van den Berg and Michael P. Friedlander
%   See the file COPYING.txt for full copyright information.
%   Use the command 'spot.gpl' to locate this file.
   
%   http://www.cs.ubc.ca/labs/scl/spot

if size(A,1) ~= size(A,2)
   error('Operator must be square.');
end
if ~isscalar(B)
   error('Exponent must be a scalar.');
end

if isnumeric(A) || issparse(A)
   y = A ^ double(B);
elseif isa(A,'opSpot')
   y = opPower(A,double(B));
else
   error('Invalid parameters to mpower.');
end
