function test_suite = test_opWavelet
%test_opWavelet  Unit tests for the Wavelet operator
initTestSuite;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function seed = setup
   randn('state',0);
   seed = randn('state');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
function test_opWavelet_1d(seed)
   p = 23; 

   % test default and Daubechies family
   A1 = opWavelet(p);
   A2 = opWavelet(p,'Daubechies');
   
   n = p;
   x = randn(n,1);
   y = A1*x;

   assertEqual( y, A2*x );
   
   % test Haar family
   A3 = opWavelet(p,'Haar');
   
   y = A3*x;
   assertElementsAlmostEqual( y, double(A3)*x );
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
function test_opWavelet_2d(seed)
   p = 23; q = 17;
   
   % test default and Daubechies family
   A1 = opWavelet2(p,q);
   A2 = opWavelet2(p,q,'Daubechies');
   
   n = p*q;
   x = randn(n,1);
   y = A1*x;

   assertEqual( y, A2*x );
   
   % test Haar family
   A3 = opWavelet2(p,q,'Haar');
   
   y = A3*x;
   assertElementsAlmostEqual( y, double(A3)*x );
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
function test_opWavelet_divide(seed)
    p = 23; q = 17;
    
    A1 = opWavelet2(p,q);
    
    n=p*q;
    x = randn(n,1);
    y = A1*x;
    
    assertElementsAlmostEqual(x, A1\y);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
function test_opWavelet_levels(seed)
   p = 24; q = 32;
   
   A1 = opWavelet2(p,q,'Daubechies',[],3);
   
   n = p*q;
   x = randn(n,1);
   y = A1*x;
   
   assertEqual(length(x), length(y))
end
