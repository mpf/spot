classdef opMinus < opSpot
%OPMINUS   Difference of two operators.
%
%   opMinus(OP1,OP2) creates a compound operator representing OP1-OP2.
%
%   See also opSum.

%   Copyright 2009, Ewout van den Berg and Michael P. Friedlander
%   See the file COPYING.txt for full copyright information.
%   Use the command 'spot.gpl' to locate this file.

%   http://www.cs.ubc.ca/labs/scl/spot
   
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Methods
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    methods

       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       % Constructor
       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       function op = opMinus(A,B)
          
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
          compatible = ((mA == mB) && (nA == nB));
          if ~compatible
             error('Operators are not compatible in size.');
          end
          
          % Determine size
          m = mA; n = nA;
          
          % Construct operator
          op = op@opSpot('Minus', m, n);
          op.cflag      = A.cflag  | B.cflag;
          op.linear     = A.linear | B.linear;
          op.sweepflag  = A.sweepflag & B.sweepflag;
          op.children   = {A, B};
          op.precedence = 4;
       end % Constructor
      
       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       % Display
       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       function str = char(op)
          % Get operators
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
          str = [str1, ' - ', str2];
       end
    end % Methods


    methods ( Access = protected )
       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       % Multiply
       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       function y = multiply(op,x,mode)
           y =     applyMultiply(op.children{1},x,mode);
           y = y - applyMultiply(op.children{2},x,mode);
        end % Multiply
       
    end % Methods
   
end % Classdef
