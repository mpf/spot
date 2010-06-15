classdef opHeaviside < opSpot
%OPHEAVISIDE   Heaviside operator.
%
%   opHeaviside(N,NORMALIZED) creates an operator for multiplication
%   by an N by N Heaviside matrix. These matrices have ones below and
%   on the diagonal and zeros elsewhere. NORMALIZED is a flag
%   indicating whether the columns should be scaled to unit Euclidean
%   norm. By default the columns are unnormalized.

%   Copyright 2009, Ewout van den Berg and Michael P. Friedlander
%   See the file COPYING.txt for full copyright information.
%   Use the command 'spot.gpl' to locate this file.

%   http://www.cs.ubc.ca/labs/scl/spot
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Properties
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    properties (SetAccess = private)
       normalized = false; % Normalized columns flag
    end % Properties

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Methods - Public
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    methods
        
        % Constructor
        function op = opHeaviside(n,normalized)
            if (nargin < 2), normalized = 0; end;
            
            op = op@opSpot('Heaviside',n,n);
            op.normalized = (normalized ~= 0);
        end
        
    end % Methods
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Methods - protected
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    methods( Access = protected )
       
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % multiply
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function y = multiply(op,x,mode)
           if mode == 1
              % Scale if normalized columns requested
              if op.normalized
                  x = [1./sqrt(op.n:-1:1)]'.*x(:);
              end

              y = cumsum(x);
           else
              y        = cumsum(x);
              ym       = y(end);
              y(2:end) = ym - y(1:end-1);
              y(1)     = ym;
   
              % Scale if normalized columns requested
              if op.normalized,
                 y = [1./sqrt(op.n:-1:1)]'.*y(:);
              end
           end
        end % Multipy
   
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % divide
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function x = divide(op,b,mode)
           if op.normalized
              v = sqrt(op.n:-1:1)';
           else
              v = ones(op.n,1);
           end

           if mode == 1
              x = b.*v;
              x(2:end) = x(2:end) - b(1:end-1).*v(2:end);
           else
              x = b.*v;
              x(1:end-1) = x(1:end-1) - b(2:end).*v(2:end);
           end
        end % function divide
   
    end % Methods
        
end % Classdef
