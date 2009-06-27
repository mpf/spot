%opOnes   Operator equivalent to ones function.
%
%   opOnes(M,N) creates an operator corresponding to an M by N matrix
%   of ones. If parameter N is omitted it is set to M.

%   Copyright 2009, Ewout van den Berg and Michael P. Friedlander
%   http://www.cs.ubc.ca/labs/scl/sparco
%   $Id: opOnes.m 39 2009-06-12 20:59:05Z ewout78 $

classdef opOnes < opSpot
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Methods - Public
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    methods
        
        % Constructor
        function op = opOnes(m,n)
           if nargin < 1, m = 1; end;
           if nargin < 2, n = m; end;
            
            op = op@opSpot('Ones',m,n);
        end % Constructor
        
    end % Methods
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Methods - protected
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    methods( Access = protected )
       
        % Multiplication
        function y = multiply(op,x,mode)
           if (mode == 1)
              y = ones(op.m,1)*sum(x);
           else
              y = ones(op.n,1)*sum(x);
           end
        end % Multipy
      
    end % Methods
        
end % Classdef
