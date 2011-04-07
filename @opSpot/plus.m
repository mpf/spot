function y = plus(A,B)
%+   Sum of two operators.
%
%   See also opSum, opSpot.minus.

%   Copyright 2009, Ewout van den Berg and Michael P. Friedlander
%   See the file COPYING.txt for full copyright information.
%   Use the command 'spot.gpl' to locate this file.

%   http://www.cs.ubc.ca/labs/scl/spot

if isa(B,'dataContainer') % Please see DataContainerInfo.md
    y = plus(B,A,'swap');
else

if nargin ~= 2
   error('Exactly two operators must be specified.')
end
if isscalar(A)
   A = A*opOnes(size(B));
end
if isscalar(B)
   B = B*opOnes(size(A));
end
y = opSum(A,B);

end % else