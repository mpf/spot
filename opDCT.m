%opDCT  Discrete cosine transform (DCT)
%
%   opDCT(M) creates a one-dimensional discrete cosine transform
%   operator for vectors of length M.
%
%   opDCT(M,N) creates a two-dimensional discrete cosine transform
%   operator for matrices of size M by N. Input and output of the
%   matrices is done in vectorized form.

%   Copyright 2009, Ewout van den Berg and Michael P. Friedlander
%   http://www.cs.ubc.ca/labs/scl/sparco
%   $Id: opDCT.m 44 2009-06-17 00:33:32Z ewout78 $

classdef opDCT < opSpot

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Properties
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    properties (SetAccess = private)
       funHandle = []; % Multiplication function
    end % Properties

    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Methods - Public
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    methods
        
        % Constructor
        function op = opDCT(varargin)
           if nargin < 1 || nargin > 2
              error('Invalid number of arguments to opDCT.');
           end

           % Get problem size
           m = varargin{1};
           n = 1;
           if nargin == 2, n = varargin{2}; end

           if  ~isscalar(m) || m~=round(m) || m <= 0
              error('First argument to opDCT has to be a positive integer.');
           end

           if  ~isscalar(n) || n~=round(n) || n <= 0
              error('Second argument to opDCT has to be a positive integer.');
           end
           
           
           if n == 1 || m == 1
              % One-dimensional transform
              fun = @(x,mode) opDCT_intrnl(x,mode);
           else
              % Two-dimensional transform
              fun = @(x,mode) opDCT2d_intrnl(m,n,x,mode);
           end
           
           op = op@opSpot('DCT',m*n,m*n);
           op.funHandle = fun;
        end
        
    end % Methods
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Methods - protected
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    methods( Access = protected )
       
        % Multiplication
        function y = multiply(op,x,mode)
           y = op.funHandle(x,mode);
        end % Multiply
      
    end % Methods
        
end % Classdef


%======================================================================


% One-dimensional DCT
function y = opDCT_intrnl(x,mode)
if mode == 1
   y = sparcoDCT(full(x));
else
   y = sparcoIDCT(full(x));
end
end

%======================================================================

% Two-dimensional DCT
function y = opDCT2d_intrnl(m,n,x,mode)
if mode == 1
   y = sparcoDCT(full(reshape(x,m,n)));
   y = sparcoDCT(y')';
   y = y(:);
else
   y = sparcoIDCT(full(reshape(x,m,n)));
   y = sparcoIDCT(y')';
   y = y(:);
end
end
