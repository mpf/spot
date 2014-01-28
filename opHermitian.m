classdef opHermitian < opSpot
%opHermitian   Convert a numeric matrix stored as its lower triangle
%              into a Spot operator.
%
%   opHermitian(A,DESCRIPTION) creates a hermitian operator that performs
%   matrix-vector multiplication with matrix A. Only the lower triangle of
%   the input matrix need to be stored. The optional parameter
%   DESCRIPTION can be used to override the default operator name when
%   printed.

%   Copyright 2009, Ewout van den Berg and Michael P. Friedlander
%   See the file COPYING.txt for full copyright information.
%   Use the command 'spot.gpl' to locate this file.

%   http://www.cs.ubc.ca/labs/scl/spot

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Properties
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    properties (SetAccess = private)
        matrix = {}; % Underlying matrix
        L = false;   % Factors are only computed if \ is used
        D = false;
        P = false;
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Methods
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    methods

       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       function op = opHermitian(A, description)
       %opHermitian  Constructor.
          if nargin < 1
             error('At least one argument must be specified.')
          end
          if nargin > 2
             error('At most two arguments can be specified.')
          end

          % Check if input is a matrix
          if ~(isnumeric(A) || issparse(A))
             error('Input argument must be a sparse matrix.');
          end
          if size(A,1) ~= size(A,2)
            error('Input matrix must be square.');
          end

          % Check description parameter
          if nargin < 2, description = 'Hermitian'; end

          % Create object
          op = op@opSpot(description, size(A,1), size(A,2));
          op.cflag  = ~isreal(A);
          op.sweepflag  = true;
          op.matrix = tril(A);
       end % function opHermitian
       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       function str = char(op)
       %char  Create character array from operator.
          if isscalar(op)
             v = op.matrix;
             str = strtrim(evalc('disp(v)'));
          else
             str = char@opSpot(op);
          end
       end % function char
       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       function x = double(op)
       %double  Convert operator to a double.
          x = op.matrix + tril(op.matrix, -1)';
       end
       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    end % Methods

    methods ( Access = protected )

       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       function y = multiply(op,x,mode)
       %multiply  Multiply operator with a vector.
            y = op.matrix * x;
            y = y + (x' * tril(op.matrix, -1))';
       end % function multiply

       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       function x = divide(op,b,mode)
       %divide  Solve a linear system with the operator.
          if ~op.L || ~op.D || ~op.P
              % ldl only accesses the lower triangle.
              [op.L, op.D, op.P] = ldl(op.matrix);
          end
          x = op.P * (op.L' \ (op.D \ (op.L \ (op.P' * b))));
       end % function divide
       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  end % methods

end % Classdef
