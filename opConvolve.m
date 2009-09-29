classdef opConvolve < opSpot
%OPCONVOLVE   One and two dimensional convolution operator.
%
%   opConvolve(M,N,KERNEL,OFFSET,MODE) creates an operator for one or
%   two-dimensional convolution, depending on the size of the KERNEL,
%   and the matrix or vector (MxN) the convolution is applied to. The
%   convolution is one dimensional only if KERNEL is a column vector
%   and N=1, or KERNEL is a row vector and M=1. The OFFSET parameter
%   determines the center of the KERNEL and has a default value of
%   [1,1]. When the OFFSET lies outside the size of the KERNEL, the
%   KERNEL is embedded in a zero matrix/vector with appropriate
%   center. For one-dimensional convolution, KERNEL may be a
%   scalar. Specifying an offset that is not equal to one where the
%   corresponding size of the kernel does equal one leads to the
%   construction of a two-dimensional convolution operator. There are
%   three types of MODE:
% 
%   MODE = 'regular'   - convolve input with kernel;
%          'truncated' - convolve input with kernel, but keep only
%                        those MxN entries in the result that
%                        overlap with the input;
%          'cyclic'    - do cyclic convolution of the input with a
%                        kernel that is wrapped around as many
%                        times as needed.
%
%   The output of the convolution operator, like all other
%   operators, is in vector form.

%   Copyright 2009, Ewout van den Berg and Michael P. Friedlander
%   See the file COPYING.txt for full copyright information.
%   Use the command 'spot.gpl' to locate this file.

%   http://www.cs.ubc.ca/labs/scl/spot

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Properties
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    properties (SetAccess = private)
       funHandle     % Multiplication function
    end % Properties

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Methods
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    methods

       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       % Constructor
       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       function op = opConvolve(m,n,kernel,offset,mode)

          if nargin < 3
             error('opConvolve requires at least three parameters.');
          end

          if nargin < 4, offset = [];  end;
          if nargin < 5, mode = 'regular'; end;

          switch lower(mode)
             case {'cyclic'}
                cyclic = true; truncated = false;
    
             case {'truncated'}
                cyclic = false; truncated = true;
    
             case {'default','regular',''}
                cyclic = false; truncated = false;
    
             otherwise
                error('Mode parameter must be one of ''regular'', ''cyclic'', or ''truncated''.');
          end

          % Check if one-dimensional convolution applies
          if (n == 1 && size(kernel,2) == 1) || (m == 1 && size(kernel,1) == 1)
             convolveOneDim = true;
             if length(offset) >= 2
                if ((n == 1 && size(kernel,2) == 1 && offset(2) ~= 1) || ...
                    (m == 1 && size(kernel,1) == 1 && offset(1) ~= 1))
                   convolveOneDim = false;
                else
                   offset = offset(1) * offset(2);
                end
             end
          else
             convolveOneDim = false;
             if length(offset) < 2
                error('The offset parameter needs to contain at least two entries.');
             end
          end


          if convolveOneDim
             % ========= One-dimensional case =========
   
             % Get basic information
             if isempty(offset), offset = 1; end;
             offset = offset(1);
             kernel = kernel(:);
             k      = length(kernel);
             cflag  = ~isreal(kernel);

             if cyclic
                % ========= Cyclic =========
      
                % Ensure offset lies between 1 and m
                offset = rem(offset-1,m)+1;
                if offset <= 0, offset = offset + m; end;

                % Wrap around or zero-pad kernel as needed
                if k > m
                   % Wrap around however many times needed
                   kernel = [kernel; zeros(rem(m-rem(k,m),m),1)];
                   kernel = sum(reshape(kernel,m,length(kernel)/m),2);
                   k = m;
                else
                    % Pad with zeros
                    kernel = [kernel; zeros(m-k,1)];
                    k = m;
                end
      
                % Apply cyclic shift to correct for offset
                kernel = [kernel(offset:end); kernel(1:offset-1)];
      
                % Precompute kernel in frequency domain
                fKernel = fft(full(kernel));

                % Create function handle and determine operator size
                fun   = @(x,mode) opConvolveCircular1D_intrnl(fKernel,cflag,x,mode);
                nRows = m;
                nCols = m;
             else
                % ========= Regular or truncated convolution =========

                % Zero pad kernel if offset lies outside range
                if offset < 1
                   kernel = [zeros(1-offset,1); kernel];
                   offset = 1;
                   k = length(kernel);
                end
                if offset > k
                   kernel = [kernel; zeros(offset-k,1)];
                   k = length(kernel);
                end

                % Shift kernel and add internal padding
                kernel = [kernel(offset:end);zeros(m-1,1);kernel(1:offset-1)];
                if truncated
                   idx = 1:m;
                else
                   idx = [length(kernel)-(offset-2):length(kernel), 1:(m+k-offset)];
                end

                % Precompute kernel in frequency domain
                fKernel = fft(full(kernel));
   
                % Create function handle and determine operator size
                fun   = @(x,mode) opConvolve1D_intrnl(fKernel,k,m,idx,cflag,x,mode);
                nRows = length(idx);
                nCols = m;
             end   
          else
             % ========= Two-dimensional case =========

             % Get basic information
             if isempty(offset), offset = [1,1]; end;
             if length(offset) < 2
                error('Offset parameter for 2D convolution needs to contain two entries.');
             end
             offset = offset(1:2);
             k      = [size(kernel,1),size(kernel,2)];
             cflag  = ~isreal(kernel);

             if cyclic
                % ========= Cyclic =========
      
                % Ensure offset(1) lies between 1 and m
                offset(1) = rem(offset(1)-1,m)+1;
                if offset(1) <= 0, offset(1) = offset(1) + m; end;

                % Ensure offset(2) lies between 1 and n
                offset(2) = rem(offset(2)-1,n)+1;
                if offset(2) <= 0, offset(2) = offset(2) + n; end;

                % Wrap around kernel and zero pad if needed
                newKernel = zeros(m,n);
                for i=0:ceil(k(1)/m)-1
                   idx1 = 1:min(m,k(1)-i*m);
                   for j=0:ceil(k(2)/n)-1
                      idx2 = 1:min(n,k(2)-j*n);
                      newKernel(idx1,idx2) = newKernel(idx1,idx2) + kernel(i*m+idx1,j*n+idx2);
                   end
                end
                kernel = newKernel;
      
                % Apply cyclic shifts to correct for offset
                kernel = [kernel(offset(1):end,offset(2):end), kernel(offset(1):end,1:offset(2)-1); ...
                          kernel(1:offset(1)-1,offset(2):end), kernel(1:offset(1)-1,1:offset(2)-1)];
      
                % Precompute kernel in frequency domain
                fKernel = fft2(full(kernel));

                % Create function handle and determine operator size
                fun   = @(x,mode) opConvolveCircular2D_intrnl(fKernel,m,n,cflag,x,mode);
                nRows = m*n;
                nCols = m*n;
             else
                % ========= Regular or truncated convolution =========

                % Zero pad kernel if offset lies outside range
                if offset(1) < 1
                   kernel = [zeros(1-offset(1),k(2)); kernel];
                   offset(1) = 1;
                   k(1) = size(kernel,1);
                end
                if offset(1) > k(1)
                   kernel = [kernel; zeros(offset(1)-k(1),k(2))];
                   k(1) = size(kernel,1);
                end

                if offset(2) < 1
                   kernel = [zeros(k(1),1-offset(2)), kernel];
                   offset(2) = 1;
                   k(2) = size(kernel,2);
                end
                if offset(2) > k(2)
                   kernel = [kernel, zeros(k(1),offset(2)-k(2))];
                   k(2) = size(kernel,2);
                end

                % Shift kernel and add internal padding
                kernel = [kernel(offset(1):end,:);zeros(m-1,k(2));kernel(1:offset(1)-1,:)];
                kernel = [kernel(:,offset(2):end),zeros(size(kernel,1),n-1),kernel(:,1:offset(2)-1)];
                if truncated
                   idx1 = 1:m;
                   idx2 = 1:n;
                else
                   idx1 = [size(kernel,1)-(offset(1)-2):size(kernel,1), 1:(m+k(1)-offset(1))];
                   idx2 = [size(kernel,2)-(offset(2)-2):size(kernel,2), 1:(n+k(2)-offset(2))];
                end
   
                % Precompute kernel in frequency domain
                fKernel = fft2(full(kernel));
                
                % Create function handle and determine operator size
                fun   = @(x,mode) opConvolve2D_intrnl(fKernel,k,m,n,idx1,idx2,cflag,x,mode);
                nRows = length(idx1) * length(idx2);
                nCols = m*n;
             end
          end

          % Construct operator
          op = op@opSpot('Convolve', nRows, nCols);
          op.cflag     = cflag;
          op.funHandle = fun;
       end % Constructor

    end % Methods
       
 
    methods ( Access = protected )
       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       % Multiply
       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       function y = multiply(op,x,mode)
          y = op.funHandle(x,mode);
       end % Multiply          

    end % Methods
   
