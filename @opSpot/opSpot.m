classdef opSpot
    %opSpot  Spot operator super class.
    %
    %   A = opSpot  creates an empty Spot operator.
    %
    %   A = opSpot(type,m,n)  creates a Spot operator named TYPE, of size
    %   M-by-N. CFLAG is set when the operator is
    %   complex. The TYPE and DATA fields provide the type of the operator
    %   (string) and additional data for printing.
    
    %   Copyright 2009, Ewout van den Berg and Michael P. Friedlander
    %   See the file COPYING.txt for full copyright information.
    %   Use the command 'spot.gpl' to locate this file.
    
    %   http://www.cs.ubc.ca/labs/scl/spot
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Properties
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    properties( SetAccess = protected )
        linear   = 1;     % Flag the op. as linear (1) or nonlinear (0)
        counter
        m        = 0;     % No. of rows
        n        = 0;     % No. of columns
        type     = '';
        cflag    = false; % Complexity of underlying operator
        children = {};    % Constituent operators (for a meta operator)
        precedence = 1;
        sweepflag = false; % whether we can do a sweep multiply, A*B
    end
    
    properties( Dependent = true, SetAccess = private )
        nprods
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Public methods
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    methods
        
        function op = opSpot(type,m,n)
            %opSpot  Constructor.
            if nargin == 0
                % Relax -- empty constructor.
                
            elseif nargin == 3
                m = max(0,m);
                n = max(0,n);
                if round(m) ~= m || round(n) ~= n
                    warning('SPOT:ambiguousParams',...
                        'Size parameters are not integer.');
                    m = floor(m);
                    n = floor(n);
                end
                op.type = type;
                op.m    = m;
                op.n    = n;
                op.counter = spot.counter();
            else
                error('Unsupported use of Spot constructor.');
            end
        end % function opSpot
        
        function nprods = get.nprods(op)
            %get.nprods  Get a count of the produts with the operator.
            nprods = [op.counter.mode1, op.counter.mode2];
        end % function get.Nprods
        
    end % methods - public
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Public methods
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    methods( Access = protected )
        
        function y = applyMultiply(op,x,mode)
            op.counter.plus1(mode);
            if op.sweepflag
                y = op.multiply(x, mode);
            else
                q = size(x, 2);
                
                % Preallocate y
                if q > 1
                   if isscalar(op)
                      % special case: allocate result size of x
                      y = zeros(size(x), class(x));
                   elseif mode==1
                      y = zeros(op.m, q, class(x));
                   else
                      y = zeros(op.n, q, class(x));
                   end
                end
                
                for i=1:q
                    y(:,i) = op.multiply(x(:,i), mode);
                end
            end
        end
        
        function y = applyDivide(op, x, mode)
            y = op.divide(x, mode);
        end
        
        % Signature of external protected functions
        y = divide(op, x, mode);
    end % methods - protected
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Abstract methods -- must be implemented by subclass.
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    methods( Abstract, Access = protected )
        y = multiply(op, x, mode)
    end % methods - abstract
    
end % classdef
