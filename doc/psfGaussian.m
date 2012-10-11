function [P,c] = psfGaussian(m,n,std)
   siz   = ([m n]-1)/2;
   [x,y] = meshgrid(-siz(2):siz(2),-siz(1):siz(1));
   P     = exp( -(x.*x + y.*y)/(2*std*std) );
   P     = P / sum(P(:));
   [m,n] = find(P == max(P(:)));
   c     = [m(1), n(1)];
end
