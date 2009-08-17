function varargout = eigs(varargin)
%EIGS   Find a few eigenvalues and eigenvectors of an operator using ARPACK.
%
%   D = EIGS(A) returns six of the largest eigenvalues of an operator.
%
%   This routine is simply a wrapper to Matlab's own EIGS routine, and
%   most of the argument-list variations described in Matlab's EIGS
%   documentation are also allowed here.  The usage is identical to
%   Matlab's default version, except that the first argument must be a
%   Spot operator, and only the largest eigenvalues are considered.
%
%   Supported usage includes
%
%   D = EIGS(A)
%   [V,D] = EIGS(A)
%   [V,D,FLAG] = EIGS(A)
%   EIGS(A,K)
%   EIGS(A,K,OPTS)
%
%   Again, see Matlab's built-in EIGS for details on these calls.

%   Copyright 2009, Ewout van den Berg and Michael P. Friedlander
%   See the file COPYING.txt for full copyright information.
%   Use the command 'spot.gpl' to locate this file.

%   http://www.cs.ubc.ca/labs/scl/spot

%   NOTE: Because Spot does support "backslash" for operators, it
%   should in principle be possible to support the more general usage
%   of eigs where SIGMA is 0 or 'SM'.
   
   % Set function handle
   A = varargin{1};
   n = size(A,2);
   Aprod = @(x)A*x;

   if nargin < 1 || nargin > 3
      error('Unsupported number of input arguments');
   end
   if nargout < 1 || nargout > 3
      error('Unsupported number of output arguments');
   end

   varargout = cell(1,nargout);
   if nargin == 1
      [varargout{:}] = eigs(Aprod,n);
      return
   end
   if nargin >= 2
      k = varargin{2};
      if ~isscalar(k), error('2nd argument must be a scalar'); end
   else
      k = 6;
   end
   if nargin >= 3
      opts = varargin{3};
      if ~isstruct(opts), error('3rd argument must be a structure'); end
   else
      opts = struct();
   end
   [varargout{:}] = eigs(Aprod,n,k,'LM',opts);
end % function eigs
