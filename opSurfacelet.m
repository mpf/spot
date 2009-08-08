classdef opSurfacelet < opSpot
%opSurfacelet  Surfacelet transformation
%
%   OP = opSurfacelet(DIMS,PYRAMIDMODE,LEVELARRAY,HRGFILTER,OPTIONS...)
%   DIMS:        is an array containing the dimensions of the
%                data. 
%
%   PYRAMIDMODE: type of multiscale pyramid, corresponding to
%                different levels of redundancy. In 3-D, the
%                redundancy factors are:
%                1:       ~ 6.4
%                1.5:     ~ 4.0
%                2:       ~ 3.4
%
%   LEVELARAY:   an L by 1 cell array, with each cell being an N by
%                N matrix for NDFB decomposition.
%                - For matrices, the k-th row vector specifies the
%                  subsequent decomposition levels for the k-th
%                  hourglass subband. The individual elements must
%                  be greater than or equal to 0, except the diagonal
%                  elements, which should be -1.
%
%   HRGFILTER:   filter name for the hourglass filter
%                bank. Currently the only supported type is 'ritf'
%                (rotational-invariant tight frame defined in the
%                Fourier domain).
%
%   Optional inputs: fine-tuning the NXDFB transform
%                'bo':    the order of the checkerboard filters.
%                         Default: bo = 12 
%   
%               'msize':  size of the mapping kernel. This controls
%                         the quality of the hourglass
%                         filters. Default = 15;
%   
%               'beta':   beta value of the Kaiser window. This
%                         controls the quality of the hourglass
%                         filters. Default = 2.5;
%
%               'lambda': the parameter lambda used in the
%                         hourglass filter design. Default = 4;
%
%   This operator provides an interface to the SurfBox code
%   developed by Yue Lu and Minh N. Do:
%
%   [1] Y. M. Lu and M. N. Do, Multidimensional Directional Filter
%       Banks and Surfacelets, IEEE Transactions on Image
%       Processing, vol. 16, no. 4, April 2007.

%   Copyright 2009, Ewout van den Berg and Michael P. Friedlander
%   http://www.cs.ubc.ca/labs/scl/spot

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Properties
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    properties (SetAccess = private)
       funHandle = []; % Multiplication function
    end % Properties


    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Methods
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    methods

       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       % Constructor
       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       function op = opSurfacelet(dims, pyramidMode, levelArray, HRGfilter, varargin)

          % Check parameters
          if nargin < 3, levelArray = [];     end;
          if nargin < 4, HRGfilter  = 'ritf'; end;
       
          % Number of dimensions
          nDims = length(dims);

          if isempty(levelArray) && nDims == 2
             % Construct a default one that matched curvelets
             levelArray = cell(1, 4);  
             levelArray{1} = [-1 5; 5 -1];  
             levelArray{2} = [-1 4; 4 -1];
             levelArray{3} = [-1 4; 4 -1];
             levelArray{4} = [-1 3; 3 -1];
          end

          if isempty(HRGfilter)
             HRGfilter = 'ritf';
          end

          % Store additional options
          if ~isempty(varargin)
             options = varargin;
          else
             options = {};
          end

          % Apply the decomposition operator once to get recInfo
          [dummy,recInfo] = ...
              SurfBox.Matlab.Surfdec...
              (zeros(dims),pyramidMode,levelArray,HRGfilter,options{:});

          % Get structure of dummy
          [dummy, structureInfo] = SurfBox.Matlab.surf_coeff2vec(dummy);
          coefLength = length(dummy);

          % Create operator
          fun = @(x,mode) opSurfacelet_intrnl(dims,pyramidMode,levelArray, HRGfilter, ...
                                              recInfo, structureInfo, options, ...
                                              x, mode);
          fun   = @(x,mode) opCurvelet_intrnl(parms{:},x,mode);

          % Construct operator
          op = op@opSpot('Surfacelet', coefLength, prod(dims));
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


function y = opSurfacelet_intrnl(dims, pyramidMode, levelArray, HRGfilter, ...
                                 recInfo, structureInfo, options, ...
                                 x, mode)

if mode == 1
   % Apply analysis operator
   x = reshape(x,dims);
   if ~isreal(x)
      z1 = SurfBox.Matlab.Surfdec(real(x),pyramidMode,levelArray,HRGfilter,options{:});
      z1 = SurfBox.Matlab.surf_coeff2vec(z1);
      z2 = SurfBox.Matlab.Surfdec(imag(x),pyramidMode,levelArray,HRGfilter, options{:});
      z2 = sufracelet.surf_coeff2vec(z2);
      y  = z1 + sqrt(-1) * z2;
   else
      y  = SurfBox.Matlab.Surfdec(x,pyramidMode,levelArray,HRGfilter,options{:});
      y  = SurfBox.Matlab.surf_coeff2vec(y);
   end
else
   % Apply synthesis operator
   if ~isreal(x)
     z1 = surf_vec2coeff(real(x), structureInfo);
     z1 = SurfBox.Matlab.Surfrec(z1,recInfo);
     z2 = surf_vec2coeff(imag(x), structureInfo);
     z2 = SurfBox.Matlab.Surfrec(z2,recInfo);
     y  = z1 + sqrt(-1) * z2;
   else
     y  = surf_vec2coeff(x, structureInfo);
     y  = SurfBox.Matlab.Surfrec(y,recInfo);
   end
   y = reshape(y,prod(dims),1);
end
end
