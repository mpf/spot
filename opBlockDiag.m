classdef opBlockDiag < opSpot
%OPBLOCKDIAG   Operator-diagonal operator.
%
%   B = opBlockDiag(OP1, OP2,...,OPN,OVERLAP) creates a compound block
%   operator with the input operators OP1, OP2,... on the diagonal of
%   B, e.g., B = DIAG([OP1 OP2 ... OPN]). When OVERLAP is a positive
%   integer the blocks will be offset OVERLAP rows relative to the
%   previous operator, when OVERLAP is negative the operators are
%   offset by the absolute value of OVERLAP in columns. Note that
%   choosing OVERLAP larger than the operator size may cause the
%   matrix to become block antidiagonal.
%
%   B = opBlockDiag(WEIGHT,OP1,...,OPN,OVERLAP) additionally
%   weights each block by the elements of the vector WEIGHT. If
%   only a single operator is given it is replicated as many times
%   as there are weights.
%
%   B = opBlockDiag(N,OP,OVERLAP) similar as above with WEIGHT
%   equal to ones(N,1). This will cause operator OP to be repeated
%   N times.
%
%   See also opFoG, opKron, opDictionary.

%   Copyright 2009, Ewout van den Berg and Michael P. Friedlander
%   See the file COPYING.txt for full copyright information.
%   Use the command 'spot.gpl' to locate this file.

%   http://www.cs.ubc.ca/labs/scl/spot

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Properties
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    properties( SetAccess = private )
       funHandle     % Multiplication function
    end % properties

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Methods
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    methods

       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       % Constructor
       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       function op = opBlockDiag(varargin)

          % Extract weight, overlap, and operator list parameters
          idxStart = 1; idxEnd   = nargin;
          weights  = [];
          overlap  = 0;
          if nargin > 0 && isnumeric(varargin{1})
             weights = varargin{1};
             weights = weights(:);
             idxStart = idxStart + 1;
          end

          if nargin > 2 && isscalar(varargin{end})
             overlap = varargin{end};
             idxEnd  = nargin - 1;
          end
          opList = varargin(idxStart:idxEnd);

          % Check number of operators
          if isempty(opList)
             error('At least one operator must be specified.');
          end

          % Check overlap parameter
          if ~spot.utils.isposintscalar(abs(overlap)+1)
             error('Overlap must be an integer scalar.');
          end

          % Convert all arguments to operators
          for i=1:length(opList)
             if ~isa(opList{i},'opSpot') 
                opList{i} = opMatrix(opList{i});
             end
          end

          % Set weights
          if isempty(weights)
             weights = ones(length(opList),1);
          elseif spot.utils.isposintscalar(weights) && length(opList) == 1
             weights = ones(weights,1);
          end;
       
          % Check complexity and size and repeat operators
          opListNew  = {};
          if length(opList) == 1
             % Repeat one operator with given weights
             opA    = opList{1};
             [m,n]  = size(opA);
             m = m * length(weights);
             n = n * length(weights);

             % Get complexity
             cflag  = ~isreal(opA) || ~all(isreal(weights));
             linear = opA.linear;

             % Add operators to list
             for i=1:length(weights)
                opListNew{end+1} = opA;
             end             
          else
             % Initialize
             m = 0; n = 0; cflag = 0; linear = 1;
  
             for i=1:length(opList)
                % Get operator and update size
                opA = opList{i};
                m = m + size(opA,1);
                n = n + size(opA,2);

                % Get complexity
                cflag  = cflag  | ~isreal(opA) | ~isreal(weights(i));
                linear = linear &  opA.linear;

                % Append operator
                opListNew{end+1}  = opA;
             end
          end
          opList = opListNew;

        
          % Construct function handle
          if overlap == 0
             fun = @(x,mode) opBlockDiag_intrnl(m,n,opList,weights,x,mode);
          elseif overlap < 0
             % Overlap in columns
             m = 0; n = 0; colOffset = 0; column = 0;

             % Compute number of columns and column offset of first operator
             for i=1:length(opList)
                [mOp,nOp] = size(opList{i});
                m         = m + mOp;
                n         = max(n,column+nOp);
                colOffset = min(colOffset,column);
                column    = column + nOp + overlap; % Overlap is negative
             end
             n = n - colOffset;
             fun = @(x,mode) opBlockDiagCol_intrnl(m,n,-colOffset,-overlap,opList,weights,x,mode);
          else
             % Overlap in rows
             m = 0; n = 0; rowOffset = 0; row = 0;

             % Compute number of rows and row offset of first operator
             for i=1:length(opList)
                [mOp,nOp] = size(opList{i});
                m         = max(m,row+mOp);
                n         = n + nOp;
                rowOffset = min(rowOffset,row);
                row       = row + mOp - overlap; % Overlap is positive
             end
             m = m - rowOffset;
             fun = @(x,mode) opBlockDiagRow_intrnl(m,n,-rowOffset,overlap,opList,weights,x,mode);
          end

          % Construct operator
          op = op@opSpot('BlockDiag', m, n);
          op.cflag      = cflag;
          op.linear     = linear;
          op.children   = opList;
          op.funHandle  = fun;
      end
      
       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       % Display
       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       function str = char(op)
          % Initialize
          str = 'BlockDiag(';
       
          for i=1:length(op.children)
             strOp = char(op.children{i});
             if i~=1
                str = [str, ', ', strOp];
             else
                str = [str, strOp];
             end             
          end
          
          str = [str, ')'];
       end % Display

    end % Methods
       
 
    methods ( Access = protected )
       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       % Multiply
       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       function y = multiply(op,x,mode)
          y = op.funHandle(x,mode);
       end % Multiply          

    end % Methods
   
