%opMatrix  Convert a numeric matrix into a Spot operator.
%
%   opMatrix(A,DESCRIPTION) creates an operator that performs
%   matrix-vector multiplication with matrix or class instance
%   A. When A is a class instance it has to provide the `mtimes',
%   `size', and `isreal' methods. Optional parameter DESCRIPTION
%   can be used to override the default operator name when printed.

%   Copyright 2009, Ewout van den Berg and Michael P. Friedlander
%   http://www.cs.ubc.ca/labs/scl/sparco
%   $Id: opMatrix.m 39 2009-06-12 20:59:05Z ewout78 $

classdef opMatrix < opSpot

   
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Properties
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    properties (SetAccess = private)
        matrix = {}; % Underlying matrix or class
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Methods
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    methods

       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       % Constructor
       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%       
       function op = opMatrix(A,description)
          
          if nargin < 1
             error('At least one argument must be specified.')
          end
          if nargin > 2
             error('At most two arguments can be specified.')
          end

          % Check description parameter
          if nargin < 2, description = 'Matrix'; end

          if isnumeric(A) || issparse(A)
             % Explicit matrix
             isLinear = true;
          elseif isobject(A)
             % Check if class supplies required methods
             isCompatible = (ismethod(A,'mtimes') && ismethod(A,'size') && ...
                             ismethod(A,'isreal') && ismethod(A,'ctranspose'));
             if ~isCompatible
                error('Class object must provide mtimes, size, and isreal methods.');
             end
             
             % Set description
             if nargin < 2
                description = ['Class:',class(A)];
             end

             % Check linearity
             [m,n] = size(A);
             seed = randn('state');
             x = randn(m,1) + sqrt(-1)*randn(m,1);
             y = randn(n,1) + sqrt(-1)*randn(n,1);
             if abs((x' * (A * y)) - ((A' * x)' * y)) < 1e-14
                isLinear = true;
             else
                isLinear = false;
             end
             randn('state',seed);
          else
             error('Input argument must be a matrix or a class.');
          end

          % Create object
          op = op@opSpot(description, size(A,1), size(A,2));
          op.cflag      = ~(isreal(A));
          op.linear     = isLinear;
          op.children   = {A};
          op.precedence = 1;
          op.matrix     = A;
       end

      
       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       % Display
       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%       
       function str = char(op)
          if isscalar(op)
             v = op.matrix;
             str = evalc('disp(v)');
          else
             str = char@opSpot(op);
          end          
       end

       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       % Double
       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%       
       function x = double(op)
          if isnumeric(op) || issparse(op)
             x = op;
          else
             x = double@opSpot(op);
          end          
       end

    end % Methods


    methods ( Access = protected )
       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       % Multiply
       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       function y = multiply(op,x,mode)
           if mode == 1
              y = op.matrix * x;
           else
              y = op.matrix' * x;
           end
        end
    end % methods
   
end
    

