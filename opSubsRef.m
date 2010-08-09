classdef opSubsRef < opSpot
%OPSUBSREF   Extract rectangular subset of operator entries.
%
%   opSubsRef(OP,ROWIDX,COLIDX) returns subset of entries indicated by
%   the ROWIDX and COLIDX. The indices are either integer or logical
%   vectors, or the ':' string denoting the entire range.
%
%   See also opRestrict.

%   Copyright 2009, Ewout van den Berg and Michael P. Friedlander
%   See the file COPYING.txt for full copyright information.
%   Use the command 'spot.gpl' to locate this file.

%   http://www.cs.ubc.ca/labs/scl/spot

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Properties
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    properties (SetAccess = private)
       opIntrnl   = []; % Internal operator
       rowIndices = []; % Row indices
       colIndices = []; % Column indices
    end % Properties


    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Methods
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    methods

       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       % Constructor
       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       function op = opSubsRef(A,rowIdx,colIdx)
          
          if nargin ~= 3
             error('Exactly three operators must be specified.')
          end
           
          % Input matrices are immediately cast as opMatrix's.
          if isa(A,'numeric'), A = opMatrix(A); end
          
          % Check that the input operators are valid.
          if ~isa(A,'opSpot')
             error('Input operator is not valid.')
          end

          % Check indices
          subs = {rowIdx, colIdx};
          dims = size(A);
          for i=1:length(subs)
             idx = subs{i}; idx = idx(:); subs{i} = idx;
             if isempty(idx)
                % Fine
             elseif strcmp(idx,':')
                % Fine
             elseif islogical(idx)
                if (length(idx) > dims(i))
                   error('Index exceeds operator dimensions.');
                end
             elseif spot.utils.isposintmat(idx)
                if (max(idx) > dims(i))
                   error('Index exceeds operator dimensions.');
                end
             else
                error(['Subscript indices must either be real positive ' ...
                       'integers or logicals.']);
             end
          end

          % Check if all rows or columns are specified explicitly
          allindex = zeros(2,1);
          for i=1:2
             idx = subs{i};
            
             if ((strcmp(idx,':')) || ...
                 (islogical(idx) && all(idx)) || ...
                 (isnumeric(idx) && (length(idx) == dims(i)) && all(idx == [1:dims(i)]')))
                allindex(i) = 1;
             end            
          end

          % Construct new operator
          [m, n] = size(A);
          opIntrnl = A;
          if ~allindex(1)
             opIntrnl = opRestriction(m,subs{1}) * opIntrnl;
          end
          if ~allindex(2)
             opIntrnl = opIntrnl * opRestriction(n,subs{2})';
          end
          
          % Construct operator
          [m,n] = size(opIntrnl);
          op = op@opSpot('Subsref', m, n);
          op.cflag      = A.cflag;
          op.linear     = A.linear;
          op.children   = {A};
          op.precedence = 1;
          op.opIntrnl   = opIntrnl;
          op.rowIndices = rowIdx;
          op.colIndices = colIdx;
       end % Constructor
      
       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       % Display
       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       function str = char(op)
          str = ['Subsref(', char(op.children{1}),')'];
       end % Char
       
    end % Methods


    methods ( Access = protected )
       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       % Multiply
       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       function y = multiply(op,x,mode)
          y = applyMultiply(op.opIntrnl,x,mode);
       end % Multiply

    end % Methods
   
end % Classdef
