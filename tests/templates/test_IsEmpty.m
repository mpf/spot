function test_IsEmpty(data)
%btIsEmpty(A) Unit test for isempty
%this test assumes double is implemented correctly.
A=data.operator;

    B = double(A);
    assertEqual(isempty(A),isempty(B));
    
    s = size(B);
    if sum(s)>0
        commandA = 'A(:';
        commandB = 'B(:';
        for i= 1:length(s)-1
            commandA = [commandA, ',:'];
            commandB = [commandB, ',:'];
        end
        commandA = [commandA,')=[];'];
        commandB = [commandB,')=[];'];
        eval(commandA);
        eval(commandB);
        assertEqual(isempty(A), isempty(B));
    end

end