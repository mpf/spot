classdef opExtend < opSpot
%OPEXTEND   Symmetric extension operator.
%
%   opExtend(P,Q,PEXT,QEXT) creates an extension operator that appends a
%   mirror symmetric boundary to the right and bottom portions of a matrix.
%   The original matrix is of size PxQ. The operator generates a PEXTxQEXT
%   matrix. The adjoint of the operator creates a PxQ matrix whose entries
%   adjacent to the extension border are twice the value of the entries of
%   the original matrix.
%
%                   P      PEXT
%       *************++++++
%       *           *     +
%       *           *     +
%       *           *     +
%     Q *************     +
%       +                 +
%  QEXT +++++++++++++++++++


%   Copyright 2012, Hassan Mansour

%   http://www.cs.ubc.ca/labs/scl/spot   
    
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   % Properties
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    properties
        p
        q
        pext
        qext
        Rc
        Rr
        funHandle
    end
    
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   % Methods - public
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    methods
        function op = opExtend(p,q,pext,qext)
            m = pext*qext;
            n = p*q;
            op = op@opSpot('Extend',m,n);
            if p == pext
                I = opEye(p);
                op.Rc = I;
            else
                I = opEye(p);
                pbndry_size = pext - p;
                pbndry = I(p:-1:p - pbndry_size + 1, :);
                I = [I; pbndry];
                
                op.Rc = I;
            end
            
            if q == qext
                I = opEye(q);
                op.Rr = I;
            else
                I = opEye(q);
                qbndry_size = qext - q;
                qbndry = I(q:-1:q - qbndry_size + 1, :);
                I = [I; qbndry];
                
                op.Rr = I;
            end
            
            op.p = p;
            op.q = q;
            op.pext = pext;
            op.qext = qext;
            op.funHandle = @multiply_intrnl;
        end % Constructor
        
    end % methods public
    
    methods(Access = private)
        function y = multiply_intrnl(op,x,mode)
            if mode == 1
                Xmat = reshape(x,op.p, op.q);
                Xmat = op.Rc*Xmat;
                Xmat = (op.Rr*Xmat')';
            else
                Xmat = reshape(x,op.pext, op.qext);
                Xmat = op.Rc'*Xmat;
                Xmat = (op.Rr'*Xmat')';
            end
            y = Xmat(:);
        end
    end % methods private
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Methods - protected
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    methods(Access = protected)
        
      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      % Multiply
      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      function y = multiply(op,x,mode)
         y = op.funHandle(op,x,mode);
      end % function multiply
      
    end % methods protected
    
end