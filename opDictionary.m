%opDictionary   Dictionary of concatenated operators
%
%   opDictionary(WEIGHTS,OP1,OP2,...OPn) creates a dictionary
%   operator consisting of the concatenation of all operators;
%   [WEIGHT1*OP1 | WEIGHT2*OP2 | ... WEIGHTn*OPn]. Vector WEIGHTS
%   can be of size nx1 or 1xn. If the same weight is to be applied
%   to each operator, set WEIGHTS to a scalar. When WEIGHTS is
%   empty [], it is set to  one. The WEIGHT parameter can be
%   omitted as long as OP1 is not a vector of length (n-1); in
%   which case there is no way to decide whether it is a weight
%   vector or operator.
% 
%   See also opFoG, opStack, opSum.

%   Copyright 2009, Ewout van den Berg and Michael P. Friedlander
%   http://www.cs.ubc.ca/labs/scl/sparco
%   $Id$

classdef opDictionary < opSpot

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Methods
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    methods

       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       % Constructor
       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       function op = opDictionary(varargin)
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
             if (size(opA,1) ~= m) && ~isempty(opA)
               error('Operator %d is not consistent with the previous operators.',i);
             end

             n = n + size(opA,2); % Total number of columns
          end

          % Filter out all empty operators
          opListNew = {};
          for i=1:length(opList)
            if ~isempty(opList{i})
              opListNew{end+1} = opList{i};
            end
          end
          
          % Construct operator
          op = op@opSpot('Dictionary', m, n);
          op.cflag      = cflag;
          op.linear     = linear;
          op.children   = opListNew;
          op.precedence = 1;
       end
      
       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       % Display
       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       function str = char(op)
          % Initialize
          str = '[';
       
          for i=1:length(op.children)
             strOp = char(op.children{i});
             if i~=1
                str = [str, ', ', strOp];
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
                child = op.children{i};
                s = size(child,2);
                y = y + apply(child, x(k+1:k+s), 1);
                k = k + s;
             end
          else
             y = zeros(op.n,1);
             k = 0;
             for i=1:length(op.children)
                child = op.children{i};
                s          = size(child,2);
                y(k+1:k+s) = apply(child, x, 2);
                k          = k + s;
             end
          end
       end % Multiply          

    end % Methods
   
end % Classdef
