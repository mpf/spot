classdef opGaussian < opSpot
%OPGAUSSIAN   Gaussian ensemble.
%
%   opGaussian(M,N) creates an M-by-N Gaussian-ensemble operator.
%
%   opGaussian(M) creates a square M-by-M Gaussian-ensemble.
%
%   opGaussian(M,N,MODE) is the same as above, except that the
%   parameter MODE controls the type of ensemble that is generated.
%   The default is MODE=0 unless the overall memory requred exceeds 50
%   MBs.
%
%   MODE = 0 (default): generates an explicit unnormalized matrix from
%   the Normal distribution. The overall storage is O(M*N).
%
%   MODE = 1: generates columns of the unnormalized matrix as the
%   operator is applied. This allows for much larger ensembles because
%   the matrix is implicit. The overall storage is O(M).
%
%   MODE = 2: generates a explicit matrix with unit-norm columns.
%
%   MODE = 3: same as MODE=2, but the matrix is implicit (see MODE=1).
%
%   MODE = 4: generates an explicit matrix with orthonormal rows.
%   This mode requires M <= N.
%
%   Available operator properties:
%   .mode  is the mode used to create the operator.
%   .seed  is the seed used to initialize the RNG.

%   Copyright 2009, Ewout van den Berg and Michael P. Friedlander
%   See the file COPYING.txt for full copyright information.
%   Use the command 'spot.gpl' to locate this file.

%   http://www.cs.ubc.ca/labs/scl/spot

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Properties
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    properties ( Access = public )
       funHandle      % multiplication function
       matrix         % storage for explicit matrix (if needed)
       scale
    end % properties

    properties ( SetAccess = private, GetAccess = public )
       mode           % Mode used when operator was created
       seed           % RNG seed when operator was created
    end % properties
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Methods
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    methods

       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       % Constructor
       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       function op = opGaussian(m,n,mode)
          if nargin < 2 || isempty(n)
             n = m;
          end
          if nargin < 3 || isempty(mode)
             MByte = 2^20;
             reqst = 8*m*n;      % MBytes requested.
             if reqst < 10*MByte % If it's less than 10 MB,
                mode = 0;        % use explicit matrix.
             else
                mode = 1;
             end
          end

          % Create object.
          op = op@opSpot('Gaussian', m, n);
          op.seed = rng;
          op.mode = mode;
          [m,n] = size(op);
          
          % Construct the internal representation
          switch mode
             case 0
                A = randn(m,n);
                fun = @multiplyExplicit;

             case 1
                A = [];
                for i=1:m, randn(n,1); end; % Ensure random state is advanced
                fun = @multiplyImplicit;

             case 2
                A  = randn(m,n);
                A  = A * spdiags((1./sqrt(sum(A.*A)))',0,n,n);
                fun = @multiplyExplicit;

              case 3
                A = [];
                op.scale = zeros(1,n);
                for i=1:n
                   v = randn(m,1);
                   op.scale(i) = 1 / sqrt(v'*v);
                end
                fun = @multiplyImplicitScaled;

             case 4
                if m > n
                   error('This mode is not supported when M > N.');
                end;
                A = randn(n,m);   % NB: dimensions are reversed
                [Q,R] = qr(A,0);
                A = Q';           % Now A has the correct shape
                fun = @multiplyExplicit;

             case 5 % Not documented.
               if m > n
                  error('This mode is not supported when M > N.');
               end;
               A  = randn(m,n);
               A  = orth(A')';
               fun = @multiplyImplicit;

             otherwise
               error('Invalid mode.')
          end
          op.matrix = A;
          op.funHandle = fun;
       end % Constructor

       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       % Double
       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       function x = double(op)
          if isempty(op.matrix)
             x = double@opSpot(op);
          else
             x = op.matrix;
          end
       end % Double

    end % Methods
       
    methods ( Access = protected )
       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       % Multiply
       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       function y = multiply(op,x,mode)
          y = op.funHandle(op,x,mode);
       end % Multiply

    end % Methods
    
    methods ( Access = private )
       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       % Multiply - Explicit matrix
       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       function y = multiplyExplicit(op,x,mode)
          if mode == 1
             y = op.matrix  * x;
          else
             y = op.matrix' * x;
          end
       end % Multiply explicit

       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       % Multiply -  Implicit (unscaled)
       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       function y = multiplyImplicit(op,x,mode)
          m = op.m;
          n = op.n;
          % Store current random number generator state
          seed0 = rng;
          rng(op.seed);
          
          if mode == 1
             y = zeros(m,1);
             for i=1:n
                 y = y + randn(m,1) * x(i);
             end
          else
             y = zeros(n,1);
             for i=1:n
                 y(i) = randn(1,m) * x;
             end
          end

          % Restore original random number generator state
          rng(seed0);
       end

       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       % Multiply -  Implicit (scaled)
       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       function y = multiplyImplicitScaled(op,x,mode)
          scale = op.scale;
          m = op.m;
          n = op.n;
          % Store current random number generator state
          seed0 = rng('default');
          rng(op.seed);

          if mode == 1
             y = zeros(m,1);
             for i=1:n
                 y = y + randn(m,1) * (scale(i) * x(i));
             end
          else
             y = zeros(n,1);
             for i=1:n
                 y(i) = scale(i) * randn(1,m) * x;
             end
          end
          
          % Restore original random number generator state
          rng(seed0);
       end
   
    end % methods - private
    
end % Classdef
