tests = buildBasicTests();

for i=1:numel(tests)
    fprintf(['%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%',...
            '%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%\n']);
    fprintf(['Performing ', tests{i},'\n']);
    command = ['runtests ', tests{i}];
    eval(command);
end
