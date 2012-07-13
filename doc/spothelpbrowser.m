% Copy all the .m files in spotdoc/web/matlab_published/mfiles to the
% spot "doc" folder, editing them so that the links work in the help browser.
% Optionally publishes them to html.
clear all;

% Get parent directory
fullpath = mfilename('fullpath');
idx      = find(fullpath == filesep);
path = fullpath(1:idx(end));

fprintf('Make sure that the spotdoc folder is on the Matlab path.\n');

% Read helptoc.xml file to find titles for example pages
toctext = fileread(fullfile(path, 'helptoc.xml'));

mfiles = dir(fullfile('spotdoc', 'web', 'matlab_published', 'mfiles', '*.m'));
for k = 1:numel(mfiles)
    name = mfiles(k).name;
    % Convert the input file into a string
    text = fileread(fullfile('spotdoc', 'web', 'matlab_published', 'mfiles', name));
    
    % Replace the links to operators with matlab:doc links
    opexp = '<http://www\.cs\.ubc\.ca/labs/scl/spot/operators\.html#(op(.*)?)/?\s(\|)?\1(\|)?>';
    opreplace = '<matlab:doc(''$1'') $1>';
    text = regexprep(text, opexp, opreplace);
    
    % Replace the links to methods with matlab:doc links
    methodexp = '<http://www\.cs\.ubc\.ca/labs/scl/spot/methods\.html#((.*)?)/?\s(\|)?\1(\|)?>';
    methodreplace = '<matlab:doc(''opSpot/$1'') $1>';
    text = regexprep(text, methodexp, methodreplace);
    
    % Replace the links to operators with matlab:doc links
    mathworksexp = '<http://www\.mathworks.com/help/techdoc/ref/((.*)?)\.html/?\s(\|)?\1(\|)?>';
    mathworksreplace = '<matlab:doc(''$1'') $1>';
    text = regexprep(text, mathworksexp, mathworksreplace);
    
    % Replace the links to the usingmethods.html page with matlab:doc links
    usingmexp = '<http://www\.cs\.ubc\.ca/labs/scl/spot/usingmethods\.html/?';
    usingmreplace = '<usingmethods.html';
    text = regexprep(text, usingmexp, usingmreplace);
    
    % Get title from the helptoc.xml page
    pathtohtml = fullfile('html', ['doc', regexprep(name, '\.m', '.html')]);
    helptocexp = ['<tocitem\s*target="', pathtohtml, '"((\s)*image=".*?")?>(.*?)</tocitem>'];
    tokenstring = regexp(toctext, helptocexp, 'tokens', 'once');
    tokenstring = tokenstring{2};
    
    % If you don't find it on the helptoc.xml page, type one in
    if isempty(tokenstring) == 1
        title = input(['Enter a title for the doc', name, ' page:\n'], 's');
    else title = strtrim(tokenstring);
    end
    
    % Add the title
    arraytext = {text};
    arraytext = {arraytext{1}(3:end)};
    text = ['%% ', title, arraytext{1}];
    
    % Make a new text file or open the existing one to overwrite
    FID = fopen(fullfile(path, ['doc', name]), 'w');
    
    % Print the modified string to the text file
    result = fprintf(FID, '%s\n', text);
    
    % Close the text file
    fclose(FID);
    
end

fprintf('\nThe .m files have been moved. Enter which files to publish to html.\n\n');
% publish all the mfiles
docmfiles = dir(fullfile(path, '*doc*.m'));
options = struct('outputDir', fullfile(path, 'html'));
for i = 1:numel(docmfiles)
    reply = input(['Publish ', docmfiles(i).name, '? (y/n)\n'], 's');
    no = {'n', 'N', 'no', 'No'};
    if any(strcmp(reply, no))
        % Do nothing
    else publish(docmfiles(i).name, options);
    end
end

fprintf('All done! Update helptoc.xml and examples.m if you have added new pages.\n');

clear all;