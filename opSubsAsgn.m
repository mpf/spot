classdef opSubsAsgn < opSpot
%OPSUBSASGN   Redefine rectangular subset of operator.
%
%   opSubsAsign(A,ROWIDX,COLIDX,B), index = ':' is valid. Size of B
%   must match that of rowidx and colidx. THe indices can exceed the
%   size of A (even if idx is given as logical) but must not be negative?
%
%   See also opRestrict, opSubsRef.

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
       function op = opSubsAsgn(A,rowIdx,colIdx,B)
          
          if nargin ~= 4
             error('Exactly four operators must be specified.')
          end
           
          % Input matrices are immediately cast as opMatrix's.
          if isa(A,'numeric'), A = opMatrix(A); end
          if isa(B,'numeric'), B = opMatrix(B); end
          
          % Check that the input operators are valid.
          if ~isa(A,'opSpot') || ~isa(A,'opSpot')
             error('Input operators are not valid.')
          end

          % Initialize
          subs  = {rowIdx, colIdx};
          
          % Ensure numeric vectors are full and in vectorized form
          for i=1:length(subs)
             idx = subs{i}; idx = idx(:);
             subs{i} = full(idx);
          end
          
          % Check index type and get additional information
          allIndex  = zeros(1,2); % Set if entire dimension in A covered
          sizeIndex = zeros(1,2);
          maxIndex  = zeros(1,2);
          minIndex  = zeros(1,2);
          for i=1:2
             idx = subs{i};

             if strcmp(idx,':')
                % Replace by vector of logicals
                subs{i} = true(size(A,i),1);

                sizeIndex(i) = size(A,i);
                allIndex(i)  = 1;
                minIndex(i)  = 1;
                maxIndex(i)  = size(A,i);

             elseif islogical(idx)
                % Pad vector with false values if needed
                if length(idx) < size(A,i)
                   idx(sizeA(i)) = false;
                   subs{i} = idx;
                end
                
                sizeIndex(i) = sum(double(idx ~= 0));
                minIndex(i)  = min(find(idx));
                maxIndex(i)  = max(find(idx));

                % Check if all indices are specified
                if all(idx(1:size(A,i)))
                    allIndex(i) =1;
                end
                
             elseif spot.utils.isposintmat(idx)
                sizeIndex(i) = length(idx);
                minIndex(i)  = min(idx);
                maxIndex(i)  = max(idx);

                % Check for duplicates
                if length(idx) ~= length(unique(idx))
                   error('Subscripts cannot contain duplicates.');
                end
                
                % Check if all indices are specified
                if isempty(setdiff(1:size(A,i),idx))
                   allIndex(i) = 1;
                end
             else
                error(['Subscript indices must either be real positive ' ...
                       'integers or logicals.']);
             end
          end
          
          % Check if index and operator dimensions match
          if isscalar(B)
             B = opFoG(B,opOnes(sizeIndex(1),sizeIndex(2)));
          elseif (sizeIndex(1) ~= size(B,1)) || (sizeIndex(2) ~= size(B,2))
             error('Subscripted assignment dimension mismatch.');
          end
          
          % Determine final operator size
          m = max(maxIndex(1),size(A,1));
          n = max(maxIndex(2),size(A,2));
          
          % Embed operators A into one matching the final size
          embedA = A;
          if m > size(A,1)
             embedA = opRestriction(m,1:size(A,1))' * embedA;
          end
          if n > size(A,2)
             embedA = embedA * opRestriction(n,1:size(A,2));
          end

          % Embed and possibly permute operator B
          embedB = opRestriction(m,subs{1})' * B;
          embedB = embedB * opRestriction(n,subs{2});
          
          % Set default cflag and linear flag
          cflag  = A.cflag  | B.cflag;
          linear = A.linear | B.linear;
          
          if allIndex(1) && allIndex(2)
             % --------------------------------------------------------
             % Case 1: Full overlap
             %         Embed(B)
             % --------------------------------------------------------
             opIntrnl = embedB;
             cflag    = B.cflag;
             linear   = B.linear;
             
          elseif allIndex(1)
             % --------------------------------------------------------
             % Case 2: Number of entire rows
             %         Embed(A)*Mask + Embed(B)
             % --------------------------------------------------------
             if islogical(subs{2})
                idx = xor(true(n,1), subs{2});
             else
                idx = setdiff(1:size(A,2),subs{2});
             end
             maskA = opMask(n,idx);
             opIntrnl = embedA * maskA + embedB;
             
          elseif allIndex(2)
             % --------------------------------------------------------
             % Case 3: Number of entire columns
             %         Mask*Embed(A) + Embed(B)
             % --------------------------------------------------------
             if islogical(subs{1})
                idx = xor(true(m,1), subs{1});
             else
                idx = setdiff(1:size(A,1),subs{1});
             end
             maskA = opMask(m,idx);
             opIntrnl = maskA * embedA + embedB;
             
          elseif (minIndex(1) > size(A,1)) || (minIndex(2) > size(A,2))
             % --------------------------------------------------------
             % Case 4: No overlap
             %         Embed(A) + Embed(B)
             % --------------------------------------------------------
             opIntrnl = embedA + embedB;
          
          else
             % --------------------------------------------------------
             % Case 5: Partial overlap
             %         Embed(A) + Embed(B) - maskA1 * Embed(A) * maskA2
             % --------------------------------------------------------
             if islogical(subs{1})
                idx1 = true(m,1) & subs{1};
             else
                idx1 = intersect(1:size(A,1),subs{1});
             end

             if islogical(subs{2})
                idx2 = true(n,2) & subs{2};
             else
                idx2 = intersect(1:size(A,2),subs{2});
             end

             maskA1 = opMask(m,idx1);
             maskA2 = opMask(n,idx2);
             opIntrnl = embedA + embedB - maskA1 * embedA * maskA2;
          end
          
          % Construct operator
          op = op@opSpot('SubsAsgn', m, n);
          op.cflag      = cflag;
          op.linear     = linear;
          op.children   = {A,B};
          op.precedence = 1;
          op.opIntrnl   = opIntrnl;
          op.rowIndices = rowIdx;
          op.colIndices = colIdx;
       end % Constructor
      
       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       % Display
       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       function str = char(op)
          str = ['Subsasgn(', char(op.children{1}),', ',...
                              char(op.children{2}),')'];
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
