function test_suite = test_eigs
%test_eigs  Unit tests for eigs/svds
initTestSuite;
end

function test_eigs_explicit
   opts.disp = 0;
   
   Aex = delsq(numgrid('C',15));
   Aop = opMatrix(Aex);
   
   [tmp,Dex] = evalc('eigs(Aex)');
   [tmp,Dop] = evalc('eigs(Aop)');
   assertElementsAlmostEqual(sort(Dex),sort(Dop));
   
   Dex = eigs(Aex,1,'lm',opts);
   Dop = eigs(Aop,1,'lm',opts);
   assertElementsAlmostEqual(sort(Dex),sort(Dop));
   
   Dex = eigs(Aex,6,'sm',opts);
   Dop = eigs(Aop,6,'sm',opts);
   assertElementsAlmostEqual(sort(Dex),sort(Dop));
end
