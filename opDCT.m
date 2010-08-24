classdef opDCT < opOrthogonal
%OPDCT  Discrete cosine transform (DCT).
%
%   opDCT(M) creates a one-dimensional discrete cosine transform
%   operator for vectors of length M.

%   Copyright 2009, Ewout van den Berg and Michael P. Friedlander
%   See the file COPYING.txt for full copyright information.
%   Use the command 'spot.gpl' to locate this file.

%   http://www.cs.ubc.ca/labs/scl/spot

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   % Methods - public
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   methods
      
      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      % opDCT. Constructor.
      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      function op = opDCT(m)
         if nargin ~= 1
            error('Invalid number of arguments.');
         end
         if ~isscalar(m) || m~=round(m) || m <= 0
            error('Argument to opDCT must be a positive integer.');
         end
         op = op@opOrthogonal('DCT',m,m);
         op.sweepflag   = true;
      end % function opDCT
      
      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      % spy. Really only a pedagogical tool, and only practical to
      % execute for DCTs that have less than, say, a dozen columns.
      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      function spy(op)
         
         colormap('gray');
         mSig = op.m;
         x    = zeros(mSig,1);
         
         for i=1:mSig
            x(i) = 1;
            y    = op'*x;
            x(i) = 0;
            subplot(mSig,1,i);
            plot(y); ylim([-0.5, +0.5]);
            axis off;
         end
      end % function plot
      
   end % methods - public
   
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   % Methods - protected
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   methods( Access = protected )
      
      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      % multiply.
      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      function y = multiply(op,x,mode)
         if mode == 1
            y = spot.utils.dct(full(x));
         else
            y = spot.utils.idct(full(x));
         end
      end % function multiply
      
   end % methods - protected
   
end % Classdef
