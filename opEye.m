classdef opEye < opSpot
%OPEYE  Identity operator.
%
%   opEye(M) creates the M-by-M identity operator.
%
%   opEye(M,N) creates the M-by-N identity operator. If N is omitted
%   it is set to M by default. Without any arguments an operator
%   corresponding to the scalar 1 is created.
%
%   opEye([M N]) is the same as the above.

%   Copyright 2009, Ewout van den Berg and Michael P. Friedlander
%   See the file COPYING.txt for full copyright information.
%   Use the command 'spot.gpl' to locate this file.

%   http://www.cs.ubc.ca/labs/scl/spot

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Methods - Public
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    methods
        
        % Constructor
        function op = opEye(varargin)
           if nargin == 0
              m = 1; n = 1;
           elseif nargin == 1
              if length(varargin{1}) == 2
                 m = varargin{1}(1);
                 n = varargin{1}(2);
              else
                 m = varargin{1};
                 n = m;
              end
           elseif nargin == 2
              m = varargin{1};
              n = varargin{2};
           else
              error('Too many input arguments.');
           end
           op = op@opSpot('Eye',m,n);
        end % function opEye

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
        end % multiply
      
    end % Methods
        
end % Classdef
