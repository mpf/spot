classdef opRestriction < opSpot
%OPRESTRICTION   Restriction operator.
%
%   opRestriction(N,IDX) creates a restriction operator that selects
%   the entries listed in the index vector IDX from an input vector of
%   length N. The adjoint of the operator creates a zero vector of
%   length N and fills the entries given by IDX with the input data.
%
%   Algebraically, opRestriction(N,IDX) is equivalent to a matrix of
%   size length(IDX)-by-N, where row i has a single 1 in column
%   IDX(i).
%
%   See also opMask.

%   Copyright 2009, Ewout van den Berg and Michael P. Friedlander
%   See the file COPYING.txt for full copyright information.
%   Use the command 'spot.gpl' to locate this file.

%   http://www.cs.ubc.ca/labs/scl/spot

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Properties
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    properties (SetAccess = private)
       funHandle = []; % Multiplication function
    end % Properties


    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Methods
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    methods

       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       % Constructor
       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       function op = opRestriction(n,idx)
          if nargin ~= 2
             error('Exactly two operators must be specified.')
          end
           
          idx = full(idx(:));

          if islogical(idx)
             if length(idx) > n
                error('Index exceeds operator dimensions.');
             else
                m = sum(idx);
             end
          elseif spot.utils.isposintmat(idx) || isempty(idx)
             if ~isempty(idx) && (max(idx) > n)
                error('Index exceeds operator dimensions.');
             else
                m = length(idx);
             end
          else
             error('Subscript indices must either be real positive integers or logicals.');
          end

          % -----------------------------------------------------------
          % If the indices are unique we can use the direct indexing
          % method for the conjugate operation; otherwise need to
          % construct sparse indexing matrix. The reason behind this
          % is that using y(idx) = x sequentially sets the y(idx(i)),
          % overwriting old results when needed, instead of
          % aggregating them.
          % -----------------------------------------------------------
          if islogical(idx) || (length(idx) == length(unique(idx)))
             fun = @(x,mode) opRestriction_intrnl(n,idx,x,mode);
          else
             P   = sparse(n,length(idx));
             P((0:length(idx)-1)'*n + idx) = 1;
             fun = @(x,mode) opRestrictionP_intrnl(n,idx,P,x,mode);
          end

          % Construct operator
          op = op@opSpot('Restriction', m, n);
          op.funHandle = fun;
       end % Constructor

    end % Methods
       
 
    methods ( Access = protected )
       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       % Multiply
       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       function y = multiply(op,x,mode)
          y = op.funHandle(x,mode);
       end % Multiply          

    end % Methods
   
end % Classdef


%=======================================================================


function y = opRestriction_intrnl(n,idx,x,mode)
if mode == 1
   y = x(idx);
else
   y = zeros(n,1);
   y(idx) = x;
end
end

%======================================================================

function y = opRestrictionP_intrnl(n,idx,P,x,mode)
if mode == 1
   y = x(idx);
else
   y = P * x;
end
end