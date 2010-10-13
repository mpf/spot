classdef opCurvelet < opSpot
%OPCURVELET  Two-dimensional curvelet operator.
%
%   opCurvelet(M,N,NBSCALES,NBANGLES,TTYPE) creates a two-dimensional
%   curvelet operator for M by N matrices. The curvelet transform is
%   computed using the Curvelab code.
%
%   The remaining three parameters are optional; NBSCALES gives the
%   number of scales and is set to max(1,ceil(log2(min(M,N)) - 3)) by
%   default, as suggested by Curvelab. NBANGLES gives the number of
%   angles at the second coarsest level which must be a multiple of
%   four with a minimum of 8. By default NBANGLES is set to 16. TTYPE
%   determines the type of transformation and is set to 'WRAP' by
%   default.
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
       finest = 1;   %currently not adjustable, but put it here for view
       header;          %sizes of coefficient vectors
       nbcoeffs;           %total number of coefficients
       dims;           %size of curvelet
       ttype;           %type of transformation
       
    end % Properties

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Methods
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    methods

       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       % Constructor
       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       function op = opCurvelet(m,n,nbscales,nbangles,ttype)

          if nargin < 3, nbscales = max(1,ceil(log2(min(m,n)) - 3)); end;
          if nargin < 4, nbangles = 16;                              end;
          if nargin < 5, ttype = 'WRAP';                             end; % Wrapping

          finest  = 1;
          is_real = 1;

          % Compute length of curvelet coefficient vector
          if strcmp(ttype,'ME')
             C = mefcv2(randn(m,n),m,n,nbscales,nbangles);

             hdr{1}{1} = size(C{1}{1});
             cn = prod(hdr{1}{1});
             for i = 2:nbscales
                nw = length(C{i});
                hdr{i}{1} = size(C{i}{1});
                hdr{i}{2} = size(C{i}{nw/2+1});
                cn = cn + nw/2*prod(hdr{i}{1}) + nw/2*prod(hdr{i}{2});
             end
          else
             [tmphdr, cn] = fdct_sizes_mex(m,n,nbscales,nbangles,finest);
             hdr = cell(1,nbscales);
             hdr{1} = {[tmphdr{1:2}]}; 
             for i = 2:nbscales
                j = 3 + 5*(i-2);
                hdr{i}={[tmphdr{j+1:j+2}];[tmphdr{j+3:j+4}];[tmphdr{j}]};
             end
          end

          % Construct operator
          op = op@opSpot('Curvelet', cn, m*n);
          op.cflag     = ~is_real;
          op.nbscales = nbscales;
          op.nbangles = nbangles;
          op.header = hdr;
          op.nbcoeffs = cn;
          op.dims = [m,n];
       end % Constructor

    end % Methods
       
 
    methods ( Access = protected )
       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       % Multiply
       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       function x = multiply(op,x,mode)
         if mode == 1
            % Analysis mode
            if strcmp(op.ttype,'ME')
               x = mefcv2(reshape(x,op.dims(1),op.dims(2)),...
                  op.dims(1),op.dims(2),op.nbscales,op.nbangles);
            else
               x = fdct_wrapping_mex(op.dims(1),op.dims(2),op.nbscales,...
                  op.nbangles,op.finest,reshape(x,op.dims(1),op.dims(2)));
               x = fdct_wrapping_c2r(x);
            end
            x = spot.utils.fdct_c2v(x,op.nbcoeffs);
         else
            % Synthesis mode  
            if strcmp(op.ttype,'ME')
               x = mefdct_v2c(x,op.header,op.nbangles);
               x = meicv2(x,op.dims(1),op.dims(2),op.nbscales,op.nbangles);
            else
               x = spot.utils.fdct_v2c(x,op.header);
               x = fdct_wrapping_r2c(x);
               x = ifdct_wrapping_mex(op.dims(1),op.dims(2),op.nbscales,...
               op.nbangles,op.finest,x);
            end
            if ~op.cflag
               x = real(x);
            end
            x = x(:);
         end
       end % Multiply

    end % Methods
   
end % Classdef