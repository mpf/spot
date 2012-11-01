classdef opCurvelet3d < opSpot
%OPCURVELET3D  Three-dimensional curvelet operator.
%
%   opCurvelet3d(M,N,P,NBSCALES,NBANGLES,FINEST,IS_REAL) creates a
%   three-dimensional curvelet operator for M by N by P matrices. The
%   curvelet transform is computed using the Curvelab code.
%
%   The remaining four parameters are optional; NBSCALES gives the number
%   of scales and is set to max(1,ceil(log2(min(M,N,P)) - 3)) by default,
%   as suggested by Curvelab. NBANGLES gives the number of angles at the
%   second coarsest level which must be a multiple of four with a minimum
%   of 8. By default NBANGLES is set to 16. FINEST sets whether to include
%   the finest scale of coefficients and is set to 0 by default; set this
%   to 1 to include the finest scale, or to 2 to keep the finest scale but
%   set it to zeros. IS_REAL set whether the to keep the complex 
%   coefficients or not and is set to 1 by default.
%
%   See also CURVELAB.

%   Nameet Kumar - Oct 2010
%   Copyright 2009, Gilles Hennenfent, Ewout van den Berg and Michael P. Friedlander
%   See the file COPYING.txt for full copyright information.
%   Use the command 'spot.gpl' to locate this file.

%   http://www.cs.ubc.ca/labs/scl/spot

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Properties
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    properties (SetAccess = protected)
       nbscales;
       nbangles;
       finest;   
       header;          %sizes of coefficient vectors
       nbcoeffs;           %total number of coefficients
       dims;           %size of curvelet
       
    end % Properties

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Methods
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    methods

       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       % Constructor
       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       function op = opCurvelet3d(m,n,p,nbscales,nbangles,finest,is_real)

          assert( isscalar(m) && isscalar(n) && isscalar(p),['Please ensure'...
            ' sizes are scalar values']);
          if nargin < 4, nbscales = max(1,ceil(log2(min([m,n,p]))-3)); end;
          if nargin < 5, nbangles = 16;                              end;
          if nargin < 6, finest = 0;                      end;
          if nargin < 7, is_real = 1;                                end;
          assert( isscalar(nbscales) && isscalar(nbangles),['Please ensure'...
             ' nbscales and nbangles are scalar values']);
          assert( (any(finest == [0 1 2])) && (is_real==0||is_real==1),...
             'Please ensure finest and is_real are appropriate values');

          % Compute length of curvelet coefficient vector
          [tmphdr, cn] = fdct3d_sizes_mex(m,n,p,nbscales,nbangles,logical(finest)); 
          hdr = cell(nbscales,1);
          hdr{1} = {[tmphdr{1:3}]};
          for i = 2:nbscales - (~finest)
             j = 4 + 10*(i - 2);
             hdr{i} = {[tmphdr{j+1:j+3}];[tmphdr{j+4:j+6}];...
                [tmphdr{j+7:j+9}];[tmphdr{j}]};
          end
          if ~finest,    hdr{end} = {[tmphdr{end-2:end}];1};         end;
          
          % Construct operator
          op = op@opSpot('Curvelet3d', cn, m*n*p);
          op.cflag    = ~is_real;
          op.nbscales = nbscales;
          op.nbangles = nbangles;
          op.finest   = finest;
          op.header   = hdr;
          op.nbcoeffs = cn;
          op.dims     = [m,n,p];
          op.ns       = [m,n,p];
       end % Constructor

       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       % rrandn             
       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       % overloaded to produce a vector that really falls in the range of op
       function y = rrandn(op)
          y = op.drandn;
          y = multiply(op,y,1);
       end
       
    end % Methods
       
 
    methods ( Access = protected )
       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       % Multiply
       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       function x = multiply(op,x,mode)
         
          if mode == 1
            % Analysis mode
            x = fdct3d_forward_mex(op.dims(1),op.dims(2),op.dims(3),...
               op.nbscales,op.nbangles,logical(op.finest),reshape(x,op.dims));
            if op.finest == 2, zero_finest_scale; end
            if ~op.cflag
               x = fdct_wrapping_c2r(x);
            end
            x = spot.utils.fdct_c2v(x,op.nbcoeffs);
          else
            % Synthesis mode  
            x = spot.utils.fdct_v2c(x,op.header);
            if op.finest == 2, zero_finest_scale; end
            if ~op.cflag
               x = fdct_wrapping_r2c(x);
            end
            x = fdct3d_inverse_mex(op.dims(1),op.dims(2),op.dims(3),...
               op.nbscales,op.nbangles,logical(op.finest),x);
            if ~op.cflag
               x = real(x);
            end
            x = x(:);
          end
         
         
          %%% Nested Function
          function zero_finest_scale
             for i = 1:length(x{end})
               x{end}{i} = zeros( size( x{end}{i} ) );
             end
          end
         
       end % Multiply          

    end % Methods
   
end % Classdef