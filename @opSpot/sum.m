function s = sum(A,dim)
%SUM Sums rows or columns of a Spot operator.
%
%   S = sum(A), for an M-by-N Spot operator A, S is a row vector with the
%   sum of elements of each column.
%
%   S = SUM(A,DIM) sums along the dimension DIM. 
%   Note that DIM must be 1 or 2.

if nargin == 0
    error('Not enough input arguments');
    
elseif nargin > 2
    error('Too many input arguments');
    
elseif nargin > 1 && ~isempty(dim)
    if ~(dim == 1 || dim == 2)
        error('Dimension argument must be 1 or 2');
    end
else
    dim = 1;
end

if dim == 1
    s = (A'*ones(A.m,1))';
else
    s = A*ones(A.n,1);
end
