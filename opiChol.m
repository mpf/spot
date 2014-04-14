classdef opiChol < opFactorization
%opiChol   Operator representing the incomplete Cholesky factorization of a
%          symmetric and definitematrix with optional iterative refinement.
%
%   opiChol(A) creates an operator for multiplication by an approximate
%   inverse of the matrix A implicitly represented by its incomplete
%   Cholesky factorization. Optionally, iterative refinement is performed.
%   Note that A is an explicit matrix.
%
%   Additional input arguments are passed directly to ichol() with the
%   exception of the 'shape' attribute.
%
%   The following attributes may be changed by the user:
%    * nitref : the maximum number of iterative refinement steps (3)
%    * itref_tol : iterative refinement tolerance (1.0e-8)
%    * force_itref : force iterative refinement (false)
%
%   See also ichol.
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
    L             % Lower triangular incomplete factor
  end

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Methods - Public
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  methods

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % opiChol. Constructor
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function op = opiChol(A, varargin)

      [m,n] = size(A);
      if m ~= n
        error('Input matrix must be square');
      end

      % Construct operator
      op = op@opFactorization('iChol', n, n);
      B  = A;
      if ~issparse(A)
       B           = sparse(A);
      end
      op.A         = opMatrix(B);
      if nargin > 1
        opts = varargin{1};
      end
      opts.shape   = 'lower';
      op.L         = opMatrix(ichol(B, opts));
      op.Ainv      = inv(op.L') * inv(op.L);
      op.cflag     = ~isreal(A);
    end % function opiChol

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % transpose
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function opOut = transpose(op)
       opOut = inv(op.L.') * inv(op.L);
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % conj
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function opOut = conj(op)
       opOut = inv(conj(op.L')) * inv(conj(op.L));
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % ctranpose
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function opOut = ctranspose(op)
       opOut = op.Ainv;
    end

  end % methods - public

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Methods - Protected
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  methods( Access = protected )

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % divide
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function x = divide(op, b, mode)
       x = op.L * (op.L' * b);  % Not the same as op.A * b.
    end % function divide

  end % methods - protected

end % classdef
