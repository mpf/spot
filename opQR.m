classdef opQR < opFactorization
%opQR    Operator representing the QR factorization of a
%        matrix with optional iterative refinement. If the matrix
%
%   opQR(A) creates an operator for multiplication by the (pseudo-)
%   inverse of the matrix A implicitly represented by its QR
%   factorization. Optionally, iterative refinement is performed.
%   Note that A is an explicit matrix.
%
%   The following attributes may be changed by the user:
%    * nitref : the maximum number of iterative refinement steps (3)
%    * itref_tol : iterative refinement tolerance (1.0e-8)
%    * force_itref : force iterative refinement (false)
%
%   See also qr.
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
    Q             % Orthogonal operator
    R             % Lower triangular factor
  end

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Methods - Public
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  methods

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % opQR. Constructor
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function op = opQR(A)
      if nargin ~= 1
        error('Invalid number of arguments.');
      end

      % Construct operator
      [m, n] = size(A);
      op = op@opFactorization('QR', n, m);
      B  = A;
      if ~issparse(A)
        B             = sparse(A);
      end
      op.A            = opMatrix(B);
      [op.Q, op.R, p] = qr(B, 'vector');
      op.P            = opPermutation(p);
      op.Ainv         = op.P' * opPInverse(op.R) * op.Q';
      op.cflag        = ~isreal(A);
    end % function opQR

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % transpose
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function opOut = transpose(op)
       opOut = conj(op.Q) * opPInverse(op.R).' * op.P;
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % conj
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function opOut = conj(op)
       opOut = op.P' * conj(opPInverse(op.R)) * op.Q.';
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % ctranpose
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function opOut = ctranspose(op)
       opOut = op.Q * opPInverse(op.R)' * op.P;
    end

  end % methods - public

end % classdef
