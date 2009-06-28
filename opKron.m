%opKron   Kronecker tensor product
%
%   opKron(OP1,OP2,...OPn) creates an operator that is the Kronecker
%   tensor product of OP1, OP2, ..., OPn.

%   Copyright 2009, Rayan Saab, Ewout van den Berg and Michael P. Friedlander
%   http://www.cs.ubc.ca/labs/scl/sparco
%   $Id$

classdef opKron < opSpot


    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Methods
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    methods

       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       % Constructor
       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       function op = opKron(A,B)
          
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
          
          % Determine operator size and complexity (this code is
          % general for any number of operators)
          opList = {A,B};
          opA    = opList{1};
          [m,n]  = size(opA);
          cflag  = opA.cflag;
          linear = opA.linear;
          for i=2:length(opList)
             opA    = opList{i};
             cflag  = cflag  | opA.cflag;
             linear = linear & opA.linear;
             [mi,ni]= size(opA);
             m = m * mi; n = n * ni;
          end
          
          % Construct operator
          op = op@opSpot('Kron', m, n);
          op.cflag    = cflag;
          op.linear   = linear;
          op.children = opList;
       end % Constructor


       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       % Display
       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       function str = char(op)
          % Get operators
          op1 = op.children{1};
          op2 = op.children{2};
          str = ['Kron(',char(op1),', ',char(op2),')'];
       end % Char
      
    end % Methods
       
 
    methods ( Access = protected )
       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       % Multiply
       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       function y = multiply(op,x,mode)
          opList = op.children;
          [m,n]  = size(op);
          if mode == 1
             for i=length(opList):-1:1
                k = size(opList{i},2);
                x = reshape(x,k,n/k);
                z = opList{i} * x;
                x = z.';
                n = size(opList{i},1) * n / k;
             end
             y = x(:);
          else
             for i=length(opList):-1:1
                k = size(opList{i},1);
                x = reshape(x,k,m/k);
                z = opList{i}' * x;
                x = z.';
                m = size(opList{i},2) * m / k;
             end
             y = x(:);  
          end
       end % Multiply

    end % Methods
   
end % Classdef


