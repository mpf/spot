classdef opCurvelet3d < opSpot
%OPCURVELET3D  Three-dimensional curvelet operator.
%
%   opCurvelet(M,N,P,NBSCALES,NBANGLES) creates a three-dimensional
%   curvelet operator for M by N by P matrices. The curvelet transform is
%   computed using the Curvelab code.
%
%   The remaining two parameters are optional; NBSCALES gives the
%   number of scales and is set to max(1,ceil(log2(min(M,N,P)) - 3)) by
%   default, as suggested by Curvelab. NBANGLES gives the number of
%   angles at the second coarsest level which must be a multiple of
%   four with a minimum of 8. By default NBANGLES is set to 16.
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
       
    end % Properties

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Methods
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    methods

       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       % Constructor
       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       function op = opCurvelet3d(m,n,p,nbscales,nbangles)

          if nargin < 4, nbscales = max(1,ceil(log2(min([m,n,p])) - 3)); end;
          if nargin < 5, nbangles = 16;                              end;
          finest = 1;  %#ok<PROP>
          is_real = 1; % currently this is not taken as an input, maybe 
                        % support complex later on?

          % Compute length of curvelet coefficient vector
          [tmphdr, cn] = fdct3d_sizes_mex(m,n,p,nbscales,nbangles,finest); %#ok<PROP>
          hdr = cell(nbscales,1);
          hdr{1} = {[tmphdr{1:3}]};
          for i = 2:nbscales
             j = 4 + 10*(i - 2);
             hdr{i} = {[tmphdr{j+1:j+3}];[tmphdr{j+4:j+6}];...
                [tmphdr{j+7:j+9}];[tmphdr{j}]};
          end
          
          % Construct operator
          op = op@opSpot('Curvelet3d', cn, m*n*p);
          op.cflag     = ~is_real;
          op.nbscales = nbscales;
          op.nbangles = nbangles;
          op.header = hdr;
          op.nbcoeffs = cn;
          op.dims = [m,n,p];
       end % Constructor

    end % Methods
       
 
    methods ( Access = protected )
       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       % Multiply
       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       function x = multiply(op,x,mode)
         
          if mode == 1
            % Analysis mode
            x = fdct3d_forward_mex(op.dims(1),op.dims(2),op.dims(3),...
               op.nbscales,op.nbangles,op.finest,reshape(x,op.dims));
            x = fdct_wrapping_c2r(x);
            x = spot.utils.fdct_c2v(x,op.nbcoeffs);
         else
            % Synthesis mode  
            x = spot.utils.fdct_v2c(x,op.header);
            x = fdct_wrapping_r2c(x);
            x = fdct3d_inverse_mex(op.dims(1),op.dims(2),op.dims(3),...
               op.nbscales,op.nbangles,op.finest,x);
            if ~op.cflag
               x = real(x);
            end
            x = x(:);
         end
       end % Multiply          

    end % Methods
   
end % Classdef