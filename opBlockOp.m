
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
           
           nbr = m / br1;
           nbc = n / bc1;
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
                    data= apply(blockOp,blk(:),1);
                    z((i-1)*bsr2+(1:bsr2),(j-1)*bsc2+(1:bsc2)) = reshape(data,bsr2,bsc2);
                 end
             end             
          else
             y = full(reshape(x,nbr*bsr2,nbc*bsc2));
             z = zeros(m,n);
             for i=1:nbr
                 for j=1:nbc
                    blk = y((i-1)*bsr2+(1:bsr2),(j-1)*bsc2+(1:bsc2));
                    data= apply(blockOp,blk(:),2);
                    z((i-1)*bsr1+(1:bsr1),(j-1)*bsc1+(1:bsc1)) = reshape(data,bsr1,bsc1);
                 end
             end             
          end
          z = z(:);
       end % function multiply

    end % methods - protected
        
end % Classdef
