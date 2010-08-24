classdef opInverse < opSpot
%OPINVERSE   (Pseudo) inverse of operator.
%
%   Ainv = opInverse(A) creates the (pseudo) inverse of a square operator.
%   The product Ainv*b is then equivalent to A\b.
%
%   See also @opSpot/mldivide.

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
 
          % Check operator size
          [m, n] = size(A);
          if m ~= n
             error('Operator must be square.');
          end
          
          % Construct operator
          op = op@opSpot('Inverse', n, m);
          op.cflag      = A.cflag;
          op.linear     = A.linear;
          op.sweepflag  = A.sweepflag;
          op.children   = {A};
       end % function opInverse
      
       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       % Display
       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       function str = char(op)
          str = ['inv(', char(op.children{1}) ,')'];
       end % function char
       
       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       % Inv
       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       function opOut = inv(op)
          opOut = op.children{1};
       end % function inv
       
    end % methods - public


    methods ( Access = protected )
       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       % Multiply
       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       function y = multiply(op,x,mode)
          opA    = op.children{1};
          if mode == 1
             A = opA;
          else
             A = opA';
          end
           y = A\x;
        end % function multiply

    end % methods - protected
   
end % classdef
