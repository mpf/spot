function e = end(A,k,idxcount)
%END   returns maximum index
%
%   E = END(OP,K,IDXCOUNT) returns the maximum index of operator
%   OP in dimension K. When IDXCOUNT equals one argument K is
%   ignored and the product of number of rows and columns of OP is
%   returned.

%   Copyright 2009, Ewout van den Berg and Michael P. Friedlander
%   http://www.cs.ubc.ca/labs/scl/sparco
%   $Id$

% Get operator size
[m,n] = size(A);

% Get maximum index in given direction
if idxcount == 1
   e = m*n;
else
   if k == 1
      e = m;
   elseif k == 2
      e = n;
   else
      e = 1;
   end   
end
