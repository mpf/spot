classdef op2DTransform < opKron & opSweep
    
    %op2DTransform extends opKron. Indeed, it stores 2 transform operators
    %which will be applied to the rows and the columns of a right-hand
    %matrix X according to the equivalent operation (A kron B)X(:). Thus the
    %number of columns of A must be equal to the numer of rows of X and
    %the number of columns of B must be equal to the number of columns of X.
    %X must be distributed. The calculation is done in parallel.
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Public methods
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    methods
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Constructor
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function op = op2DTransform(varargin)
            op=op@opKron(varargin);
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
            [m,n]=size(x);
            if ~(m == size(op.children{2},2) && n == size(op.children{1},2))
                error(['The distributed matrix must match the columns',...
                    ' of the transform operators applied to it'])
            elseif ~isa(op,'op2DTransform')
                error('Left multiplication not taken in account')
            elseif ~isa(x,'distributed')
                error('Please, multiply with a distributed matrix')
            else
                y=op.multiply(x,1);
            end
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
            
            %Size of the operators
            [rA,cA]=size(A);
            [rB,cB]=size(B);
            
            %%%%%%%%%%%%%%%%%%%%%%Multiplication%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            perm = op.permutation; %Permutation to take in account.
            
            if perm(1)==2 %Classic multiplication order
                spmd
                    local_part=getLocalPart(x);
                    local_part_width=size(local_part,2);
                    assert( mod(local_part_width,1) == 0, ['x must be'...
                       ' distributed along columns'])
                    partition = codistributed.build(local_part_width, ...
                        codistributor1d(2,codistributor1d.unsetPartition,...
                        [1,numlabs]));
                    
                    local_part=B*local_part;
                    local_part=local_part.';
                    
                    x = codistributed.build(local_part, codistributor1d...
                        (1,partition,[cA,rB]));
                    x = redistribute(x,codistributor1d(2));
                    
                    local_part = getLocalPart(x);
                    local_part=A*local_part;
                    local_part=local_part.';
                    x=codistributed.build(local_part,codistributor1d(1,...
                        codistributor1d.unsetPartition,[rB,rA]));
                    y=redistribute(x,codistributor1d(2));
                end
            else  %Inverted multiplication order (to implement)
                spmd
                    local_part=getLocalPart(x);
                    local_part_width=size(local_part,2);
                    assert( mod(local_part_width,1) == 0, ['x must be'...
                       ' distributed along columns'])
                    partition = codistributed.build(local_part_width, ...
                        codistributor1d(2,codistributor1d.unsetPartition,...
                        [1,numlabs]));
                    
                    local_part=B*local_part;
                    local_part=local_part.';
                    
                    x = codistributed.build(local_part, codistributor1d...
                        (1,partition,[cA,rB]));
                    x = redistribute(x,codistributor1d(2));
                    
                    local_part = getLocalPart(x);
                    local_part=A*local_part;
                    local_part=local_part.';
                    x=codistributed.build(local_part,codistributor1d(1,...
                        codistributor1d.unsetPartition,[rB,rA]));
                    y=redistribute(x,codistributor1d(2));
                end
            end
        end % Multiply
    end %Protected methods
end % Classdef