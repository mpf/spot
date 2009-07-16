function basicTests

tests = buildBasicTests();

for i=1:numel(tests)
    command = ['runtests ', tests{i}];
    eval(command);
end

end