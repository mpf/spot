classdef opHadamard < opSpot
%OPHADAMARD   Hadamard matrix.
%
%   opHadamard(N) creates a Hadamard operator for vectors of length
%   N, where N is a power of two. Multiplication is done using a fast
%   routine.
%
%   opHadamard(N,NORMALIZED) is the same as above, except that the
%   columns are scaled to unit two-norm. By default, the NORMALIZED
%   flag is set to FALSE.

%   Copyright 2008-2009, Ewout van den Berg and Michael P. Friedlander
%   See the file COPYING.txt for full copyright information.
%   Use the command 'spot.gpl' to locate this file.

%   http://www.cs.ubc.ca/labs/scl/spot

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Properties
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    properties( SetAccess = private, GetAccess = public )
       normalized = false
    end
       
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Methods - Public
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    methods
       
       function op = opHadamard(n,normalized)
          %opHadamard Constructor
          if nargin < 1  ||  nargin > 2
             error('Invalid number of arguments.');
          end
          if n ~= power(2,round(log2(n)))
             error('Dimension must be a power of two.')
          end
          op = op@opSpot('Hadamard',n,n);
          if nargin == 2 && normalized
             op.normalized = true;
          end
       end % Constructor
        
    end % Methods

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Methods - protected
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    methods( Access = protected )
       
        % Multiplication
        function y = multiply(op,x,mode)
           y = x;
           n = op.n;
           k = round(log2(n));
           b = 1;     % Blocks on current level
           s = n / 2; % Stride
           for i=1:k  % Level
              for j=0:b-1  % Blocks
                 for k=1:s   % Elements within block
                    i1 = j*n + k;
                    i2 = i1 + s;
                    t1 = y(i1);
                    t2 = y(i2);
                    y(i1) = t1 + t2;
                    y(i2) = t1 - t2;
                 end
              end
              b = b * 2; s = s / 2; n = n / 2;
           end
           if op.normalized
              y = y / sqrt(op.n);
           end
        end % Multiply
    
    end % Methods
       
end % Classdef
