%opUnaryMinus   Negation of an operator.
%
%   opUnaryMinus(OP) returns -OP.
%
%   See also opSum, opMinus.

%   Copyright 2009, Ewout van den Berg and Michael P. Friedlander
%   http://www.cs.ubc.ca/labs/scl/sparco
%   $Id$

classdef opUnaryMinus < opSpot

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Methods
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    methods

       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       % Constructor
       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       function op = opUnaryMinus(A)
          
          if nargin ~= 1
             error('Exactly one operator must be specified.')
          end
           
          % Input matrices are immediately cast as opMatrix's.
          if isa(A,'numeric'), A = opMatrix(A); end
          
          % Check that the input operators are valid.
          if ~isa(A,'opSpot')
             error('Input operator is not valid.')
          end
          
          % Constuct operator
          [m, n] = size(A);
          op = op@opSpot('UnaryMinus', n, m);
          op.cflag      = A.cflag;
          op.linear     = A.linear;
          op.children   = {A};
          op.precedence = 2;
       end % Constructor
      
       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       % Display
       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       function str = char(op)
          op1 = op.children{1};
          str = char(op1);
          if op1.precedence > op.precedence
             str = ['(', str, ')'];
          end
          str = ['-', str];
       end % Char
       
    end % Methods


    methods ( Access = protected )
       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       % Multiply
       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       function y = multiply(op,x,mode)
           y = -1 * apply(op.children{1},x,mode);
       end % Multiply

    end % Methods
   
end % Classdef
