function varargout = eigs(varargin)
%EIGS   Find a few eigenvalues and eigenvectors of an operator using ARPACK.
%
%   eigs(A) returns six of the largest eigenvalues of an operator.
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
%   [V,D,FLAG] = EIGS(A,K)
%   [V,D,FLAG] = EIGS(A,K,SIGMA)
%   [V,D,FLAG] = EIGS(A,K,SIGMA,OPTS)
%
%   Again, see Matlab's built-in EIGS for details on these calls.

%   Copyright 2009, Ewout van den Berg and Michael P. Friedlander
%   See the file COPYING.txt for full copyright information.
%   Use the command 'spot.gpl' to locate this file.

%   http://www.cs.ubc.ca/labs/scl/spot

   A = varargin{1};
   n = size(A,2);
   if nargin < 3
      sigma = [];
   else
      sigma = varargin{3};
   end      
   if isempty(sigma) || (ischar(sigma) && ~strcmpi(sigma,'sm'))
      Aprod = @(x)A*x;
   else
      if strcmpi(sigma,'sm') || sigma == 0
         Aprod = @(x)A\x;
      else
         Aprod = @(x)(A-sigma*opEye(n))\x;
      end
   end
   if nargin < 1 || nargin > 4
      error('Unsupported number of input arguments');
   end
   if nargout > 3
      error('Unsupported number of output arguments');
   end

   varargout = cell(1,max(1,nargout));
   [varargout{:}] = eigs(Aprod,n,varargin{2:end});
end % function eigs
