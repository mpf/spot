function test_suite = test_opRomberg
initTestSuite;
end

function test_opRomberg_builtin
%% Built-in test for opRomberg
m = randi(10);
n = randi(10);
A = opRomberg([m n]);
A.utest;
A = A';
A.utest;
end

function test_opRomberg_gaussian
%% Felix's Test for opRomberg
gauss     = 0;
n         = 2000;
r         = 20;
A1        = rand(n,r)*rand(r,n );
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

[U2,S2,V2] = spotpca(A2,r,0);
end