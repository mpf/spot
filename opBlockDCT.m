
classdef opBlockDCT < opSpot
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Properties
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    properties( SetAccess = private )
       blocksize  = 0;  % Blocksize (square)
       inputdims  = []; % Dimensions of the input      
    end % Properties

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Methods
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    methods
  
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Constructor
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function op = opBlockDCT(m,n,k)
           
           if (m/k) ~= round(m/k) || (n/k) ~= round(n/k)
              error('Block size must divide data dimensions.');
           end
            
           op = op@opSpot('BlockDCT',m*n,m*n);
           op.inputdims  = [m,n];
           op.blocksize  = k;
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
          k   = op.blocksize;
          
          y = full(reshape(x,m,n));
          z = zeros(m,n);
          if mode == 1
             for i=1:m/k
                 for j=1:n/k
                    blk = y((i-1)*k+(1:k),(j-1)*k+(1:k));
                    blk = dct(blk);
                    z((i-1)*k+(1:k),(j-1)*k+(1:k)) = dct(blk')';
                 end
             end             
          else
             for i=1:m/k
                 for j=1:n/k
                    blk = y((i-1)*k+(1:k),(j-1)*k+(1:k));
                    blk = idct(blk);
                    z((i-1)*k+(1:k),(j-1)*k+(1:k)) = idct(blk')';
                 end
             end             
          end
          z = z(:);
       end % function multiply

    end % methods - protected
        
end % Classdef
