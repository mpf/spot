classdef opLU < opFactorization
%opLU    Operator representing the LU factorization of a
%        matrix with optional iterative refinement. If the matrix
%        is known to be symmetric, opLDL will be more efficient.
%        If in addition, the matrix is known to be definite,
%        opChol will be more efficient.
%
%   opLU(A) creates an operator for multiplication by the (pseudo-)
%   inverse of the matrix A implicitly represented by its LU
%   factorization. Optionally, iterative refinement is performed.
%   Note that A is an explicit matrix.
%
%   The following attributes may be changed by the user:
%    * nitref : the maximum number of iterative refinement steps (3)
%    * itref_tol : iterative refinement tolerance (1.0e-8)
%    * force_itref : force iterative refinement (false)
%
%   See also lu.
%
%   Dominique Orban <dominique.orban@gerad.ca>, 2014.
%
%   Copyright 2009, Ewout van den Berg and Michael P. Friedlander
%   See the file COPYING.txt for full copyright information.
%   Use the command 'spot.gpl' to locate this file.

%   http://www.cs.ubc.ca/labs/scl/spot

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Properties
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  properties( SetAccess = private )
    P             % Permutation operator
    Q             % Permutation operator
    L             % Lower triangular factor
    U             % Upper triangular factor
  end

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Methods - Public
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  methods

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % opLU. Constructor
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function op = opLU(A)
      if nargin ~= 1
        error('Invalid number of arguments.');
      end

      [m,n] = size(A);

      % Construct operator
      op = op@opFactorization('LU', m, n);
      B  = A;
      if ~issparse(A)
       B           = sparse(A);
      end
      op.A         = opMatrix(B);
      [L, U, p, q] = lu(B, 'vector');
      op.L         = opMatrix(L);
      op.U         = opMatrix(U);
      op.P         = opPermutation(p);
      op.Q         = opPermutation(q);
      op.Ainv      = op.Q' * inv(op.U) * inv(op.L) * op.P;
      op.cflag     = ~isreal(A);
    end % function opLU

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % transpose
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function opOut = transpose(op)
       opOut = op.P' * inv(op.L.') * inv(op.U.') * op.Q;
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % conj
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function opOut = conj(op)
       opOut = op.Q' * inv(conj(op.U)) * inv(conj(op.L)) * op.P;
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % ctranpose
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function opOut = ctranspose(op)
       opOut = op.P' * inv(op.L') * inv(op.U') * op.Q;
    end

  end % methods - public

end % classdef
