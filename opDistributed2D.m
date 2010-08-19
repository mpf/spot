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
        
        %This function is called in priority when an opSpot multiplies an
        %'opDistributed' object. Only left multiplication is enabled.
        function y=mtimes(A,B)
            if isa(B,'opDistributed2D')
                obj=B.obj;
                spmd
                    y=A*getLocalPart(obj);
                end
            elseif isa(A,'opDistributed2D')
                error('Data of opDistributed2D do not enable right multiplication.')
            end
        end
    end
end