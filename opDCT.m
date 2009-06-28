%opDCT  Discrete cosine transform (DCT)
%
%   opDCT(M) creates a one-dimensional discrete cosine transform
%   operator for vectors of length M.
%
%   opDCT(M,N) creates a two-dimensional discrete cosine transform
%   operator for matrices of size M-by-N. Input and output of the
%   matrices is done in vectorized form.

%   Copyright 2009, Ewout van den Berg and Michael P. Friedlander
%   http://www.cs.ubc.ca/labs/scl/sparco
%   $Id$

classdef opDCT < opSpot
    
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
        function op = opDCT(m,n)
           if nargin < 1 || nargin > 2
              error('Invalid number of arguments.');
           end
           if nargin < 2 || isempty(m)
              n = 1;
           end
           if ~isscalar(m) || m~=round(m) || m <= 0
              error('First argument to opDCT must be a positive integer.');
           end
           if ~isscalar(n) || n~=round(n) || n <= 0
              error('Second argument to opDCT must be a positive integer.');
           end
           
           op = op@opSpot('DCT',m*n,m*n);
           if n == 1 || m == 1
              % 1D-transform
              op.funHandle = @op.multiply1D;
           else
              % 2D-transform
              op.funHandle = @op.multiply2D;
           end
           op.inputdims = [m, n];           
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % plot. Really only a pedagocial tool, and only practical to
        % execute for DCTs that have less than, say, a dozen columns.
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function plot(op)
    
           colormap('gray');
           mSig = op.inputdims(1);
           nSig = op.inputdims(2);
           x    = zeros(mSig*nSig,1);
           if nSig == 1
              % For 1-dim.
              for i=1:mSig
                  x(i) = 1;
                  y    = op'*x;
                  x(i) = 0;
                  subplot(mSig,1,i);
                  plot(y); ylim([-0.5, +0.5]);
                  axis off;
              end
           else
              % For 2-dim: create image with single pixel.
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
          y = op.funHandle(x,mode);
       end % function multiply

    end % methods - protected
       
    methods( Access = private )
       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       % Multiply - 1D
       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       function y = multiply1D(op,x,mode)
          if mode == 1
             y = dct(full(x));
          else
             y = idct(full(x));
          end
       end % function multiply1D

       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       % Multiply - 2D
       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       function y = multiply2D(op,x,mode)
          m = op.inputdims(1);
          n = op.inputdims(2);
          if mode == 1
             y = dct(full(reshape(x,m,n)));
             y = dct(y')';
             y = y(:);
          else
             y = idct(full(reshape(x,m,n)));
             y = idct(y')';
             y = y(:);
          end
       end % function multiply2D

    end % methods - private
        
end % Classdef
