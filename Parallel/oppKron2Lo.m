classdef oppKron2Lo < opKron & opSweep
    
    %oppKron2Lo extends opKron. Indeed, it stores 2 transform operators
    %which will be applied to the rows and the columns of a right-hand
    %matrix X according to the equivalent operation (A kron B)X(:). Thus the
    %number of columns of A must be equal to the numer of rows of X and
    %the number of columns of B must be equal to the number of columns of X.
    %X must be distributed. The calculation is done in parallel.
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Properties
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    properties
        tflag = 0;
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Public methods
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    methods
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Constructor
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function op = oppKron2Lo(varargin)
            op= op@opKron(varargin);
        end % Constructor
        
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Display
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function str = char(op)
            str=['Kron(',char(op.children{1})];
            
            % Get operators
            for i=2:length(op.children)
                str=strcat(str,[', ',char(op.children{i})]);
            end
            str=strcat(str,')');
            if op.tflag
                str = strcat(str, '''');
            end
        end % Char
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % mtimes
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % mtimes is overloaded so as to call multiplication on a
        % distributed array. This multiplication will do the expected 2D
        % transform on 'x'.
        % For the moment mtimes is only implemented for right
        % multiplication
        function y=mtimes(op,x)
            assert( isa(x,'distributed') && size(x,2) == 1, ...
                'Please, use a vected distributed matrix')
            if ~isa(op,'oppKron2Lo')
                error('Left multiplication not taken in account')
            elseif ~isa(x,'distributed')
                error('Please, multiply with a distributed matrix')
            else
                y=op.multiply(x, op.tflag + 1 );
            end
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % transpose
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % transpose is overloaded to avoid wrapping the operator in an
        % opTranspose.
        function y = transpose(op)
            [m,n] = size(op);
            op.m = n;
            op.n = m;
            op.tflag =  ~op.tflag;
            op.permutation = op.permutation(end:-1:1);
            y = op;
        end
        function y = ctranspose(op)
            y = transpose(op);
        end
    
    end % Methods
    
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Protected methods
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    methods ( Access = protected )
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Multiply
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function y = multiply(op,x,mode)
            
            %The Kronecker product (KP) is applied to the right-hand matrix
            %taking in account the best order to apply the operators A and
            %B.
            
            %Operators
            A=op.children{1};
            B=op.children{2};
            
            if mode == 2
                A = A';
                B = B';
            end
            
            %Size of the operators
            [rA,cA]=size(A);
            [rB,cB]=size(B);
            
            %%%%%%%%%%%%%%%%%%%%%%Multiplication%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            perm = op.permutation; %Permutation to take in account.
            
            if perm(1)==2 %Classic multiplication order
                spmd
                    x=getLocalPart(x);
                    local_width=length(x)/cB;
                    assert( mod(local_width,1) == 0, ...
                        ' x must be distributed along columns before vec')
                    x = reshape(x,cB,local_width);
                    partition = codistributed.build(local_width, ...
                        codistributor1d(2,codistributor1d.unsetPartition,...
                        [1,numlabs]));
                    
                    x=B*x;
                    x=x.';
                    
                    x = codistributed.build(x, codistributor1d...
                        (1,partition,[cA,rB]));
                    x = redistribute(x,codistributor1d(2));
                    
                    x = getLocalPart(x);
                    x=A*x;
                    x=x.';
                    x=codistributed.build(x,codistributor1d(1,...
                        codistributor1d.unsetPartition,[rB,rA]));
                    x=redistribute(x,codistributor1d(2));
                    y = x(:);
                end
            else  %Inverted multiplication order 
                spmd
                    x=getLocalPart(x);
                    local_width=length(x)/cB;
                    assert( mod(local_width,1) == 0, ...
                        ' x must be distributed along columns before vec')
                    x = reshape(x,cB,local_width);
                    partition = codistributed.build(local_width, ...
                        codistributor1d(2,codistributor1d.unsetPartition,...
                        [1,numlabs]));
                    
                    x=x.';                    
                    x = codistributed.build(x, codistributor1d...
                        (1,partition,[cA,cB]));
                    x = redistribute(x,codistributor1d(2));
                    x = getLocalPart(x);
                    x = A*x;
                    x = x.';
                    
                    x = codistributed.build(x,codistributor1d(1,...
                        codistributor1d.unsetPartition,[cB,rA]));
                    x=redistribute(x,codistributor1d(2));
                    x = getLocalPart(x);
                    x = B*x;
                    x = codistributed.build(x,codistributor1d(2,...
                        codistributor1d.unsetPartition,[rB,rA]));
                    y = x(:);
                end
            end
        end % Multiply
    end %Protected methods
end % Classdef