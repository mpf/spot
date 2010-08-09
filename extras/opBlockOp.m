%opBlockOp   Blockwise application of operator on matrices
%
%   B = opBlockOp(M,N,OPIN,BR1,BC1,BR2,BC2) creates an operator that
%   applies the given OPIN operator on two-dimensional data in a
%   blockwise fashion. In the forward mode this means that the input
%   vector is reshaped into an M-by-N matrix, which is then divided
%   into blocks of size BR1-by-BC1. Next, we apply OPIN to each
%   (vectorized) block and reshape the output to BR2-by-BC2
%   blocks. These blocks are gathered in a matrix which is vectorized
%   to give the final output. In transpose mode, the input vector is
%   reshaped into a matrix with M/BR1-by-N/BC1 blocks of size
%   BR2-by-BC2, and the conjugate transpose of OPIN is applied to each
%   block as described above to give BR1-by-BC1 blocks. These form an
%   M-by-N matrix which is vectorized for output. When omitted, BR2
%   and BC2 are respectively set to BR1 and BC1 by default.

%   Copyright 2009, Ewout van den Berg and Michael P. Friedlander
%   http://www.cs.ubc.ca/labs/scl/sparco
%   $Id$

classdef opBlockOp < opSpot
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Properties
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    properties( SetAccess = private )
       nblocks    = []; % Number of blocks
       blocksize1 = []; % Blocksize in forward mode
       blocksize2 = []; % Blocksize in transpose mode
       inputdims  = []; % Dimensions of the input      
    end % Properties

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Methods
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    methods
  
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Constructor
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function op = opBlockOp(m,n,A,br1,bc1,br2,bc2)
           
           nbr = m / br1; % Number of blocks in row direction
           nbc = n / bc1; % Number of blocks in column direction

           if ~exist('br2','var'), br2 = br1; end;
           if ~exist('bc2','var'), bc2 = bc1; end;
           
           if nbr ~= round(nbr) || nbc ~= round(nbc)
              error('Block size must divide data dimensions.');
           end
           
           if (size(A,1) ~= br2*bc2) || (size(A,2) ~= br1*bc1)
              error('Block size and operator dimensions do not match.');
           end

           op = op@opSpot('BlockOp',(nbr*br2)*(nbc*bc2),m*n);
           op.inputdims  = [m,n];
           op.nblocks    = [nbr,nbc];
           op.blocksize1 = [br1,bc1];
           op.blocksize2 = [br2,bc2];
           op.children   = {A};
        end

    end % Methods
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Methods - protected
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    methods( Access = protected )

       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       % Multiply
       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       function z = multiply(op,x,mode)
          m   = op.inputdims(1);
          n   = op.inputdims(2);
          nbr = op.nblocks(1); % Blocks per row
          nbc = op.nblocks(2); % Blocks per columns
          blockOp = op.children{1};

          bsr1 = op.blocksize1(1); % Block size in rows
          bsc1 = op.blocksize1(2); % Block size in columns
          bsr2 = op.blocksize2(1); % Block size in rows
          bsc2 = op.blocksize2(2); % Block size in columns
          
          if mode == 1
             y = full(reshape(x,m,n));
             z = zeros(nbr*bsr2,nbc*bsc2);
             for i=1:nbr
                 for j=1:nbc
                    blk = y((i-1)*bsr1+(1:bsr1),(j-1)*bsc1+(1:bsc1));
                    data= applyMultiply(blockOp,blk(:),1);
                    z((i-1)*bsr2+(1:bsr2),(j-1)*bsc2+(1:bsc2)) = reshape(data,bsr2,bsc2);
                 end
             end             
          else
             y = full(reshape(x,nbr*bsr2,nbc*bsc2));
             z = zeros(m,n);
             for i=1:nbr
                 for j=1:nbc
                    blk = y((i-1)*bsr2+(1:bsr2),(j-1)*bsc2+(1:bsc2));
                    data= applyMultiply(blockOp,blk(:),2);
                    z((i-1)*bsr1+(1:bsr1),(j-1)*bsc1+(1:bsc1)) = reshape(data,bsr1,bsc1);
                 end
             end             
          end
          z = z(:);
       end % function multiply

    end % methods - protected
        
end % Classdef
