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
<<<<<<< HEAD
<<<<<<< HEAD
=======
>>>>>>> "spot_multiplied removed and for loop placed inside applyMultiply. Supplementary test on the size of 'op' for pre-allocation when the for loop is needed."
        linear   = 1;     % Flag the op. as linear (1) or nonlinear (0)
        counter
        m        = 0;     % No. of rows
        n        = 0;     % No. of columns
        type     = '';
        cflag    = false; % Complexity of underlying operator
        children = {};    % Constituent operators (for a meta operator)
        precedence = 1;
<<<<<<< HEAD
    end
    
    properties( Dependent = true, SetAccess = private )
        nprods
=======
       linear   = 1;     % Flag the op. as linear (1) or nonlinear (0)
       counter
       m        = 0;     % No. of rows
       n        = 0;     % No. of columns
       type     = '';
       cflag    = false; % Complexity of underlying operator
       children = {};    % Constituent operators (for a meta operator)
       precedence = 1;
    end
    
    properties( Dependent = true, SetAccess = private )
       nprods
>>>>>>> "Initial import of spot optimized toolbox"
=======
    end
    
    properties( Dependent = true, SetAccess = private )
        nprods
>>>>>>> "spot_multiplied removed and for loop placed inside applyMultiply. Supplementary test on the size of 'op' for pre-allocation when the for loop is needed."
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
<<<<<<< HEAD
<<<<<<< HEAD
        
        function y = applyMultiply(op,x,mode)
            op.counter.plus1(mode);
            if isa(op,'opSweep')
                y = op.multiply(x,mode);
            else
                q = size(x,2);
                
                % Preallocate y
                if q > 1
                   if isscalar(op)
                      % special case: allocate result size of x
                      y = zeros(size(x));
                   elseif mode==1
                      y = zeros(op.m,q);
                   else
                      y = zeros(op.n,q);
                   end
                end
                
                for i=1:q
                    y(:,i) = op.multiply(x(:,i),mode);
                end
            end
        end
        
        function y = applyDivide(op,x,mode)
            y = op.divide(x,mode);
        end
        
        % Signature of external protected functions
        y = divide(op,x,mode);
=======

        function y = applyMultiply(op,x,mode)
          %op.counter.plus1(mode);
          %The previous line can be used to count the number of
          %multiplications (mode1 & mode2) so as to compare
          %algorithms.
          y=op.multiply(x,mode);
       end
       
       function y = applyDivide(op,x,mode)
          y = op.divide(x,mode);
       end
       
       % Signature of external protected functions
       y = divide(op,x,mode);
>>>>>>> "Initial import of spot optimized toolbox"
=======
        
        function y = applyMultiply(op,x,mode)
            %op.counter.plus1(mode);
            %The previous line can be used to count the number of
            %multiplications (mode1 & mode2) so as to compare
            %algorithms.
            if isa(op,'opSweep')
                y = op.multiply(x,mode);
            else
                q=size(x,2);
                
                height=op.m;
                width=op.n;
                
                % Preallocate y
                if (q > 1 || issparse(x))&& height>1 && width>1
                    if mode==1
                        y = zeros(op.m,q);
                    else
                        y = zeros(op.n,q);
                    end
                end
                
                for i=1:q
                    y(:,i) = op.multiply(x(:,i),mode);
                end
            end
        end
        
        function y = applyDivide(op,x,mode)
            y = op.divide(x,mode);
        end
        
        % Signature of external protected functions
        y = divide(op,x,mode);
>>>>>>> "spot_multiplied removed and for loop placed inside applyMultiply. Supplementary test on the size of 'op' for pre-allocation when the for loop is needed."
    end % methods - protected
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Abstract methods -- must be implemented by subclass.
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    methods( Abstract, Access = protected )
        y = multiply(op,x,mode)
    end % methods - abstract
    
end % classdef
