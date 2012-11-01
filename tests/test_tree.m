function test_suite = test_tree
%test_tree  Unit test for tree generation and optimization.
initTestSuite;
end

function d = setup
   d.plot = false;
   rng('default');
   d.A1 = opMatrix(randn(30,35));
   d.A2 = opMatrix(randn(35,15));
   d.A3 = opMatrix(randn(15, 5));
   d.A4 = opMatrix(randn( 5,10));
   d.A5 = opMatrix(randn(10,20));
   d.A6 = opMatrix(randn(20,25));
end

function teardown(d)
   close all
end
   
function test_tree_multiplication(d)
   import('spot.utils.*') 
   B = d.A1*d.A2*d.A3*d.A4*d.A5*d.A6;
   C = optimalBracketing(B);
   if d.plot
      Btree = spottree(B);
      plot(Btree);
      preFlops = flops(Btree);
      title(['Pre-optimized flops: ', num2str(preFlops)])
      Ctree = spottree(C);
      plot(Ctree);
      postFlops = flops(Ctree);
      title(['Post-optimized flops: ', num2str(postFlops)])
   end
   assertElementsAlmostEqual(double(B),double(C))
end

function test_tree_ctranspose(d)
   import('spot.utils.*') 
   B1 = d.A6'*(d.A2*d.A3*d.A4*d.A5)'*d.A1';
   C1 = optimalBracketing(B1);
   if d.plot
      B1tree = spottree(B1);
      plot(B1tree);
      preFlops = flops(B1tree);
      title(['Pre-optimized flops: ', num2str(preFlops)])
      C1tree = spottree(C1);
      plot(C1tree);
      postFlops = flops(C1tree);
      title(['Post-optimized flops: ', num2str(postFlops)])
   end
   assertElementsAlmostEqual(double(B1),double(C1))
end

function test_tree_scalars(d)
   import('spot.utils.*') 
   B2 = d.A1*10*d.A2*d.A3*(1/9)*d.A4*d.A5*d.A6;
   C2 = optimalBracketing(B2);
   if d.plot
      B2tree = spottree(B2);
      plot(B2tree);
      preFlops = flops(B2tree);
      title(['Pre-optimized flops: ', num2str(preFlops)])      
      C2tree = spottree(C2);
      plot(C2tree);
      postFlops = flops(C2tree);
      title(['Post-optimized flops: ', num2str(postFlops)])
   end
   assertElementsAlmostEqual(double(B2),double(C2))
end

function test_tree_sums_diffs_sup(d)
   % check summation that happens at top level
   import('spot.utils.*') 
   sA5=size(d.A5); sA6 = size(d.A6);
   B3 = (d.A1+randn(size(d.A1)))*(d.A2-randn(size(d.A2)))*d.A3*d.A4*(d.A5*d.A6+randn(sA5(1),sA6(2)));
   C3 = optimalBracketing(B3);
   if d.plot
      B3tree = spottree(B3);
      plot(B3tree);
      preFlops = flops(B3tree);
      title(['Pre-optimized flops: ', num2str(preFlops)])      
      C3tree = spottree(C3);
      plot(C3tree);
      postFlops = flops(C3tree);
      title(['Post-optimized flops: ', num2str(postFlops)])
   end
   assertElementsAlmostEqual(double(B3),double(C3))
end

function test_tree_sums_diffs_sub(d)
   % case checking optimization happens inside the summation(i.e. below the
   % top level)
   import('spot.utils.*') 
   B4 = (d.A1+randn(size(d.A1)))*(d.A2-randn(size(d.A2)))*...
      (d.A3*d.A4*d.A5*d.A6+d.A3*d.A4*d.A5*d.A6);
   C4 = optimalBracketing(B4);
   if d.plot
      B4tree = spottree(B4);
      plot(B4tree);
      preFlops = flops(B4tree);
      title(['Pre-optimized flops: ', num2str(preFlops)])
      C4tree = spottree(C4);
      plot(C4tree);
      postFlops = flops(C4tree);
      title(['Post-optimized flops: ', num2str(postFlops)])
   end
   assertElementsAlmostEqual(double(B4),double(C4))
end

function test_tree_concatentation(d)
   % test with concatenation
   import('spot.utils.*') 
   B5 = [d.A1(1:2, :); d.A1(3:4, :); d.A1(5:end, :)]*[d.A2(:, 1:2), ...
      d.A2(:, 3:4), d.A2(:,5:8), d.A2(:,9:end)]*d.A3*d.A4*d.A5*d.A6;
   C5 = optimalBracketing(B5);
   if d.plot
      B5tree = spottree(B5);
      plot(B5tree);
      preFlops = flops(B5tree);
      title(['Pre-optimized flops: ', num2str(preFlops)])
      C5tree = spottree(C5);
      plot(C5tree);
      postFlops = flops(C5tree);
      title(['Post-optimized flops: ', num2str(postFlops)])
   end
   assertElementsAlmostEqual(double(B5),double(C5))
end