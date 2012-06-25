function x = mldivide(A,B)
%\  Backslash or left matrix divide.
%
%   X = A\B is similar to Matlab's backslash operator. If A is a Spot
%   operator and B is a vector, then in general X is computed as the solution to the
%   least-squares problem
%
%   (*)  minimize  ||Ax - b||_2.
%
%   However, some Spot operators implement their own mldivide routines
%   that determine exactly how a solution to (*) is obtained.  For
%   example, the orthogonal operators (e.g., opWavlet) obtain X via
%   A'*b.
%
%   If A is a scalar and B is a spot operator, then X = opFoG(1/A,B).
%
%   The least-squares problem (*) is solved using LSQR with default
%   parameters specified by spotparams.
%
%   See also opSpot.mrdivide, opFoG, opPInverse, spotparams.

%   Copyright 2009, Ewout van den Berg and Michael P. Friedlander
%   See the file COPYING.txt for full copyright information.
%   Use the command 'spot.gpl' to locate this file.
   
%   http://www.cs.ubc.ca/labs/scl/spot

% Note that either A or B must be belong to the opSpot class because this
% function gets called for both M\C, C\M, where C is the class and M is a
% matrix or vector. This gives the following options, with s for scalar and
% C for any instance of an opSpot:
%
% 1) M\C
% 2) C\M
% 3) s\C
% 4) C\C (where both are Spot classes)
% TODO: What if one of the classes in 5 is not a Spot class?

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Mode 1: M\C
% Mode 3: s\C - Here we also handle the special case where C is 1-by-M.
%               If so, then we recast this as (C'*s)', which results in
%               a call to the "usual" matrix-vector product.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if isnumeric(A)
   if isscalar(A)
      % s\C (mode 3).  NOTE: if B is a row vector, then the mtimes
      % routine will ensure that the following product evaluates to a
      % double row-vector. Otherwise, the results is a scaled operator
      % via opFoG.
      x = (1/double(A)) * B;
   else
      % M\C (mode 1).
      if size(A,1) ~= size(B,1)
         error('Matrix dimensions must agree.');
      end
      
      % Pre-allocate result matrix
      x = zeros(size(A,2),size(B,2));
      
      ej = zeros(size(B,2),1);
      for j=1:size(B,2)
          ej(j) = 1;
          x(:,j) = A \ (B * ej);
          ej(j) = 0;
      end
   end
      
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Mode 2: C\M
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
elseif isnumeric(B)
   if size(A,1) ~= size(B,1)
      error('Matrix dimensions must agree.');
   end
   
   % Pre-allocate result matrix and apply mldivide to each column
   x = zeros(size(A,2),size(B,2));
   for j=1:size(B,2)
      x(:,j) = A.divide(B(:,j),1);
   end
   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Mode 4: Both args are Spot ops.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
else
   x = pinv(A) * B;
end
