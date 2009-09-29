function varargout = lsqr(A,b,varargin)
%LSQR   LSQR Method.
%
%   X = lsqr(A,B) attempts to solve the least-squares problem
%
%       minimize  || A*X - B ||_2
%
%   This routine is simply a wrapper to Matlab's own LSQR routine,
%   and the argument list variations described in Matlab's LSQR
%   documentation are also allowed here.  The usage is identical to
%   Matlab's default version, except that the first argument must be a
%   Spot operator.

%   Copyright 2009, Ewout van den Berg and Michael P. Friedlander
%   See the file COPYING.txt for full copyright information.
%   Use the command 'spot.gpl' to locate this file.

%   http://www.cs.ubc.ca/labs/scl/spot

    fun = @(x,mode) lsqr_intrnl(A,x,mode);

    if nargout == 0
       lsqr(fun,b,varargin{:});
    elseif nargout <= 6
       varargout = cell(1,nargout);
       [varargout{:}] = lsqr(fun,b,varargin{:});
    else
       error('Too many output arguments.');
    end
end % function lsqr
    
% ======================================================================
% Private function
% ======================================================================
function y = lsqr_intrnl(A,x,mode)
   if strcmp(mode,'notransp')
      y = A * x;
   else
      y = A' * x;
   end
end % function lsqr_intrnl
