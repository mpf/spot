classdef opFoG < opSpot
%OPFOG   Forms the product of two operators.
%
%   opFoG(OP1,OP2) creates an operator that successively applies each
%   of the operators OP1, OP2 on a given input vector. In non-adjoint
%   mode this is done in reverse order.
%
%   The inputs must be either Spot operators or explicit Matlab matrices
%   (including scalars).
%
%   See also opDictionary, opStack, opSum.

%   Copyright 2009, Ewout van den Berg and Michael P. Friedlander
%   See the file COPYING.txt for full copyright information.
%   Use the command 'spot.gpl' to locate this file.

%   http://www.cs.ubc.ca/labs/scl/spot

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Properties
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    properties (SetAccess = private)
        operators = {}; % List of preprocessed operators
    end % Properties

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Methods
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    methods

       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       % Constructor
       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       function op = opFoG(A,B)
          
          if nargin ~= 2
             error('Exactly two operators must be specified.')
          end
          
          % Input matrices are immediately cast as opMatrix's.
          if isa(A,'numeric'), A = opMatrix(A); end
          if isa(B,'numeric'), B = opMatrix(B); end
          
          % Check that the input operators are valid.
          if ~( isa(A,'opSpot') && isa(B,'opSpot') )
             error('One of the operators is not a valid input.')
          end
          
          % Check operator consistency and complexity
          [mA, nA] = size(A);
          [mB, nB] = size(B);
          compatible = isscalar(A) || isscalar(B) || nA == mB;
          if ~compatible
             error('Operators are not compatible in size.');
          end
          
          % Determine size
          if isscalar(A) || isscalar(B)
            m = max(mA,mB);
            n = max(nA,nB);
          else
            m = mA;
            n = nB;
          end
          
          % Construct operator
          op = op@opSpot('FoG', m, n);
          op.cflag    = A.cflag  | B.cflag;
          op.linear   = A.linear | B.linear;
          op.sweepflag= A.sweepflag & B.sweepflag;
          op.children = {A, B};
          op.precedence = 3;

          % Preprocess children
          if isscalar(A), op.children{1} = opMatrix(double(A)); end
          if isscalar(B), op.children{2} = opMatrix(double(B)); end
       end % Constructor
       
       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       % double
       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       function A = double(op)
          C1 = op.children{1};
          C2 = op.children{2};
          A  = double(C1)*double(C2);
       end
       
       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       % Display
       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       function str = char(op)
          % Get children
          op1 = op.children{1};
          op2 = op.children{2};
          
          % Format first operator
          str1 = char(op1);
          if op1.precedence > op.precedence
             str1 = ['(',str1,')'];
          end
          
          % Format second operator
          str2 = char(op2);
          if op2.precedence > op.precedence
             str2 = ['(',str2,')'];
          end
          
          % Combine
          str = [str1, ' * ', str2];
       end
    end % Methods
       
 
    methods ( Access = protected )
       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       % Multiply
       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       function z = multiply(op,x,mode)
           if mode == 1
              y = applyMultiply(op.children{2},x,mode);
              z = applyMultiply(op.children{1},y,mode);
           else
              y = applyMultiply(op.children{1},x,mode);
              z = applyMultiply(op.children{2},y,mode);
           end
        end % Multiply
       
    end % Methods
   
end % Classdef
