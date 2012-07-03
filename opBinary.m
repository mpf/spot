classdef opBinary < opSpot
%OPBINARY   Binary (0/1) ensemble.
%
%   opBinary(M,N) creates an M-by-N binary-ensemble operator.
%
%   opBinary(M) creates a square M-by-M binary-ensemble.
%
%   opGaussian(M,N,MODE) is the same as above, except that the
%   parameter MODE controls the type of ensemble that is generated.
%   The default is MODE=0 unless the overall memory requred exceeds 50
%   MBs.
%
%   MODE = 0 (default): generates an explicit matrix with O(M*N)
%   storage.
%
%   MODE = 1: generates columns of the matrix as the operator is
%   applied. This allows for much larger ensembles because the matrix
%   is stored implicitly. The overall storage is O(M).

%   Copyright 2009, Ewout van den Berg and Michael P. Friedlander
%   See the file COPYING.txt for full copyright information.
%   Use the command 'spot.gpl' to locate this file.

%   http://www.cs.ubc.ca/labs/scl/spot

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Properties
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    properties( Access = private )
       matrix         % storage for explicit matrix (if needed)
    end % properties

    properties( SetAccess = private, GetAccess = public )
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
       function op = opBinary(m,n,mode)
          
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
          op = op@opSpot('Binary', m, n);
          op.mode = mode;
          [m,n] = size(op);

          switch mode
             case 0
                op.matrix  = double(randn(m,n) < 0);
               
             case 1
                op.seed = rng;
                for i=1:m, randn(n,1); end; % Ensure random state is advanced
                
            otherwise
                error('Invalid mode.')
          end
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

    end % methods - public

    methods ( Access = protected )
       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       % Multiply
       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       function y = multiply(op,x,mode)
          if ~isempty(op.matrix)
             % Explicit matrix
             if mode == 1
                y = op.matrix * x;
             else
                y = op.matrix' * x;
             end
          else
             % Store current random number generator state
             seed0 = rng;
             rng(op.seed);
             m = op.m; n = op.n;

             % Multiply
             if mode == 1
                y = zeros(m,1);
                for i=1:n
                   v = 1.0 * (randn(m,1) < 0);
                   y = y + v * x(i);
                end
             else
                y = zeros(n,1);
                for i=1:n
                   v    = 1.0 * (randn(1,m) < 0);
                   y(i) = v * x;
                end
             end

             % Restore original random number generator state
             rng(seed0);
          end
       end % Multiply

    end % methods - protected
   
end % classdef
