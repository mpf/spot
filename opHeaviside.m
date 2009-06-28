%opHeaviside   Heaviside operator
%
%   opHeaviside(N,NORMALIZED) creates an operator for multiplication
%   by an N by N Heaviside matrix. These matrices have ones below and
%   on the diagonal and zeros elsewhere. NORMALIZED is a flag
%   indicating whether the columns should be scaled to unit Euclidean
%   norm. By default the columns are unnormalized.

%   Copyright 2009, Ewout van den Berg and Michael P. Friedlander
%   http://www.cs.ubc.ca/labs/scl/sparco
%   $Id$

classdef opHeaviside < opSpot
    
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
       
        % Multiplication
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
      
    end % Methods
        
end % Classdef
