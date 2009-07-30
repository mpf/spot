%opEye  Identity operator
%
%   opEye(M,N) creates the identity operator of size M-by-N. If N is
%   omitted it is set to M by default. Without any arguments an
%   operator corresponding to the scalar 1 is created.

%   Copyright 2009, Ewout van den Berg and Michael P. Friedlander
%   http://www.cs.ubc.ca/labs/scl/spot

classdef opEye < opSpot
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Methods - Public
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    methods
        
        % Constructor
        function op = opEye(m,n)
           if nargin < 1, m = 1; end
           if nargin < 2, n = m; end
           op = op@opSpot('Eye',m,n);
        end % Constructor

        function A = double(op)
           A = eye(size(op));
        end % double
        
    end % Methods
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Methods - protected
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    methods( Access = protected )
       
        % Multiplication
        function y = multiply(op,x,mode)
           [m,n] = size(op);
           if mode == 1
              if m <= n
                 y = x(1:m);
              else
                  y = [x; zeros(m-n,1)];
              end   
           else
              if n <= m
                 y = x(1:n);
              else
                 y = [x; zeros(n-m,1)];
              end
           end
        end % Multipy
      
    end % Methods
        
end % Classdef
