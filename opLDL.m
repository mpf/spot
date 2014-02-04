classdef opLDL < opFactorization
%OPLDL   Operator representing the LDL factorization of a symmetric
%        matrix with optional iterative refinement. Only the lower
%        triangle of the input matrix is referenced. This is currently
%        only available for real matrices. If the matrix
%        is known to be definite, opChol will be more efficient.
%
%   opLDL(A) creates an operator for multiplication by the
%   inverse of the matrix A implicitly represented by its LDL
%   factorization. Optionally, iterative refinement is performed.
%   Note that A is an explicit matrix.
%
%   The following attributes may be changed by the user:
%    * nitref : the maximum number of iterative refinement steps (3)
%    * itref_tol : iterative refinement tolerance (1.0e-8)
%    * force_itref : force iterative refinement (false)
%
%   See also ldl.
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
    L             % Lower triangular factor
    D             % Diagonal factor
  end

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Methods - Public
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  methods

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % opLDL. Constructor
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function op = opLDL(A)
      if nargin ~= 1
        error('Invalid number of arguments.');
      end

      % Get size of input matrix
      n = size(A,1);
      if n ~= size(A,2)
        error('Input matrix must be square.');
      end

      % Construct operator
      op = op@opFactorization('LDL', n, n);
      B  = A;
      if ~issparse(A)
       B             = sparse(A);
      end
      op.A            = opHermitian(B);
      [op.L, op.D, p] = ldl(tril(B), 'vector');
      op.P            = opPermutation(p);
      op.Ainv         = op.P * inv(op.L') * inv(op.D) * inv(op.L) * op.P';
      op.cflag        = ~isreal(A);
    end % function opLDL

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % transpose
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function opOut = transpose(op)
       opOut = op;
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % conj
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function opOut = conj(op)
       opOut = op;
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % ctranpose
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function opOut = ctranspose(op)
       opOut = op;
    end

  end % methods - public

end % classdef
