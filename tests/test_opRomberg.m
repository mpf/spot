gauss      = 0;
n          = 2000;
r          = 20;

A1         = rand(n,r)*rand(r,n );
tic;
% [U1,S1,V1] = pca(A1,r,0);
toc;

if gauss,
A21        = opGaussian(n ,r);
A22        = opGaussian(n ,r);
A2         = A21*A22';
else
 G21       = opRomberg([n 1]);
 inds      = randperm(n);
 idx1      = inds(1:r);
 R21       = opRestriction(n,idx1);
 A21       = R21*G21;
 G22       = opRomberg([n 1]);
 inds      = randperm(n);
 idx2      = inds(1:r);
 R22       = opRestriction(n,idx2);
 A22       = R22*G22;
 A2        = A21'*A22;
end

tic;
[U2,S2,V2] = spotpca(A2,r,0);
toc;