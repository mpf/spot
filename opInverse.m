%opInverse   (Pseudo) inverse of operator
%
%   OP = opInverse(A) creates the (pseudo) inverse of M x N
%   operator A. When applied, as in x = A * b, it calls the LSQR
%   algorithm by Paige and Saunders to solve:
%
%                  minimize ||Ax - b||_2.
%
%   When the inverses below exist, the operator is equivalent to
%
%      M = N,  OP = (A)^-1
%      M < N,  OP = A' * (A * A')^-1
%      M > N,  OP = (A' * A)^-1 * A'

%   For more information see:
%
%   [1] C. C. Paige and M. A. Saunders (1982a), LSQR: An algorithm
%       for sparse linear equations and sparse least squares, ACM
%       TOMS 8(1), 43-71.
%   [2] C. C. Paige and M. A. Saunders (1982b), Algorithm 583.
%       LSQR: Sparse linear equations and least squares problems,
%       ACM TOMS 8(2), 195-209.

%   Copyright 2009, Ewout van den Berg and Michael P. Friedlander
%   http://www.cs.ubc.ca/labs/scl/sparco
%   $Id$

classdef opInverse < opSpot

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Methods
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    methods

       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       % Constructor
       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       function op = opInverse(A)
          
          if nargin ~= 1
             error('Exactly one operator must be specified.')
          end
           
          % Input matrices are immediately cast as opMatrix's.
          if isa(A,'numeric'), A = opMatrix(A); end
          
          % Check that the input operators are valid.
          if ~isa(A,'opSpot')
             error('Input operator is not valid.')
          end
          
          % Check operator consistency and complexity
          [m, n] = size(A);
          op = op@opSpot('Inverse', n, m);
          op.cflag      = A.cflag;
          op.linear     = A.linear;
          op.children   = {A};
          op.precedence = 1;
       end
      
       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       % Display
       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       function str = char(op)
          str = ['inv(', char(op.children{1}) ,')'];
       end
       
    end % Methods


    methods ( Access = protected )
       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       % Multiply
       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       function y = multiply(op,x,mode)
          % Set paramters for LSQR call
          opA    = op.children{1};
          damp   = 0;
          atol   = 1e-9;
          btol   = 1e-9;
          conlim = 1e7;
          itnlim = min([20,size(opA,1),size(opA,2)]);
          show   = 0;

          % Set the function used for multiplication
          if mode == 1
             A = opA;  [m,n] = size(A);
          else
             A = opA'; [m,n] = size(A);
          end

           % Call LSQR
           y = spotLSQR(m,n, A, x, damp,atol,btol,conlim,itnlim,show);
        end % Multiply

    end % Methods
   
end % Classdef
