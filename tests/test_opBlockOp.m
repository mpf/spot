function test_suite = test_opBlockOp
initTestSuite;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function seed = setup
   seed = rng('default');
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function test_opBlockOp_DCT2a(seed);
    
   rng(seed);
   data = randn(7*16,4*16);

   A = opBlockOp(size(data,1),size(data,2),opDCT2(16),16,16);
   B = reshape(A' * A * (data(:)),size(data,1),size(data,2));
   
   assertElementsAlmostEqual( B, data );
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function test_opBlockOp_DCT2b(seed);
    
   rng(seed);
   data = randn(7*16,4*16);

   A = opBlockOp(size(data,1),size(data,2),opDCT2(16),16,16,256,1);
   B = reshape(A' * A * (data(:)),size(data,1),size(data,2));
   
   assertElementsAlmostEqual( B, data );
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function test_opBlockOp_DCT(seed);
    
   rng(seed);
   data = randn(7*16,4*16);

   A = opBlockOp(size(data,1),size(data,2),opDCT(256),16,16,32,8);
   B = reshape(A' * A * (data(:)),size(data,1),size(data,2));
   
   assertElementsAlmostEqual( B, data );
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function test_opBlockOp_Gaussian(seed);
    
   rng(seed);
   data = randn(32,80); % 4x5 blocks of size 8x16
   
   G = randn(120,128); % Map 8x16 blocks to 10x12 blocks
   M = opMatrix(G);
   A = opBlockOp(32,80,M,8,16,10,12);

   dataA = reshape(A*data(:),40,60); % 4x5 blocks of size 10x12
   dataB = zeros(40,60);
   for i=1:4
      for j=1:5
         block = data((1:8)+(i-1)*8,(1:16)+(j-1)*16);
         dataB((1:10)+(i-1)*10,(1:12)+(j-1)*12) = reshape(G*block(:),10,12);
      end      
   end
   
   assertEqual( dataA, dataB );
end
