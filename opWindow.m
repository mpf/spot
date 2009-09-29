classdef opWindow < opSpot
%OPWINDOW   Diagonal window matrix.
%
%   opWindow(D) creates an operator for multiplication by the
%   diagonal matrix with D on its diagonal.
%
%   opWindow(N,FAMILY,VARARGIN) creates an N by N diagonal matrix with
%   diagonal entries given by the window function of given family and
%   optional additional parameters.
%
%   Family                 Optional parameters
%   ---------------------  ----------------------------------------
%   Bartlett               -
%   Bartlett-Hann          -
%   Blackman               alpha = 0.16;
%   Blackman-Harris        -
%   Blackman-Nuttall       -
%   Bohman                 -
%   Cauchy                 alpha = 3;
%   Cos                    (see Cosine)
%   Cosine                 alpha = 1;
%   Dirichlet              -
%   Flattop                -
%   Gauss                  (see Gaussian)
%   Gaussian               alpha = 2.5;
%   Hamming                -
%   Hann                   -
%   Hann-Poisson           alpha = 1;
%   Kaiser                 alpha = 0.5;
%   Kaiser-Bessel Derived  alpha = 0.5;
%   KBD                    (see Kaiser-Bessel Derived)
%   Lanczos                alpha = 1;
%   Triangle               -
%   Parzen                 -
%   Poisson                alpha = 1;
%   Rectangle              (see Dirichlet)
%   Sinc                   (see Lanczos)
%   Tukey                  alpha = 0.5;
%   Uniform                (see Dirichlet)
%   Valle-Poussin          (see Parzen)
%   Weierstrasss           (see Gaussian)
%
%   See also opDiag.

%   Copyright 2009, Ewout van den Berg and Michael P. Friedlander
%   See the file COPYING.txt for full copyright information.
%   Use the command 'spot.gpl' to locate this file.

%   http://www.cs.ubc.ca/labs/scl/spot

% See also
% [1] Harris, F. J. "On the Use of Windows for Harmonic Analysis
%     with the Discrete Fourier Transform.", Proceedings of the
%     IEEE. Vol. 66 (January 1978). pp. 51-84.

% [2] Gade, Svend and H. Herlufsen, "Use of Weighting Functions in
%     DFT/FFT Analysis (Part I)," Bruel & Kjaer, Windows to FFT
%     Analysis, (Part I) Technical Review, No. 3, 1987, pp. 19-21.

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Properties
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    properties (SetAccess = private)
       family    = ''; % Window family
       window    = []; % Window function vector
       funHandle = []; % Multiplication function
    end % Properties


    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Methods
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    methods

       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       % Constructor
       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       function op = opWindow(varargin)

          if nargin < 1
            error('opWindow requires at least one parameters.');
          end

          % Create the window
          [window,family] = opWindowFunction_intrnl(varargin{:});
          fun = @(x,mode) opWindow_intrnl(window,x,mode);
       
          % Construct operator
          n  = length(window);
          op = op@opSpot('Window', n, n);
          op.cflag     = ~isreal(window);
          op.funHandle = fun;
          op.family    = family;
          op.window    = window;
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


function y = opWindow_intrnl(window,x,mode)
if (mode == 1)
   y = window.*x;
else
   y = conj(window).*x;
end
end

%======================================================================

function [d,family] = opWindowFunction_intrnl(varargin)

if (nargin == 1) && (isnumeric(varargin{1}) || issparse(varargin{1}))
   family = 'Custom';
   d      = varargin{1};
   d      = d(:); % Ensure d is a column vector
   N      = length(d);
