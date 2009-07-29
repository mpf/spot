%opDCT2  Two-dimensional discrete cosine transform (DCT)
%
%   opDCT2(M,N) creates a two-dimensional discrete cosine transform
%   operator for matrices of size M-by-N. Input and output of the
%   matrices is done in vectorized form.

%   Copyright 2009, Ewout van den Berg and Michael P. Friedlander
%   http://www.cs.ubc.ca/labs/scl/sparco
%   $Id: opDCT.m 14 2009-06-28 17:55:58Z mpf $

classdef opDCT2 < opSpot
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Properties
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    properties( SetAccess = private )
       funHandle = []; % Multiplication function
       inputdims = []; % Dimensions of the input      
    end % Properties

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Methods
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    methods
  
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Constructor
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function op = opDCT2(m,n)
           if nargin ~= 2
              error('Invalid number of arguments.');
           end
           if ~isscalar(m) || m~=round(m) || m <= 0
              error('First argument to opDCT2 must be a positive integer.');
           end
           if ~isscalar(n) || n~=round(n) || n <= 0
              error('Second argument to opDCT2 must be a positive integer.');
           end
           
           op = op@opSpot('DCT2',m*n,m*n);
           op.inputdims = [m,n];           
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % spy. Really only a pedagogical tool, and only practical to
        % execute for DCTs that have less than, say, a dozen columns.
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function spy(op)
    
           colormap('gray');
           mSig = op.inputdims(1);
           nSig = op.inputdims(2);
           x    = zeros(mSig*nSig,1);

           % Create image with single pixel.
           k = 0;
           for i=1:mSig
               for j=1:nSig
                   k    = k + 1;
                   x(k) = 1;
                   y    = op'*x;
                   x(k) = 0;
                   subplot(nSig,mSig,k);
                   imagesc(reshape(y,mSig,nSig));
                   axis square; axis off;
               end
           end
        end % function plot

    end % Methods
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Methods - protected
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    methods( Access = protected )

       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       % Multiply
       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       function y = multiply(op,x,mode)
          m = op.inputdims(1);
          n = op.inputdims(2);
          if mode == 1
             y = spot.utils.dct(full(reshape(x,m,n)));
             y = spot.utils.dct(y')';
             y = y(:);
          else
             y = spot.utils.idct(full(reshape(x,m,n)));
             y = spot.utils.idct(y')';
             y = y(:);
          end
       end % function multiply

    end % methods - protected
        
end % Classdef
