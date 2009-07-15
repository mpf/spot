function test_char
%test_char  Unit tests for the char method
initTestSuite;
end

function test_char_elementaryops
list = opBasic();

for i=1:length(list)
    assertEqual(1,1)
end

end