elseif (nargin >= 2) && (ischar(varargin{2}) && spot.utils.isposintscalar(varargin{1}))
   family = varargin{2};
   N = varargin{1};
   d = zeros(N,1);
   n = 0:N-1;
   k = abs(2*n/(N-1) - 1);
   symmetric = 1; % symmetric by default

   switch(lower(family))
      case {'bartlett'}
                family = 'Bartlett';
                d(1:N) = 1 - abs(2*n/(N-1) - 1);
    
      case {'bartlett-hann'}
                family = 'Barlett-Hann';
                a0 = 0.62; a1 = 0.48; a2 = 0.38;
                d(1:N) = a0 - a1 * abs(n / (N-1) - 1/2) ...
                            - a2 * cos(2*pi*n/(N-1));
    
      case {'blackman'}
                family = 'Blackman';
                alpha = 0.16;
                if nargin > 2, alpha = varargin{3}; end;
                a0 = (1 - alpha) / 2; a1 = 1/2; a2 = alpha / 2;
                d(1:N) = a0 - a1 * cos(2*pi*n/(N-1)) ...
                            + a2 * cos(4*pi*n/(N-1));
                
      case {'blackman-harris'}
                family = 'Blackman-Harris';
                a0 = 0.35875; a1 = 0.48829; a2 = 0.14128; a3 = 0.01168;
                d(1:N) = a0 - a1 * cos(2*pi*n/(N-1)) ...
                            + a2 * cos(4*pi*n/(N-1)) ...
                            - a3 * cos(6*pi*n/(N-1));

      case {'blackman-nuttall'}
                family = 'Blackman-Nuttall';
                a0 = 0.3635819; a1 = 0.4891775; a2 = 0.1365995; a3 = 0.0106411;
                d(1:N) = a0 - a1 * cos(2*pi*n/(N-1)) ...
                            + a2 * cos(4*pi*n/(N-1)) ...
                            - a3 * cos(6*pi*n/(N-1));
       
      case {'bohman'}
                family = 'Bohman';
                d(1:N) = (1 - k).*cos(pi*k) + 1/pi * sin(pi*k);
                d(1)   = 0;
                d(N)   = 0;
    
      case {'cauchy'}
                family = 'Cauchy';
                alpha = 3;
                if nargin > 2, alpha = varargin{3}; end;
                d(1:N) = 1./(1 + (alpha * k).^2);
    
      case {'cosine','cos'}
                family = 'Cosine';
                alpha = 1;
                if nargin > 2, alpha = varargin{3}; end;
                d(1:N) = power(cos(k*pi/2),alpha);
    
      case {'dirichlet','rectangle','uniform'}
                family = 'Rectangle';
                d(1:N) = 1;

      case {'flattop','flat top'}
                family = 'FlatTop';
                a0 = 1; a1 = 1.93; a2 = 1.29; a3 = 0.388; a4 = 0.032;
                s = a0 + a1 + a2 + a3 + a4;
                a0 = a0 / s; a1 = a1 / s; a2 = a2 / s; a3 = a3 / s; a4 = a4 / s;
                
                d(1:N) = a0 - a1 * cos(2*pi*n/(N-1)) ...
                            + a2 * cos(4*pi*n/(N-1)) ...
                            - a3 * cos(6*pi*n/(N-1));
                            + a4 * cos(8*pi*n/(N-1));

      case {'gaussian','gauss','weierstrass'}
                family = 'Gaussian';
                alpha = 2.5;
                if nargin > 2, alpha = varargin{3}; end;
                if (alpha < 0)
                   error('Alpha parameter for Gaussian window must be positive.');
                end
                d(1:N) = exp(-0.5 * (alpha * k).^2);
     
      case {'hamming'}
                family = 'Hamming';
                a0 = 0.54; a1 = 0.46;
                d(1:N) = a0 - a1 * cos(2*pi*n/(N-1));

      case {'hann'}
                family = 'Hann';
                d(1:N) = (1 - cos(2*pi*n/(N-1))) / 2;
    
      case {'hann-poisson'}
                family = 'Hann-Poisson';
                alpha = 1.0;
                if nargin > 2, alpha = varargin{3}; end;
                d(1:N) = (1 + cos(pi*k)) .* exp(-alpha*k) / 2;
       
      case {'kaiser'}
                family = 'Kaiser';
                alpha = 0.5;
                if nargin > 2, alpha = varargin{3}; end;
                
                w = abs(besseli(0,alpha));
                if mod(N,2) == 0
                   % Even number of points
                   M = round(N/2);
                   d(1:M) = besseli(0,alpha * sqrt(1 - (2*(0:M-1)/(N-1) - 1).^2));
                   d(M+(M:-1:1)) = d(1:M);
                else
                   % Odd number of points
                   M = round((N-1)/2);
                   d(1:M+1) = besseli(0,alpha * sqrt(1 - (2*(0:M)/(N-1) - 1).^2));
                   d(M+1+(M:-1:1)) = d(1:M);
                end
                d = abs(d) / w;
    
      case {'kaiser-bessel derived','kbd'}
                family = 'KBD';
                alpha = 0.5;
                if nargin > 2, alpha = varargin{3}; end;

                if mod(N,2) == 1
                   error('The Kaiser-Bessel derived window requires an even number of points.');
                end

                M = round(N/2); cumval = 0;
                v = opWindowFunction_intrnl('Kaiser',M+1,alpha);
                v = cumsum(v);

                % Mirror and normalize
                d(1:M)      = sqrt(v(1:M) / v(M+1));
                d(N:-1:M+1) = d(1:M);
 
      case {'lanczos','sinc'}
                family = 'Lanczos';
                alpha = 1;
                if nargin > 2, alpha = varargin{3}; end;

                d(1:N) = sin(pi*k) ./ (pi*k);
                if mod(N,2) ~= 0
                   % Fix singularity
                   d(ceil(N/2)) = 1;
                end
                d = power(d,alpha);
    
      case {'nuttall'}
                family = 'Nuttall';
                a0 = 0.355768; a1 = 0.487396; a2 = 0.144232; a3 = 0.012604;
                d(1:N) = a0 - a1 * cos(2*pi*n/(N-1)) ...
                            + a2 * cos(4*pi*n/(N-1)) ...
                            - a3 * cos(6*pi*n/(N-1));

      case {'parzen','valle-poussin'}
                family = 'Valle-Poussin';
                n1 = floor((N-1.5)/4);
                n2 = N-n1-1;
                k1 = abs((0:n1) - (N-1) / 2);
                k2 = abs((n1+1:n2-1) - (N-1) / 2);
                d1 = 2 * power(1 - 2 * k1/N,3);
                d2 = 1 - 6 * power(2 * k2/N,2) .* (1 - 2 * k2/N);
                d(1:N) = [d1, d2, d1(end:-1:1)];
                
      case {'poisson'}
                family = 'Poisson';
                alpha = 1;
                if nargin > 2, alpha = varargin{3}; end;
                d(1:N) = exp(-alpha*k);
                
      case {'riemann'}
                family = 'Riemann';
                d(1:N) = sin(pi*k) ./ (pi*k);
                if mod(N,2) ~= 0
                   d(ceil(N/2)) = 1; % Fix singularity
                end

      case {'riesz'}
                family = 'Riesz';
                d(1:N) = 1 - k.^2;
     
      case {'triangle'}
                family = 'Triangle';
                if mod(N,2) == 0
                   d(1:N) = 1 - abs(2*n/N - (N-1)/N);
                else
                   d(1:N) = 1 - abs((n+1) * 2/(N+1) - 1);
                end
                
      case {'tukey'}
                family = 'Tukey';
                alpha = 0.5;
                if nargin > 2, alpha = varargin{3}; end;
                if (alpha <= 0) || (alpha >= 1)
                   error('The alpha in the Tukey window has to lie between [0,1].');
                end

                n1 = floor(alpha * (N-1)/2) + 1;
                n2 = N - 2*n1;

                d1 = (1 + cos(2*pi*(0:n1-1)' / (alpha * (N-1)) - pi))/2;
                d(1:N) = [d1; ones(n2,1); d1(end:-1:1)];
   end
   
   if symmetric
      if mod(N,2) == 0
         d(N/2+1:end) = d(N/2:-1:1);
      else
         d((N+1)/2+1:end) = d((N-1)/2:-1:1);
      end      
   end
else
   error('Invalid parameters to opWindow, see help for details.');
end
end
