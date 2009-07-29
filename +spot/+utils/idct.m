function y = idct (x, n)
% y = idct (x, n)
%    Computes the inverse discrete cosine transform of x.  If n is
%    given, then x is padded or trimmed to length n before computing
%    the transform. If x is a matrix, compute the transform along the
%    columns of the the matrix. The transform is faster if x is
%    real-valued and even length.
%
% The inverse discrete cosine transform x of X can be defined as follows:
%
%          N-1
%   x[n] = sum w(k) X[k] cos (pi (2n-1) k / 2N ),  k = 0, ..., N-1
%          k=0
%
% with w(0) = sqrt(1/N) and w(k) = sqrt(2/N), k = 1, ..., N-1
%
% See also: idct, dct2, idct2, dctmtx

% Author: Paul Kienzle
% 2001-02-08
%   * initial release
%
% 2007-08-18
%   * Converted to Matlab by Michael P. Friedlander (mpf@cs.ubc.ca).

% Copyright (C) 2001 Paul Kienzle
%
% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 2 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program; if not, write to the Free Software
% Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA
    
  if (nargin < 1 || nargin > 2)
     error('y = dct(x [, n])');
  end

  realx = isreal(x);
  transpose = (size(x,1) == 1);

  if transpose, x = x (:); end
  [nr, nc] = size (x);
  if nargin == 1
    n = nr;
  elseif n > nr
    x = [ x ; zeros(n-nr,nc) ];
  elseif n < nr
    x (n-nr+1 : n, :) = [];
  end

  if ( realx && rem (n, 2) == 0 )
    w = [ sqrt(n/4); sqrt(n/2)*exp((1i*pi/2/n)*[1:n-1]') ] * ones (1, nc);
    y = ifft (w .* x);
    y([1:2:n, n:-2:1], :) = 2*real(y);
  elseif n == 1
    y = x;
  else
    % reverse the steps of dct using inverse operations
    % 1. undo post-fft scaling
    w = [ sqrt(4*n); sqrt(2*n)*exp((1i*pi/2/n)*[1:n-1]') ] * ones (1, nc);
    y = x.*w;

    % 2. reconstruct fft result and invert it
    w = exp(-1i*pi*[n-1:-1:1]'/n) * ones(1,nc);
    y = ifft ( [ y ; zeros(1,nc); y(n:-1:2,:).*w ] );

    % 3. keep only the original data; toss the reversed copy
    y = y(1:n, :);
    if (realx) y = real (y); end
  end
  if transpose, y = y.'; end

end % function
