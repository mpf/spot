%opHadamard   Hadamard matrix
%
%    opHadamard(N,NORMALIZED) creates a Hadamard operator for vectors
%    of length N, where N is a power of two. Multiplication is done
%    using a fast routine. When the normalized flag is set, the
%    columns of the Hadamard matrix are scaled to unit two-norm. By
%    default the NORMALIZED flag is set to 0.

classdef opHadamard < opSpot

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Properties
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    properties (SetAccess = private)
       diag = []; % Diagonal entries
    end % Properties


    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Methods - Public
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    methods
        
        % Constructor
        function op = opHadamard(n,normalized)
           if (nargin < 1) || (nargin > 2)
              error('Invalid number of arguments.');
           end
           if n ~= power(2,round(log2(n)))
              error('Dimension has to be power of two.')
           end
           if (nargin < 2)
              normalized = 0;
           end
           
           % Construct object
           op = op@opSpot('Hadamard',n,n);
        end
        
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
       
        end % Multiply
    
    end % Methods
       
end % Classdef
