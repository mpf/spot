classdef opKron < opSpot
%OPKRON   Kronecker tensor product.
%
%   opKron(OP1,OP2,...OPn) creates an operator that is the Kronecker
%   tensor product of OP1, OP2, ..., OPn.

%   Copyright 2009, Rayan Saab, Ewout van den Berg and Michael P. Friedlander
%   See the file COPYING.txt for full copyright information.
%   Use the command 'spot.gpl' to locate this file.

%   http://www.cs.ubc.ca/labs/scl/spot

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Methods
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    methods

       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       function op = opKron(varargin)
          %opKron  Constructor

          if nargin < 2
             error('At least two operators must be specified.')
          end

          opList = cell(1,nargin);
          for i = 1:nargin
              A = varargin{i};              
              if isa(A,'numeric')
                  % A matrix input is immediately cast as opMatrix
                  A = opMatrix(A);
              elseif ~isa(A,'opSpot')
                  error('One of the operators is not a valid input.')
              end              
              opList{i} = A;
          end
          
          % Determine operator size and complexity
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
       end % function opKron

       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       
       function str = char(op)
          %char  Construct operator string representation
          str = 'Kron(';
          for i=1:length(op.children)
              A = op.children{i};
              str = strcat(str,char(A),',');
          end
          str = str(1:end-1);    % delete superfluous comma
          str = strcat(str,')');
       end % function char
      
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


