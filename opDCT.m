%opDCT  One-dimensional discrete cosine transform (DCT)
%
%   opDCT(N) creates a one-dimensional discrete cosine transform
%   operator for vectors of length N.

%   Copyright 2008, Ewout van den Berg and Michael P. Friedlander
%   http://www.cs.ubc.ca/labs/scl/sparco
%   $Id: opDCT.m 1027 2008-06-24 23:42:28Z ewout78 $

classdef opDCT < opSpot
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Methods - Public
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    methods
        
        % Constructor
        function op = opDCT(m,n)
            if nargin < 1 || nargin > 2
               error('Invalid number of arguments.');
            end
            if nargin < 2 || isempty(m)
               n = 1;
            end
            op = op@opSpot('DCT',m*n,m*n);
        end
        
    end % methods
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Methods - protected
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    methods( Access = protected )
       
        % Multiplication
        function y = multiply(op,x,mode)
            if mode == 1
               y = dct(full(x));
            else
               y = idct(full(x));
            end
        end
      
    end % methods
        
end % classdef
