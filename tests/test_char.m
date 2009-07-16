function test_char
%test_char  Unit tests for the char method
initTestSuite;
end

function test_char_elementaryops
   m = 2; n = 2;
   assertEqual( char(opBernoulli(m,n)),'Bernoulli(2,2)' )
   assertEqual( char(opBinary(m,n))   ,'Binary(2,2)' )
   % 15 Jul 09, MPF: Need to add asserts for other elementary ops.   
end
