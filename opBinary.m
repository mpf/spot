%opBinary   Binary (0/1) ensemble
%
%   OP = opBinary(M,N,MODE) creates an M by N binary ensemble
%   operator. When choosing MODE = 0 an explicit binary matrix is
%   formed and used when applying the operator. Choosing MODE = 1
%   causes the operator to generate the above matrix on the fly,
%   each time the operator is used. This mode can be used when
%   dealing with very large matrices.

%   Copyright 2009, Ewout van den Berg and Michael P. Friedlander
%   http://www.cs.ubc.ca/labs/scl/sparco
%   $Id$


classdef opBinary < opSpot

   
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Properties
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    properties (SetAccess = private)
        seed   = 0;  % Random state
        matrix = []; % Explicit matrix form
    end % Properties

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Methods
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    methods

       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       % Constructor
       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       function op = opBinary(m,n,mode)
          
          if nargin < 2
             error('At least two argument must be specified.')
          end
          if nargin > 3
             error('At most three arguments can be specified.')
          end
          if nargin < 3, mode = 0; end

          % Check type
          if ~ismember(mode,[0,1])
             error('Invalid Binary type.')
          end
         
          % Create object
          op = op@opSpot('Binary', m, n);
          op.precedence = 1;

          switch mode
             case 0
                op.matrix  = double(randn(m,n) < 0);
               
             case 1
                op.seed = randn('state');
                for i=1:m, randn(n,1); end; % Ensure random state is advanced
          end
       end % Constructor

       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       % Double
       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       function x = double(op)
          if ~isempty(op.matrix)
             x = op.matrix;
          else
             x = double@opSpot(op);
          end          
       end % Double

    end % Methods

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
             seed0 = randn('state');
             randn('state',op.seed);
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
             randn('state',seed0);
          end
       end % Multiply

    end % methods
   
end % Classdef