end % Classdef


%=======================================================================


function y = opBlockDiag_intrnl(m,n,opList,weights,x,mode)

kx = 0; ky = 0;

if mode == 1
   y  = zeros(m,1);
   for i=1:length(opList)
      op  = opList{i};
      mOp = op.m;
      nOp = op.n;
      y(ky+1:ky+mOp) = weights(i) * op * x(kx+1:kx+nOp);
      kx = kx + nOp;
      ky = ky + mOp;
   end;
else   
   y  = zeros(n,1);
   for i=1:length(opList)
      op = opList{i};
      mOp = op.m;
      nOp = op.n;
      y(ky+1:ky+nOp) = conj(weights(i)) * op' * x(kx+1:kx+mOp);
      kx = kx + mOp;
      ky = ky + nOp;
   end
end
end


%=======================================================================


function y = opBlockDiagCol_intrnl(m,n,offset,overlap,opList,weights,x,mode)

kx = 0; ky = 0;

if mode == 1
   kx = offset; y  = zeros(m,1);
   for i=1:length(opList)
      op = opList{i};
      mOp = op.m;
      nOp = op.n;
      y(ky+1:ky+mOp) = weights(i) * (op * x(kx+1:kx+nOp));
      kx = kx + nOp - overlap;
      ky = ky + mOp;
   end
else
   ky = offset; y  = zeros(n,1);
   for i=1:length(opList)
      op = opList{i};
      mOp = op.m;
      nOp = op.n;
      y(ky+1:ky+nOp) = y(ky+1:ky+nOp) + conj(weights(i))*(op' * x(kx+1:kx+mOp));
      kx = kx + mOp;
      ky = ky + nOp - overlap;
   end   
end
end

%=======================================================================


function y = opBlockDiagRow_intrnl(m,n,offset,overlap,opList,weights,x,mode)

kx = 0; ky = 0;

if mode == 1
   ky = offset; y  = zeros(m,1);
   for i=1:length(opList)
      op = opList{i};
      mOp = op.m;
      nOp = op.n;
      y(ky+1:ky+mOp) = y(ky+1:ky+mOp) + weights(i) * (op * x(kx+1:kx+nOp));
      kx = kx + nOp;
      ky = ky + mOp - overlap;
   end
else
   kx = offset; y  = zeros(n,1);
   for i=1:length(opList)
      op = opList{i};
      mOp = op.m;
      nOp = op.n;
      y(ky+1:ky+nOp) = conj(weights(i)) * (op' * x(kx+1:kx+mOp));
      kx = kx + mOp - overlap;
      ky = ky + nOp;
   end   
end
end
