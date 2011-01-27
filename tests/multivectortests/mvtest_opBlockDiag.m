function test_suite = mvtest_opBlockDiag
%test_opBlockDiag  Unit tests for the opBlockDiag operator
initTestSuite;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function seed = setup
   randn('state',0);
   rand('state',0);
   seed = [];
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
function test_opBlockDiag_prod(~)
   n = randi(100); m = randi(100);
   A = opMatrix(randn(m,m));
   B = opMatrix(randn(n,n));
   D = opBlockDiag(A,B);
   x = randn(m+n,2);
   for i = 1:2 % Because y = [A*x(1:m,:); B*x(m+1:end,:)] 
               % has some weird rounding errors
       y(:,i) = [A*x(1:m,i); B*x(m+1:end,i)];
   end
   assertEqual( y, D*x )
   
   for i = 1:2
       y2(:,i) = [A'*x(1:m,i); B'*x(m+1:end,i)];
   end
   assertEqual( y2, D'*x )
end

function test_opBlockDiag_overlap(~)
   m1 = randi([5,100]); n1 = randi([5,100]);
   m2 = randi([5,100]); n2 = randi([5,100]);
   A  = opMatrix(randn(m1,n1));
   B  = opMatrix(randn(m2,n2));
   
   % row overlap
   ov = 5;
   D  = opBlockDiag(A,B,ov);
   assertFalse(dottest(D));
   
   % column overlap
   ov = -5;
   D  = opBlockDiag(A,B,ov);
   assertFalse(dottest(D));

   % row-anti-diag overlap
   ov = m1+1;
   D  = opBlockDiag(A,B,ov);
   assertFalse(dottest(D));

   % col-anti-diag overlap
   ov = -(m1+1);
   D  = opBlockDiag(A,B,ov);
   assertFalse(dottest(D));
end