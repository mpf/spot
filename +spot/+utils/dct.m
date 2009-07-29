function y = dct (x, n)
% y = dct (x, n)
%    Computes the discrete cosine transform of x.  If n is given, then
%    x is padded or trimmed to length n before computing the transform.
%    If x is a matrix, compute the transform along the columns of the
%    the matrix. The transform is faster if x is real-valued and even
%    length.
%
% The discrete cosine transform X of x can be defined as follows:
%
%               N-1
%   X[k] = w(k) sum x[n] cos (pi (2n-1) k / 2N ),  k = 0, ..., N-1
%               n=0
%
% with w(0) = sqrt(1/N) and w(k) = sqrt(2/N), k = 1, ..., N-1.  There
% are other definitions with different scaling of X[k], but this form
% is common in image processing.
%
% See also: idct, dct2, idct2, dctmtx

% From Discrete Cosine Transform notes by Brian Evans at UT Austin,
% http://www.ece.utexas.edu/~bevans/courses/ee381k/lectures/09_DCT/lecture9/
% the discrete cosine transform of x at k is as follows:
%
%          N-1
%   X[k] = sum 2 x[n] cos (pi (2n-1) k / 2N )
%          n=0
%
% which can be computed using:
%
%   y = [ x ; flipud (x) ]
%   Y = fft(y)
%   X = exp( -j pi [0:N-1] / 2N ) .* Y
%
% or for real, even length x
%
%   y = [ even(x) ; flipud(odd(x)) ]
%   Y = fft(y)
%   X = 2 real { exp( -j pi [0:N-1] / 2N ) .* Y }
%
% Scaling the result by w(k)/2 will give us the desired output.

% Author: Paul Kienzle
% 2001-02-08
%   * initial release
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
     error('Usage: y = dct(x [, n]');
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
    x (nr-n+1 : n, :) = [];
  end

  if n == 1
    w = 1/2;
  else
    w = [ sqrt(1/4/n); sqrt(1/2/n)*exp((-1i*pi/2/n)*[1:n-1]') ] * ones (1, nc);
  end
  if ( realx && rem (n, 2) == 0 )
    y = fft ([ x(1:2:n,:) ; x(n:-2:1,:) ]);
    y = 2 * real( w .* y );
  else
    y = fft ([ x ; flipud(x) ]);
    y = w .* y (1:n, :);
    if (realx) y = real (y); end
  end
  if transpose, y = y.'; end

end % function
