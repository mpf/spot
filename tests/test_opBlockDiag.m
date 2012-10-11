function test_suite = test_opBlockDiag
%test_opBlockDiag  Unit tests for the opBlockDiag operator
initTestSuite;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function seed = setup
   rng('default');
   seed = [];
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
function test_opBlockDiag_prod(seed)
   n = randi(100); m = randi(100);
   A = opMatrix(randn(m,m));
   B = opMatrix(randn(n,n));
   D = blkdiag(A,B);
   x = randn(m+n,1);
   assertEqual( [A*x(1:m); B*x(m+1:end)], D*x )
   assertEqual( [A'*x(1:m); B'*x(m+1:end)], D'*x )
end

function test_opBlockDiag_overlap(seed)
   m1 = randi([5,100]); n1 = randi([5,100]);
   m2 = randi([5,100]); n2 = randi([5,100]);
   A  = opMatrix(randn(m1,n1));
   B  = opMatrix(randn(m2,n2));
   
   % row overlap
   ov = 5;
   D  = opBlockDiag(A,B,ov);
   assertFalse(spot.utils.dottest(D));
   
   % column overlap
   ov = -5;
   D  = opBlockDiag(A,B,ov);
   assertFalse(spot.utils.dottest(D));

   % row-anti-diag overlap
   ov = m1+1;
   D  = opBlockDiag(A,B,ov);
   assertFalse(spot.utils.dottest(D));

   % col-anti-diag overlap
   ov = -(m1+1);
   D  = opBlockDiag(A,B,ov);
   assertFalse(spot.utils.dottest(D));
end