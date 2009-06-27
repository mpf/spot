%opGaussian   Gaussian ensemble
%
%   opGaussian(M,N,MODE) creates an M-by-N Gaussian ensemble
%   operator. The parameter MODE controls the types of ensemble that
%   is generated.  If MODE isn't specified, than the default is
%   MODE=0 unless the overall memory requred exceeds 50 MB.
%
%   MODE = 0: generates an explicit unnormalized matrix from
%   the Normal distribution. The overall storage is O(M*N).
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
%   MODE = 4: generates an explicit matrix with orthonormal rows.
%   This mode requires M <= N.

%   Copyright 2009, Ewout van den Berg and Michael P. Friedlander
%   http://www.cs.ubc.ca/labs/scl/sparco
%   $Id: opGaussian.m 39 2009-06-12 20:59:05Z ewout78 $

classdef opGaussian < opSpot

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
       function op = opGaussian(m,n,mode)
          if nargin < 3 || isempty(mode)
             MByte = 2^20;
             reqst = 8*m*n;      % MBytes requested.
             if reqst < 10*MByte % If it's less than 10 MB,
                mode = 0;        % use explicit matrix.
             else
                mode = 1;
             end
          end

          switch (mode)
             case 0
                A  = randn(m,n);
                fun = @(x,mode) opGaussianExplicit_intrnl(A,x,mode);

             case 1
                seed = randn('state');
                for i=1:m, randn(n,1); end; % Ensure random state is advanced
                fun = @(x,mode) opGaussian_intrnl(m,n,seed,x,mode);

             case 2
                A  = randn(m,n);
                A  = A * spdiags((1./sqrt(sum(A.*A)))',0,n,n);
                fun = @(x,mode) opGaussianExplicit_intrnl(A,x,mode);

             case 3
                seed = randn('state');
                scale = zeros(1,n);
                for i=1:n
                   v = randn(m,1);
                   scale(i) = 1 / sqrt(v'*v);
                end
                fun = @(x,mode) opGaussianScaled_intrnl(m,n,seed,scale,x,mode);

             case 4
                if m > n
                   error('This mode is not supported when M > N.');
                end;
                A  = randn(n,m);
                [Q,R] = qr(A,0);
                fun = @(x,mode) opGaussianExplicit_intrnl(Q,x,mode);

             case 5 % Not documented.
               if m > n
                  error('This mode is not supported when M > N.');
               end;
               A  = randn(m,n);
               A  = orth(A')';
               fun = @(x,mode) opGaussianExplicit_intrnl(A,x,mode);

             otherwise
                error('Invalid mode.')
          end

          % Construct operator
          op = op@opSpot('Gaussian', m, n);
          op.funHandle = fun;
       end % Constructor

    end % Methods
       
 
    methods ( Access = protected )
       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       % Multiply
       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       function y = multiply(op,x,mode)
          y = op.funHandle(x,mode);
       end % Multiply          

    end % Methods
   
end % Classdef


%=======================================================================


function y = opGaussian_intrnl(m,n,seed,x,mode)

% Store current random number generator state
seed0 = randn('state');
randn('state',seed);

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
randn('state',seed0);
end

%=======================================================================

function y = opGaussianScaled_intrnl(m,n,seed,scale,x,mode)

% Store current random number generator state
seed0 = randn('state');
randn('state',seed);

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
randn('state',seed0);
end

%=======================================================================

function y = opGaussianExplicit_intrnl(A,x,mode)
if mode ==1
   y = A*x;
else
   y = A'*x;
end
end