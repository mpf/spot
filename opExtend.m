classdef opExtend < opSpot
%OPEXTEND   Symmetric extension operator.
%
%   opExtend(P,Q,PEXT,QEXT) creates an extension operator that acts on a
%   "vectorized" matrix and appends a mirror symmetric boundary to the
%   right and bottom portions of  matrix. The original matrix is of size
%   PxQ. The operator generates a matrix that is PEXTxQEXT matrix. The
%   adjoint of the operator creates a PxQ matrix whose entries adjacent to
%   the extension border are twice the value of the entries of the original
%   matrix.
%
%                   Q      QEXT
%       *************++++++
%       *           *     +
%       *           *     +
%       *           *     +
%     P *************     +
%       +                 +
%  PEXT +++++++++++++++++++
%
%  Example 1. Extend a 2-by-3 matrix into a 4-by-6 matrix:
%    A = [1 2 3; 4 5 6];
%    E = opExtend(2, 3, 4, 6);
%    reshape(E*A(:),4,6)
%
%  Example 2. Requires imaging toolbox:
%    I = double(imread('cameraman.tif'));
%    E = opExtend(256,256,650,1400);
%    Isup = reshape(E*I(:),650,1400);
%    figure; imshow(uint8(Isup));

%   Copyright 2012, Hassan Mansour

%   http://www.cs.ubc.ca/labs/scl/spot   
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Properties
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
properties( SetAccess = private, GetAccess = public )
   % Input matrix
   p           % rows
   q           % cols
   % Extended result
   pext        % rows
   qext        % cols
end

properties( Access = public )
   Rc
   Rr
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Methods - public
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
methods
   function op = opExtend(p,q,pext,qext)
      
      m = pext*qext;
      n = p*q;
      op = op@opSpot('Extend',m,n);
      
      if p <= pext
         I = speye(p);
         Iflip = flipud(I);
         
         pbndry_size = pext - p;
         pmult = floor(pbndry_size/p);
         
         if mod(pmult,2)
            Icat = repmat([I;Iflip],(pmult+1)/2,1);
            I = Icat;
         else
            Icat = repmat([Iflip;I],(pmult)/2,1);
            I = [I;Icat];
         end
         
         pbndry = I(end:-1:end - (pbndry_size - pmult*p)+ 1, :);
         op.Rc = [I; pbndry]; % = I if p == pext.
      else
         I = speye(p);
         op.Rc = I(1:pext,1:p);
      end
      
      if q <= qext
         I = speye(q);
         Iflip = flipud(I);
         
         qbndry_size = qext - q;
         qmult = floor(qbndry_size/q);
         
         if mod(qmult,2)
            Icat = repmat([I;Iflip],(qmult+1)/2,1);
            I = Icat;
         else
            Icat = repmat([Iflip;I],(qmult)/2,1);
            I = [I;Icat];
         end
         
         qbndry = I(end:-1:end - (qbndry_size - qmult*q)+ 1, :);
         op.Rr = [I; qbndry]; % = I if q == qext.
      else
         I = speye(q);
         op.Rr = I(1:qext,1:q);
      end
      
      op.p = p;
      op.q = q;
      op.pext = pext;
      op.qext = qext;
   end % Constructor
   
end % methods public

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Methods - protected
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
methods(Access = protected)
   
   function y = multiply(op,x,mode)
      if mode == 1
         Xmat = reshape(x, op.p, op.q);
         Xmat = op.Rc*Xmat;
         Xmat = (op.Rr*Xmat')';
      else
         Xmat = reshape(x, op.pext, op.qext);
         Xmat = op.Rc'*Xmat;
         Xmat = (op.Rr'*Xmat')';
      end
      y = full(Xmat(:));  % need full because op.Rx is sparse
   end % function multiply
   
end % methods protected

end
