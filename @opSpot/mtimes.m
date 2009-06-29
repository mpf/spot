function y = mtimes(A,B)

%   Copyright 2009, Ewout van den Berg and Michael P. Friedlander
%   http://www.cs.ubc.ca/labs/scl/sparco
%   $Id$

% Note that either A or B must be belong to the opSpot class because this
% function gets called for both M*C, C*M, where C is the class and M is a
% matrix or vector. This gives the following options, with s for scalar and
% C for any instance of an opSpot:
%
% 1) M*C, implemented as (C'*M')'
% 2) C*M
% 3) s*C
% 4) C*s
% 5) C*C, either of which can be a foreign class

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Mode 1: M*C
% Mode 3: s*C - Here we also handle the special case where C is 1-by-M.
%               If so, then we recast this as (C'*s)', which results in
%               a call to the "usual" matrix-vector product.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if isnumeric(A)
    if isscalar(A) && (size(B,1) ~= 1)
       % s*C (mode 3)
       y = opFoG(A,B);
    else
       % M*C (mode 1) or ((M-by-1)*scalar)'
       y = (B' * A')';
    end
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Mode 2: C*M
% Mode 4: C*s - Here we also handle the special case where C is N-by-1.
%               If so, then we recast this as (C'*s)', which results in
%               a call to the "usual" matrix-vector product.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
elseif isnumeric(B)
   if isscalar(B)
      if size(A,2) ~= 1
         % C*s (mode 4)
         y = opFoG(A,B);
      else
         y = A.apply(B,1);  % A is a column "vector".
      end
   else
      [m,n] = size(A);
      [p,q] = size(B);
   
      % Raise an error when the matrices do not commute
      if n ~= p
         error('Matrix dimensions must agree when multiplying by %s.', ...
             char(A));
      end
   
      % Preallocate y
      y = zeros(m,q);
   
      % Perform operator*vector on each column of B
      if isempty(A) % Zero rows or columns
         % Nothing to be done, result will be y
      else
         for i=1:q
            y(:,i) = A.apply(B(:,i),1);
         end
      end
      
   end   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Both args are Spot ops.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
else
    y = opFoG(A,B);
end
