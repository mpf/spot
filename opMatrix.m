%opMatrix   Convert a numeric matrix into a Spot operator.
%
%   opMatrix(A,DESCRIPTION) creates an operator that performs
%   matrix-vector multiplication with matrix A. The optional parameter
%   DESCRIPTION can be used to override the default operator name when
%   printed.

%   Copyright 2009, Ewout van den Berg and Michael P. Friedlander
%   http://www.cs.ubc.ca/labs/scl/sparco
%   $Id: opMatrix.m 39 2009-06-12 20:59:05Z ewout78 $

classdef opMatrix < opSpot

   
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Properties
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    properties (SetAccess = private)
        matrix = {}; % Underlying matrix
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
          
          % Check if input is a matrix
          if ~(isnumeric(A) || issparse(A))
             error('Input argument must be a matrix.');
          end
          
          % Check description parameter
          if nargin < 2, description = 'Matrix'; end

          % Create object
          op = op@opSpot(description, size(A,1), size(A,2));
          op.cflag  = ~isreal(A);
          op.matrix = A;
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
          x = op.matrix;
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
