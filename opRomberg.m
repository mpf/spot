classdef opRomberg < opSpot
    % OPROMBERG     a 2D random convolution based on Romberg 08
    % (expects a vector for input and output)
    %
    %   opRomberg(DIMS) returns an opRomberg operator
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Properties
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    properties ( Access = private )
        dimensions = []; % Dimensions of the Romberg
        phases     = [];
        signs      = [];
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Public methods
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    methods
        
      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      % Constructor
      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      
        function op = opRomberg(dims)
            
            % Check number of arguments
            assert(nargin == 1, 'opRomberg must have one argument')
            
            % Check for input arguments
            assert(isnumeric(dims) && all(dims > 0),...
                'Dimensions argument of opRomberg has to be a positive numeric vector.')
            
            % Check for vector cases
            if numel(dims) == 1, dims = [dims 1]; end
            
            % Process dimensions
            m  = prod(dims);
            n  = prod(dims);
            
            op = op@opSpot('Romberg',m,n);
            op.cflag      = false;
            op.linear     = true;
            op.sweepflag  = false;
            op.dimensions = dims;
            op.phases     = random_phasesND(dims);
            op.signs      = sign(randn(dims));
        end % Constructor
        
    end % Public methods
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Protected methods
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    methods( Access = protected )
        function y = multiply(op,x,mode)
            
            % Setup variables
            dims = op.dimensions;
            phs  = op.phases;
            sgn  = op.signs;
            
            if mode == 1
                x = reshape(x,dims);
                y = sgn.*ifftn(phs.*fftn(full(x)));
                y = y(:);
            else
                x = reshape(x,dims);
                y = ifftn(conj(phs).*fftn(sgn.*full(x)));
                y = y(:);
            end
            
        end % Multiply
        
    end % Protected methods
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Private methods
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
    methods( Access = private )
        function PHS = random_phasesND(dims)
            % random_phases.m
            %
            % Create array of random phases, with symmetries for a real-valued
            % 3D image.
            p1 = exp(1i*2*pi*rand(dims));
            p2 = fftn(real(ifftn(p1)));
            PHS = p2./abs(p2);
            
        end % random_phasesND
        
    end % Private methods
    
end % Classdef