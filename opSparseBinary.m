classdef opSparseBinary < opSpot
%OPSPARSEBINARY   Random sparse binary matrix.
%
%   opSparseBinary(M,N) creates an M-by-N sparse binary matrix with
%   min(M,8) nonzeros in each column.
%
%   opSparseBinary(M,N,D) is the same as above, except that each
%   column has min(M,D) nonzero elements.
%
%   This matrix was suggested by Radu Berinde and Piotr Indyk,
%   "Sparse recovery using sparse random matrices", MIT CSAIL TR
%   2008-001, January 2008, http://hdl.handle.net/1721.1/40089
%
%   Note that opSparseBinary calls RANDPERM and thus changes the state
%   of RAND.
%
%   See also RAND, RANDPERM, SPARSE

%   Copyright 2008-2009, Ewout van den Berg and Michael P. Friedlander
%   See the file COPYING.txt for full copyright information.
%   Use the command 'spot.gpl' to locate this file.

%   http://www.cs.ubc.ca/labs/scl/spot

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Properties
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    properties (SetAccess = private)
       matrix = []; % Sparse matrix representation
    end % Properties

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Methods
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    methods

       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       % Constructor
       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       function op = opSparseBinary(m,n,d)
          
          if nargin < 2
             error('At least two parameters must be specified.')
          end
          
          % Don't allow more than m nonzeros per column (obviously).
          d = min(d,m);

          % Preallocate row pointers.
          ia = zeros(d*n,1);
          ja = zeros(d*n,1);
          va =  ones(d*n,1);

          for k = 1:n  % Loop over each column.

             % Generate d random integers in [1,m].
             % First try the faster (and newer) approach.
             try
                p = randperm(m,d);
             catch
                p = randperm(m);
                p = p(1:d);
             end
                
             % Indices for start and end of the k-th column.
             colbeg = 1+(k-1)*d;
             colend = colbeg + d - 1;

             % Populate the row and column indices.
             ia(colbeg:colend) = p;
             ja(colbeg:colend) = k;
          end
          A  = sparse(ia,ja,va,m,n);

          % Construct operator
          op = op@opSpot('SparseBinary', m, n);
          op.matrix = A;
       end % Constructor
                 
    end % Methods

    methods ( Access = protected )
       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       % Multiply
       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       function y = multiply(op,x,mode)
          if mode == 1
             y = op.matrix * x;
          else
             y = op.matrix'* x;
          end
       end % Multiply

    end % Methods
  
end % Classdef
