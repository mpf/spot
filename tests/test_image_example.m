function test_suite = test_image_example
%test_image_example  Unit tests for the DFT operator.
initTestSuite;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function h = setup
%   h = [figure(1) figure(2)];
   h = [];
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function test_image_clown(h)

load clown                   % the famous clown image
m  = 128; n = 256; N = m*n;
[P,c] = psfGaussian(m,n,2);  % Gaussian PSF
Y  = X(1:m,1:n);             % nicely-shaped version of the original image 
y  = Y(:);                   % vectorized version of image
A1 = circshift(P,1-c);       % first col of blurring operator A

% Using Matlab's built-in DFTs.
S  = fft2( A1 );             % spectrum of A
B  = ifft2( S.* fft2(Y));    % b = A*x; blurred image
B  = real(B);

%figure(h(1)); imagesc(B); axis image; colormap gray; title('Built-in DFT');

% Using Spot.
F  = opDFT2(m,n);
s  = sqrt(N) * F  * A1(:);   % F*a1 = 1/sqrt(N) evals of A
b  = F' * (s .* (F*y));      % b = F'*S*F*y
b  = real(b);
B2 = reshape(b,m,n);         % Reshape into a matrix.

%figure(h(2)); imagesc(B2); axis image; colormap gray; title('Spot''s DFT');

assertElementsAlmostEqual(B,B2,'relative',sqrt(eps));

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function teardown(h)
  close(h)
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [P,c] = psfGaussian(m,n,std)
   siz   = ([m n]-1)/2;
   [x,y] = meshgrid(-siz(2):siz(2),-siz(1):siz(1));
   P     = exp( -(x.*x + y.*y)/(2*std*std) );
   P     = P / sum(P(:));
   [m,n] = find(P == max(P(:)));
   c     = [m(1), n(1)];
end