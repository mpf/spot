function [p,q] = size(A,dim)
%size  Dimensions of a Spot operator.
%
%   D = size(A), for an M-by-N Spot operator A, returns the
%   two-element row vectors D = [M,N].
%
%   [M,N] = size(A) returns M and N as separate arguments.
%
%   M = size(A,DIM) retuns the length of the dimension specified by
%   the scalar DIM.  Note that DIM must be 1 or 2.

%   Copyright 2009, Ewout van den Berg and Michael P. Friedlander
%   See the file COPYING.txt for full copyright information.
%   Use the command 'spot.gpl' to locate this file.

%   http://www.cs.ubc.ca/labs/scl/spot

if nargin == 0
   error('Not enough input arguments');

elseif nargin > 2
   error('Too many input arguments');
   
elseif nargin > 1 && ~isempty('dim')
    if nargout > 1
       error('Unknown command option.');
    end
    if ~(dim == 1 || dim == 2)
       error('Dimension argument must be 1 or 2');
    else
       if dim == 1
          p = A.m;
       else
          p = A.n;
       end
    end
    
else
   if nargout < 2
      p = [A.m, A.n];
   else
      p = A.m;
      q = A.n;
   end
end
