classdef (InferiorClasses = {?opKron})opDistributed2D < opClass
    %opDistributed2D extends from opClass and wraps a distributed matrix
    %stored in its property 'obj' (property of the upper class). The matrix
    %is distributed along the columns. Its function 'mtimes' is called in
    %priority when opDistributed2D is multiplied by an opKron.
    
    %fixme : all other opSpot objects should be inferior to opDistributed2D
    %but InferiorClasses just defines the specified object as inferior and
    %not its subclasses.
    
    methods
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Constructor
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function op=opDistributed2D(matrix)
            [m,n]=size(matrix);
            cflag=~isreal(matrix);
            spmd,distributed_matrix=codistributed(matrix,codistributor1d(2));end
            op=op@opClass(m,n,distributed_matrix,cflag);
        end
        
        function y=double(op)
            y=op.obj;
        end
        
        %This function is called in priority when an opKron multiplies an
        %'opDistributed' object.
        function y=mtimes(A,B)
            if isa(B,'opDistributed2D')
                obj=B.obj;
                spmd
                    local_part=getLocalPart(obj);
                    if ~isempty(local_part)
                        y=applyMultiply(A,local_part,1);
                    end
                end
            elseif isa(A,'opDistributed2D')
                obj=A.obj;
                spmd,
                    local_part=getLocalPart(obj)';
                    if ~isempty(local_part)
                        y=applyMultiply(B,local_part,2)';
                    end
                end
            end
        end
    end
end