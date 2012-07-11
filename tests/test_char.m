function test_suite = test_char
%test_char  Unit tests for the char method
initTestSuite;
end

function test_char_elementary_ops
   m = 2; n = 2;
   check( opBernoulli(m,n), 'Bernoulli', m, n )
   check( opBinary(m,n),    'Binary',    m, n )
   check( opDCT(m),         'DCT',       m, m )
   check( opDCT2(m,n),      'DCT2',      m*n, m*n)
   check( opDFT(m),         'DFT',       m, n )
   check( opDFT2(m,n),      'DFT2',      m*n, m*n)
   check( opDirac(m),       'Dirac',     m, m )
   check( opEmpty(m,0),     'Empty',     m, 0 )
   check( opExtend(m,n,2*m,2*n),'Extend',(2*m)*(2*n), m*n )
   check( opEye(m),         'Eye',       m, m )   
   check( opEye(m,n),       'Eye',       m, n )
   check( opGaussian(m,n),  'Gaussian',  m, n )
   check( opHaar(m*2^5),    'Haar',      m*2^5, m*2^5 )
   check( opHaar2(64,32),   'Haar2',   64*32, 64*32)
   check( opHadamard(n),    'Hadamard',  n, n )
   check( opHeaviside(n),   'Heaviside', n, n )
   check( opOnes(m,n),      'Ones',      m, n )
   check( opWavelet(m,'Daubechies'),'Wavelet', m, n )
   check( opWavelet2(m,n,'Daubechies'),'Wavelet2', m*n, m*n )
   check( opZeros(m,n),     'Zeros',     m, n )
end

function check(op,name,m,n)
   assertEqual( char(op), sprintf('%s(%i,%i)',name,m,n) )
end