classdef opExcise < opSpot
%OPEXCISE   Excise rows or columns of an operator.
%
%   opExcise(OP,IDX,TYPE) excises the entries in the rows or columns
%   given by IDX, depending on whether TYPE = 'rows', or 'cols'.
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
       indices    = []; % Indices
       rowExcise  = false;
    end % Properties

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Methods
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    methods

       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       % Constructor
       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       function op = opExcise(A,idx,type)
          
          if nargin ~= 3
             error('Exactly three operators must be specified.')
          end
           
          % Input matrices are immediately cast as opMatrix's.
          if isa(A,'numeric'), A = opMatrix(A); end
          
          % Check that the input operators are valid.
          if ~isa(A,'opSpot')
             error('Input operator is not valid.')
          end
          
          % Check type
          switch lower(type)
             case {'col','cols','column','columns'}
                rowExcise = false;
                dimIdx    = 2;

             case {'row','rows'}
                rowExcise = true;
                dimIdx    = 1;

             otherwise
                error('Invalid parameter for operator type.');
          end
          
          % Check index type and range
          if islogical(idx)
             if (length(idx) > size(A,dimIdx))
                error('Index exceeds operator dimensions.');
             end
          elseif spot.utils.isposintmat(idx)
             if (max(idx) > size(A,dimIdx))
                error('Index exceeds operator dimensions.');
             end
          else
             error(['Subscript indices must either be real positive ' ...
                    'integers or logicals.']);
          end
          
          % Reverse input vector
          if islogical(idx)
             idxReverse = true(size(A,dimIdx),1);
             idxReverse(idx) = false;
          else
             idxReverse = setdiff(1:size(A,dimIdx),idx);
          end

          % Construct new operator
          if rowExcise
             opIntrnl = opRestriction(size(A,1),idxReverse) * A;
          else
             opIntrnl = A * opRestriction(size(A,2),idxReverse)';
          end
          
          % Construct operator
          [m,n] = size(opIntrnl);
          op = op@opSpot('Excise', m, n);
          op.cflag      = A.cflag;
          op.linear     = A.linear;
          op.children   = {A};
          op.opIntrnl   = opIntrnl;
          op.indices    = idx;
          op.rowExcise  = rowExcise;
       end % Constructor
      
       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       % Display
       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       function str = char(op)
          if op.rowExcise
             type = 'Rows';
          else
             type = 'Cols';
          end

          str = ['Excise(', char(op.children{1}),', ', type, ')'];
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
