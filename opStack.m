classdef opStack < opSpot
%OPSTACK  Stack of vertically concatenated operators.
%
%   opStack(WEIGHTS, OP1, OP2, ...) creates a stacked
%   operator consisting of the vertical concatenation of all
%   operators;
%
%               [WEIGHT1*OP1
%                WEIGHT2*OP2
%                   ...
%                WEIGHTn*OPn]
%
%   If the same weight is to be applied to each operator, set
%   WEIGHTS to a scalar. When WEIGHTS is empty [], it is set to
%   one. The WEIGHT parameter can be omitted as long as OP1 is not
%   a vector of length (n-1); in which case there is no way to
%   decide whether it is a weight vector or operator.
%
%   See also opDictionary, opFoG, opSum.

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
       function op = opStack(varargin)
          % Checks weights parameter
          if ~isnumeric(varargin{1})
             weights = ones(nargin,1);
             opList = varargin;
          else
             weights = varargin{1};
             if isempty(weights), weights = 1; end;
             [m,n] = size(weights);
             if (((m == 1) && (n == nargin-1)) || ...
                 ((n == 1) && (m == nargin-1)) || ...
                 ((m == 1) && (n == 1)))
               weights = ones(nargin-1,1).*weights(:); 
               opList = varargin(2:end);
             else
               weights = ones(nargin,1);
               opList = varargin;
             end
          end

          % Check number of operators
          if (length(opList) < 1)
            error('At least one operator must be specified.');
          end

          % Convert all arguments to operators
          for i=1:length(opList)
             if ~isa(opList{i},'opSpot') 
                opList{i} = opMatrix(opList{i});
             end
          end

          % Check operator consistency and complexity
          opA    = opList{1};
          [m,n]  = size(opA);
          cflag  = ~isreal(opA);
          linear = opA.linear;
          for i=2:length(opList)
             opA    = opList{i};
             cflag  = cflag  | ~isreal(opA); % Update complexity information
             linear = linear & opA.linear;
   
             % Generate error if operator sizes are incompatible
             if (size(opA,2) ~= n) && ~isempty(opA)
               error('Operator %d is not consistent with the previous operators.',i);
             end

             m = m + size(opA,1); % Total number of rows
          end

          % Filter out all empty operators
          opListNew = {};
          for i=1:length(opList)
            if ~isempty(opList{i})
              opListNew{end+1} = opList{i};
            end
          end
          
          % Construct operator
          op = op@opSpot('Stack', m, n);
          op.cflag      = cflag;
          op.linear     = linear;
          op.children   = opListNew;
          op.precedence = 1;
       end % Constructor
      
       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       % Display
       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       function str = char(op)
          % Initialize
          str = '[';
       
          for i=1:length(op.children)
             strOp = char(op.children{i});
             if i~=1
                str = [str, '; ', strOp];
             else
                str = [str, strOp];
             end             
          end
          
          str = [str, ']'];
       end % Display

    end % Methods
       
 
    methods ( Access = protected )
       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       % Multiply
       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       function y = multiply(op,x,mode)
          if mode == 1
             y = zeros(op.m,1);
             k = 0;
             for i=1:length(op.children)
                child      = op.children{i};
                s          = size(child,1);
                y(k+(1:s)) = applyMultiply(child, x, 1);
                k          = k + s;
             end;
          else
             y = zeros(op.n,1);
             k = 0;
             for i=1:length(op.children)
                child = op.children{i};
                s     = size(child,1);
                y     = y + applyMultiply(child, x(k+1:k+s), 2);
                k     = k + s;
             end
          end
       end % Multiply          

    end % Methods
   
end % Classdef
