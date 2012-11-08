classdef opBernoulli < opSpot
%OPBERNOULLI   Bernoulli-ensemble operator.
%
%   opBernoulli(M,N) creates an M-by-N Bernoulli ensemble, a matrix
%   with iid +1/-1 entries.
%
%   opBernoulli(M) creates a square M-by-M Bernoulli ensemble.
%
%   opBernoulli(M,N,MODE) is the same as above, except that the
%   parameter MODE controls the type of ensemble that is generated.
%   The default is MODE=0 unless the overall memory requred exceeds 50
%   MBs.
%
%   MODE = 0 (default): generates an explicit unnormalized matrix with
%   random +1/-1 entries. The overall storage is O(M*N).
%
%   MODE = 1: generates columns of the unnormalized matrix as the
%   operator is applied. This allows for much larger ensembles since
%   the matrix is implicit. The overall storage is O(M).
%
%   MODE = 2: generates a scaled explicit matrix with unit-norm
%   columns.
%
%   MODE = 3: same as MODE=2, but the matrix is implicit (see MODE=1).
%
%   Available operator properties:
%   .mode  gives the mode used to create the operator.

%   Copyright 2009, Ewout van den Berg and Michael P. Friedlander
%   See the file COPYING.txt for full copyright information.
%   Use the command 'spot.gpl' to locate this file.

%   http://www.cs.ubc.ca/labs/scl/spot
   
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Properties
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    properties( Access = public )
       funHandle      % multiplication function
       matrix         % storage for explicit matrix (if needed)
    end % properties

    properties( SetAccess = private, GetAccess = public )
       mode           % mode used when operator was created
       seed           % RNG seed when operator was created
       scale          % used for normalization
    end % properties
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Methods
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    methods

       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       % Constructor
       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       function op = opBernoulli(m,n,mode)
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

          % Create object
          op = op@opSpot('Bernoulli', m, n);
          op.seed = rng;
          op.mode = mode;
          [m,n] = size(op);
          
          switch mode
             case 0
                A = 2.0 * (randn(m,n) < 0) - 1;
                fun = @multiplyExplicit;
               
             case 1
                A = [];
                for i=1:m, randn(n,1); end; % Ensure random state is advanced
                op.scale = 1;
                fun = @multiplyImplicit;

             case 2
                A = (2.0 * (randn(m,n) < 0) - 1) / sqrt(m);
                fun = @multiplyExplicit;
              
             case 3
                A = [];
                op.scale = 1/sqrt(m);
                for i=1:m, randn(n,1); end; % Ensure random state is advanced
                fun = @multiplyImplicit;
                
            case 4
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
       end % function double

    end % Methods

    methods ( Access = protected )
       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       % Multiply
       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       function y = multiply(op,x,mode)
          y = op.funHandle(op,x,mode);
       end % function multiply
    end % methods - protected
        
    methods ( Access = private )
       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       % Multiply - Explicit matrix
       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       function y = multiplyExplicit(op,x,mode)
          if mode == 1
             y = op.matrix * x;
          else
             y = op.matrix' * x;
          end
       end % function multiplyExplicit

       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       % Multiply -  Implicit
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
                v = 2.0 * (randn(m,1) < 0) - 1;
                y = y + v * x(i);
             end
          else
             y = zeros(n,1);
             for i=1:n
                v    = 2.0 * (randn(1,m) < 0) - 1;
                y(i) = v * x;
             end
          end
          
          % Apply scaling
          if op.scale ~= 1, y = y * op.scale; end

          % Restore original random number generator state
          rng(seed0);
       end % function multiplyImplicit
       
    end % methods - private
    
end % classdef
