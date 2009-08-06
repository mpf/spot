classdef opConj < opSpot
%opConj   Take the elementwise conjugate of a complex operator.
%
%   opConj(OP) is the elementwise complex conjugate of operator
%   OP. Applying OPCONJ to conjugate operators returns the original
%   operator.
%
%   See also opImag, opReal.

%   Copyright 2009, Ewout van den Berg and Michael P. Friedlander
%   http://www.cs.ubc.ca/labs/scl/spot

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Methods
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    methods

       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       % Constructor
       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       function op = opConj(A)
          
          if nargin ~= 1
             error('Exactly one operator must be specified.')
          end
           
          % Input matrices are immediately cast as opMatrix's.
          if isa(A,'numeric'), A = opMatrix(A); end
          
          % Check that the input operators are valid.
          if ~isa(A,'opSpot')
             error('Input operator is not valid.')
          end
          
          % Construct operator
          [m, n] = size(A);
          op = op@opSpot('Conj', m, n);
          op.cflag      = A.cflag;
          op.linear     = A.linear;
          op.children   = {A};
       end % Constructor
      
       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       % Display
       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       function str = char(op)
          op1 = op.children{1};
          str = ['Conj(', char(op1), ')'];
       end % Char
      
    end % Methods


    methods( Access = protected )
       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       % Multiply
       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       function y = multiply(op,x,mode)
           if mode == 1
              y = conj(apply(op.children{1},conj(x),1));
           else
              y = conj(apply(op.children{1},conj(x),2));
           end
       end % Multiply

    end % Methods
   
end % Classdef
    

