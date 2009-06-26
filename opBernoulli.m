%opBernoulli   Bernoulli-ensemble operator.
%
%   opBernoulli(M,N,MODE) creates an M-by-N Bernoulli-ensemble
%   operator. By setting MODE a number of different types of
%   ensemble can be generated; MODE = 0 (default) explicitly
%   creates an unnormalized matrix with random +1 and -1
%   entries. MODE = 1 generates columns of the unnormalized matrix
%   as the operator is applied. This allows for much larger
%   ensembles since the matrix is implicit. For MODE = 2,3 columns
%   are scaled to have unit Euclidean norm, when MODE = 3 the
%   matrix is implicit.

%   Copyright 2009, Ewout van den Berg and Michael P. Friedlander
%   http://www.cs.ubc.ca/labs/scl/sparco
%   $Id: opBernoulli.m 43 2009-06-16 23:54:10Z ewout78 $


classdef opBernoulli < opSpot

   
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
       function op = opBernoulli(m,n,mode)
          
          if nargin < 2
             error('At least two argument must be specified.')
          end
          if nargin > 3
             error('At most three arguments can be specified.')
          end
          if nargin < 3, mode = 0; end

          % Check type
          if ~ismember(mode,[0,1,2,3])
             error('Invalid Bernoulli type.')
          end
         
          % Create object
          op = op@opSpot('Bernoulli', m, n);
          op.precedence = 1;
          
          switch mode
             case 0
                A = 2.0 * (randn(m,n) < 0) - 1;
                fun = @(x,mode) multiplyExplicit(op,A,x,mode);
               
             case 1
                seed = randn('state');
                for i=1:m, randn(n,1); end; % Ensure random state is advanced
                fun = @(x,mode) multiplyImplicit(op,seed,1,x,mode);

             case 2
                A = (2.0 * (randn(m,n) < 0) - 1) / sqrt(m);
                fun = @(x,mode) multiplyExplicit(op,A,x,mode);
              
             case 3
                seed = randn('state');
                for i=1:m, randn(n,1); end; % Ensure random state is advanced
                fun = @(x,mode) multiplyImplicit(op,seed,1/sqrt(m),x,mode);
          end
          op.funHandle = fun;
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
          y = op.funHandle(x,mode);
       end % Multiply
    end % Methods
    
    
    methods ( Access = private )
       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       % Multiply - Explicit matrix
       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       function y = multiplyExplicit(op,A,x,mode)
          if mode == 1
             y = A * x;
          else
             y = A' * x;
          end
       end % Multiply explicit

       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       % Multiply -  Implicit
       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       function y = multiplyImplicit(op,seed,scale,x,mode)
          % Store current random number generator state
          seed0 = randn('state');
          randn('state',seed);

          if mode == 1
             y = zeros(op.m,1);
             for i=1:op.n
                v = 2.0 * (randn(op.m,1) < 0) - 1;
                y = y + v * x(i);
             end
          else
             y = zeros(op.n,1);
             for i=1:op.n
                v    = 2.0 * (randn(1,op.m) < 0) - 1;
                y(i) = v * x;
             end
          end
          
          % Apply scaling
          if scale ~= 1, y = y * scale; end

          % Restore original random number generator state
          randn('state',seed0);
       end % Multiply implicit
       
    end % Methods
    
end % Classdef
