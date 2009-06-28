%opSpot  Spot operator super class.
%
%   A = opSpot  creates an empty Spot operator.
%
%   A = opSpot(type,m,n)  creates a Spot operator named TYPE, of size
%   M-by-N. CFLAG is set when the operator is
%   complex. The TYPE and DATA fields provide the type of the operator
%   (string) and additional data for printing.

%   Copyright 2009, Ewout van den Berg and Michael P. Friedlander
%   http://www.cs.ubc.ca/labs/scl/sparco
%   $Id$
classdef opSpot < handle
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Properties
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    properties (SetAccess = protected)
        linear   = 1;
        counter  = [0, 0];
        m        = 0;
        n        = 0;
        type     = '';
        cflag    = false; % Complexity of underlying operator
        children = {};    % Constituent operators (for a meta operator)
        precedence = 1;
    end
        
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Public methods
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    methods
        
        % Constructor.
        function op = opSpot(type,m,n)
            if nargin == 0
               % Relax -- empty constructor.
            
            elseif nargin == 3
                op.type = type;
                op.m    = m;
                op.n    = n;
                
            else
                error('Unsupported use of Spot constructor.');
            end
        end
    end % methods - public
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Public methods
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    methods (Access = protected)
       function y = apply(op,x,mode)
          y = op.multiply(x,mode);
       end
    end % methods - private
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Abstract methods -- must be implemented by subclass.
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    methods (Abstract, Access = protected)
        res = multiply(op,x,mode)
    end % methods - abstract
    
end % classdef
