%opWavelet   Wavelet operator
%
%   opWavelet(M,N,FAMILY) creates a Wavelet operator of given FAMILY for
%   signals of size M-by-N. The wavelet transformation is computed using
%   the Rice Wavelet Toolbox.  The values supported for FAMILY are
%   'Daubechies' and 'Haar'.
%
%   opWavelet(M,N,FAMILY,FILTER,LEVELS,REDUNDANT,TYPE) allows for four
%   additional parameters: FILTER (default 8) specifies the filter length,
%   which must be even. LEVELS (default 5) gives the number of levels in
%   the transformation. Both P and Q must be divisible by 2^LEVELS. The
%   Boolean field REDUNDANT (default false) indicates whether the wavelet
%   is redundant. TYPE (default 'min') indictates what type of solution is
%   desired; 'min' for minimum phase, 'max' for maximum phase, and 'mid'
%   for mid-phase solutions.

%   Copyright 2007-2009, Rayan Saab, Ewout van den Berg and Michael P. Friedlander
%   http://www.cs.ubc.ca/labs/scl/sparco
%   $Id$

classdef opWavelet < opSpot
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Properties
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    properties( SetAccess = private, GetAccess = public )
       family     = 'Daubechies';   % Wavelet family
       lenFilter  = 8;              % Filter length
       filter                       % Filter computed by daubcqf
       levels     = 5;              % Number of levels
       typeFilter = 'min'
       redundant  = false;          % Redundant flag
       nseg
       signal_dims                  % Dimensions of the signal domain
       funHandle                    % Multiplication function
    end % Properties

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Methods
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    methods

       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       % Constructor
       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       function op = opWavelet(p,q,family,lenFilter,levels,redundant,typeFilter)

          if nargin < 5 || isempty(levels)
             levels = 5;
          end
          if nargin >= 6 && redundant
             if p == 1 || q == 1
                nseg =   levels + 1;
             else
                nseg = 3*levels + 1;
             end
             m = p*q*nseg;
             n = p*q;
             redundant = true;
          else
             nseg = [];
             m = p*q;
             n = p*q;
             redundant = false;
          end
          
          op = op@opSpot('Wavelet', m, n);
          op.signal_dims = [p, q];
          op.levels = levels;
          op.redundant = redundant;
          op.nseg = nseg;
          
          if nargin >= 4 && ~isempty(lenFilter)
             op.lenFilter = lenFilter;
          end
          if nargin >= 7 && ischar(typeFilter)
             op.typeFilter  = typeFilter;
          end
          switch lower(family)
             case {'daubechies'}
                op.family = 'Daubechies';
                op.filter = rwt.daubcqf(op.lenFilter,op.typeFilter);
    
             case {'haar'}
                op.family = 'Haar';
                op.filter = rwt.daubcqf(0);
                
             otherwise
                error('Wavelet family %s is unknown.', family);
          end

          % Initialize function handle
          if redundant
             op.funHandle = @matvec_redundant;
          else
             op.funHandle = @matvec;
          end
          
       end % function opWavelet

    end % Methods
    
    methods( Access = protected )
       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       % Multiply
       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       function y = multiply(op,x,mode)
          y = op.funHandle(op,x,mode);
       end % function multiply          

       function y = matvec(op,x,mode)
          p = op.signal_dims(1);
          q = op.signal_dims(2);
          levels = op.levels; filter = op.filter;
          if issparse(x), x = full(x); end
          Xmat = reshape(x,p,q);
          if mode == 1
             if isreal(x)
                y  = rwt.mdwt(Xmat, filter, levels);
             else
                y1 = rwt.mdwt(real(Xmat), filter, levels);
                y2 = rwt.mdwt(imag(Xmat), filter, levels);
                y  = y1 + sqrt(-1) * y2;
             end
             y = y(:);
          else
             if isreal(x)
                y = rwt.midwt(Xmat, filter, levels);
             else
                y1 = rwt.midwt(real(Xmat), filter, levels);
                y2 = rwt.midwt(imag(Xmat), filter, levels);
                y  = y1 + sqrt(-1) * y2;
             end
             y = y(:);
          end
       end
       
       function y = matvec_redundant(op,x,mode)
          p = op.signal_dims(1);
          q = op.signal_dims(2);
          nseg = op.nseg;
          levels = op.levels; filter = op.filter;
          if issparse(x), x = full(x); end
          if mode == 1
             Xmat = reshape(x,p,q);
             if isreal(x)
                [yl,yh] = rwt.mrdwt(Xmat, filter, levels);
                y = [yl,yh];
             else
                [yl1,yh1] = rwt.mrdwt(real(Xmat), filter, levels);
                [yl2,yh2] = rwt.mrdwt(imag(Xmat), filter, levels);
                y = [yl1,yh1] + sqrt(-1) * [yl2,yh2];
             end
             y = y(:);
          else
             xl = reshape(x(1:p*q),p,q);
             xh = reshape(x(p*q+1:end),p,(nseg-1)*q);
             if isreal(x)
                y = rwt.mirdwt(xl, xh, filter, levels);
             else
                y1 = rwt.mirdwt(real(xl), real(xh), filter, levels);
                y2 = rwt.mirdwt(imag(xl), imag(xh), filter, levels);
                y = y1 + sqrt(-1) * y2;
             end
             y = y(:);
          end
       end
       
    end % Methods

end % Classdef