end % Classdef


%=======================================================================


function y = opConvolve1D_intrnl(fKernel,k,m,idx,cflag,x,mode)
if mode == 1
   fx = fft([full(x);zeros(k-1,1)]);
   y  = ifft(fKernel.*fx);
   y  = y(idx);

   if (~cflag && isreal(x)), y = real(y); end;
else
   z = zeros(m+k-1,1);
   z(idx) = full(x);
   y = ifft(conj(fKernel).*fft(z));
   y = y(1:m);

  if (~cflag && isreal(x)), y = real(y); end;
end
end

%======================================================================

function y = opConvolveCircular1D_intrnl(fKernel,cflag,x,mode)
if mode == 1
   y = ifft(fKernel.*fft(full(x)));
   if (~cflag && isreal(x)), y = real(y); end;
else
   y = ifft(conj(fKernel).*fft(full(x)));
   if (~cflag && isreal(x)), y = real(y); end;
end
end

%======================================================================

function y = opConvolve2D_intrnl(fKernel,k,m,n,idx1,idx2,cflag,x,mode)
if mode == 1
   fx = fft2([full(reshape(x,m,n)), zeros(m,k(2)-1); ...
              zeros(k(1)-1,n), zeros(k(1)-1,k(2)-1)]);
   y = ifft2(fKernel.*fx);
   y = y(idx1,idx2);
   y = y(:);

   if (~cflag && isreal(x)), y = real(y); end;
else
   z = zeros(m+k(1)-1,n+k(2)-1);
   z(idx1,idx2) = full(reshape(x,length(idx1),length(idx2)));
   y = ifft2(conj(fKernel).*fft2(z));
   y = y(1:m,1:n);
   y = y(:);

  if (~cflag && isreal(x)), y = real(y); end;
end
end

%======================================================================

function y = opConvolveCircular2D_intrnl(fKernel,m,n,cflag,x,mode)
if mode == 1
   y = ifft2(fKernel.*fft2(full(reshape(x,m,n))));
   y = y(:);
   if (~cflag && isreal(x)), y = real(y); end;
else
   y = ifft2(conj(fKernel).*fft2(full(reshape(x,m,n))));
   y = y(:);
   if (~cflag && isreal(x)), y = real(y); end;
end
end
