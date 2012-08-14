function spothelpbrowser

% Copy all the .m files in spotdoc/web/matlab_published/mfiles to the
% Spot "doc" folder if they have been updated. Edit them so that the links
% work in the help browser. Publish them to spot/doc/html. Update the
% methods and operators help files in htmlhelp. Make sure that every
% method, operator, and example has a TOC entry in helptoc.xml and in the
% appropriate help browser page (e.g. meta_operators.m). Finally, publish
% the main help browser pages.
clear all;

mainpages = {'spot_main_page.m', 'spot_methods.m', 'spot_operators.m', ...
    'container_operators.m', 'elementary_operators.m', 'examples.m', ...
    'fast_operators.m', 'meta_operators.m', 'random_ensembles.m'};

nohelp = {'Contents.html', 'divide.html'};

% Get path for help browser mfiles
fullpath = mfilename('fullpath');
idx      = find(fullpath == filesep);
hbmfilespath = fullpath(1:idx(end));
addpath(genpath(hbmfilespath));

% Get path of website examples
spotdocpath = input('Enter the path to the spotdoc folder, including spotdoc itself:\n', 's');
mfilespath = fullfile(spotdocpath, 'web', 'matlab_published', 'mfiles');
addpath(genpath(spotdocpath));

% Get list of website mfiles
mfiles = dir(fullfile(mfilespath, '*.m'));

% Read helptoc.xml file into string
toctext = fileread(fullfile(hbmfilespath, 'helptoc.xml'));

%%%%%%%%%%%%%%%%% COPY, EDIT, AND PUBLISH THE EXAMPLES %%%%%%%%%%%%%%%%%%

for k = 1:numel(mfiles)
    name = mfiles(k).name;
    hbname = ['doc' name];
    
    % Get date modified of original mfile and help browser version
    hbfile = dir(fullfile(hbmfilespath, hbname));
    if ~isempty(hbfile)
        date = mfiles(k).datenum;
        hbdate = hbfile.datenum;
        % If the original mfile hasn't been modified since the help browser
        % version has, continue to next mfile
        if date < hbdate
            continue
        end
    end
    
    % Convert the input file into a string
    text = fileread(fullfile(mfilespath, name));
    
    % Fix all the links in the file to work in the help browser
    text = editmfile(text);
    
    % Get a title for the page
    title = getexampletitle(hbname, toctext);
    
    % Add the title
    arraytext = {text};
    arraytext = {arraytext{1}(3:end)};
    text = ['%% ', title, arraytext{1}];
    
    % Make a new text file or open the existing one to overwrite
    FID = fopen(fullfile(hbmfilespath, hbname), 'w');
    
    % Print the modified string to the text file
    result = fprintf(FID, '%s\n', text);
    
    % Close the text file
    fclose(FID);
    fprintf(['\n' hbname ' updated.\n']);
    
    % Publish the mfile
    publishexample(hbmfilespath, hbname);

end

fprintf('Finished updating examples\n');

% Update examples.m and helptoc.xml with the example information
htmlexamples = dir(fullfile(hbmfilespath, 'html', 'docguide*.html'));
for b = 1:numel(htmlexamples)
    if ~strcmp(htmlexamples(b).name, 'docguide_quick.html')
        toctext = tocupdate(htmlexamples(b), toctext);
    end
end

%%%%%%%%%%%%%%%%%% UPDATE THE METHOD AND OPERATOR HELP %%%%%%%%%%%%%%%%%%%

% Update htmlhelp files
run makehtmlhelp;

% Check that each htmhelp operator and method file is in helptoc.xml
htmlhelp = dir(fullfile(hbmfilespath, 'html', 'htmlhelp', '*.html'));
for i = 1:numel(htmlhelp)
    if ~any(strcmp(htmlhelp(i).name, nohelp))
        toctext = tocupdate(htmlhelp(i), toctext);
    end
end

% Open helptoc.xml to overwrite
FID2 = fopen(fullfile(hbmfilespath, 'helptoc.xml'), 'w');
    
% Print the modified string to helptoc.xml
result = fprintf(FID2, '%s\n', toctext);
fclose(FID2);

fprintf('helptoc.xml and other tables of contents updated\n');

% Publish the main pages
for n = 1:numel(mainpages)
    publish(fullfile(hbmfilespath, mainpages{n}));
    fprintf([mainpages{n}, ' published to html\n']);
end

fprintf('All done!\n');

clear all;

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function newtext = editmfile(text)
% Change all the links in a website mfile to work in the help browser

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
    
    newtext = text;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function toc = tocupdate(helpfile, toc)
% Check if the method or operator has an entry in helptoc.xml and in mpage
% (e.g. spot_methods.m, meta_operators.m). If not, create them.

    htmlname = helpfile.name;
    name = htmlname(1:end-5);
    
    % Determine whether it's a method or operator
    if regexp(name, 'op') == 1;
        % It's an operator
        type = 1;
        mpages = {'elementary_operators.m', 'fast_operators.m', ...
            'container_operators.m', 'meta_operators.m', 'random_ensembles.m'};
        icon = 'BLOCK';
        pathtohtml = fullfile('html', 'htmlhelp', htmlname);
    elseif regexp(name, 'docguide') == 1;
        % It's an example
        type = 2;
        mpages = {'examples.m'};
        icon = 'EXAMPLES';
        pathtohtml = fullfile('html', htmlname);
    else % It's a method
        type = 3;
        mpages = {'spot_methods.m'};
        icon = 'FUNCTION';
        pathtohtml = fullfile('html', 'htmlhelp', htmlname);
    end
    
    mpage = [];
    % Look for entry in mpages
    for i=1:numel(mpages)
        strpage = char(mpages(i));
        mpagetext = fileread(fullfile(spot.path, 'doc', strpage));
        if type == 2
            exp = ['<', htmlname];
        else
            exp = ['<', fullfile('htmlhelp', htmlname)];
        end
        if ~isempty(regexp(mpagetext, exp, 'once'));
            mpage = strpage;
            break;
        end
    end
    
    prevname = [];
    
    % If entry was not in mpages, get appropriate mpage and insert entry
    if isempty(mpage)
        mpage = getmpage(name, type);
        mpagetext = fileread(fullfile(spot.path, 'doc', mpage));
        [prevname, tailindex] = findplaceinmpage(name, type, mpagetext);
        insertmpageentry(name, mpage, mpagetext, tailindex);
    end
    
    % Find heading and hpage for helptoc.xml
    hpage = strrep(mpage, '.m', '.html');
    switch mpage
        case 'spot_methods.m'
            heading = 'Methods';
        case 'examples.m'
            heading = 'Examples';
        case 'elementary_operators.m'
            heading = 'Elementary operators';
        case 'container_operators.m'
            heading = 'Containers';
        case 'fast_operators.m'
            heading = 'Fast transforms';
        case 'random_ensembles.m'
            heading = 'Random ensembles';
        case 'meta_operators.m'
            heading = 'Meta operators';
    end
            
    % Look for entry in helptoc.xml
    helptocexp = ['<tocitem\s*target="', pathtohtml, '"((\s)*image=".*?")?>(.*?)</tocitem>'];
    match = regexp(toc, helptocexp, 'once');

    % If it's not in helptoc.xml, insert it
    if isempty(match)
        toc = inserttocentry(name, type, prevname, mpage, hpage, heading, icon, toc);
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function page = getmpage(name, type)
if type == 1
    h = input(['What type of operator is ' name ' ? Enter 1 for ' ...
        '"Elementary Operator", 2 for "Container",\n 3 for "Fast Operator",' ...
        '4 for "Random Ensemble" or 5 for "Meta Operator":\n']);
    switch h
        case 1
            page = 'elementary_operators.m';
        case 2
            page = 'container_operators.m';
        case 3
            page = 'fast_operators.m';
        case 4
            page = 'random_ensembles.m';
        case 5
            page = 'meta_operators.m';
    end
elseif type == 2
    % It's an example
    page = 'examples.m';
else % It's a method
    page = 'spot_methods.m';
end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [prevname, tailindex] = findplaceinmpage(name, type, mpagetext)
% Find the operator or method name that comes before the given name, and
% the index to insert a new entry in front of if relevant. Prevname is
% 'START' if the name is the first on the page.
    
    if type == 2
        entryexp = '%\s\*\s<(\S*)\s.*?>\s*$';
    else entryexp = '%\s\*\s<\S*\s(\S*)>\s*.*?$';
    end
        
    % Find all entries in the list
    [starts, tokens] = regexp(mpagetext, entryexp, 'start', 'tokens', 'lineanchors');
    
    prevname = 'START';
    tailindex = [];
    
    % Find where to insert the new entry
    if type == 2
        last = char(tokens{end});
        last = last(6:end-5);
        if strcmp(last, name)
            last = char(tokens{end-1});
            last = last(6:end-5);
        end
        prevname = last;
    else
        for m = 1:numel(starts)
            % Compare token with name alphabetically
            match = char(tokens{m});
            compare = strcmpc(match, name);
            if compare == -1
                prevname = match;
                continue
            elseif compare == 0
                % Already on the mpage - leave prevname as is
                break
            else
                tailindex = starts(m);
                break
            end
        end
    end
    
    if isempty(tailindex)
        % Last entry on page
        tailindex = length(mpagetext)+1;
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function insertmpageentry(name, mpage, mpagetext, tailindex)
% Insert the operator or method's entry to the mpage just before tailindex

    % Create the entry
    htmlpage = [name, '.html'];
    if regexp(name, 'docguide') == 1
        % Get title of example page
        exFID = fopen([name, '.m']);
        firstline = fgets(exFID);
        title = strtrim(firstline(4:end));
        fclose(exFID);
        entry = sprintf(['%% * <', htmlpage, ' ', title, '>\n']);
    else
        helpline = getHelpLine(name);
        entry = sprintf(['%% * <', fullfile('htmlhelp', htmlpage), ' ', name, '> - ', helpline, '\n']);
    end
    
    % Insert it into the mpagetext
    arraympage = {mpagetext};
    beginning = arraympage{1}(1:tailindex-1);
    finish = arraympage{1}(tailindex:end);
    mpagetext = [beginning, entry, finish];
    
    % Print to mpage file
    FID = fopen(fullfile(spot.path, 'doc', mpage), 'w+');
    result = fprintf(FID, '%s', mpagetext);
    fclose(FID);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function helpline = getHelpLine(name)
    % Get first line of help text
    if regexp(name, 'op') == 1
        helptext = help(name);
    else helptext = help(fullfile('opSpot', name));
    end
    rexp = '.+?\s+(.*?)\.?\n';
    helpline = char(regexp(helptext, rexp, 'tokens', 'once', 'ignorecase'));
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function toc = inserttocentry(name, type, prevname, mpage, hpage, heading, icon, toc)
% Find where to insert
mpagetext = fileread(fullfile(spot.path, 'doc', mpage));
if isempty(prevname)
    [prevname, ~] = findplaceinmpage(name, type, mpagetext);
end

if type == 2
    prevnamepath = fullfile('html', [prevname, '.html']);
    exFID = fopen([name, '.m']);
    firstline = fgets(exFID);
    title = strtrim(firstline(4:end));
    fclose(exFID);
    hpath = fullfile('html', name);
else
    prevnamepath = fullfile('html', 'htmlhelp', [prevname, '.html']);
    title = name;
    hpath = fullfile('html', 'htmlhelp', name);
end

% Create TOC entry string
entry = ['             ', '<tocitem target="', hpath, '.html', ...
    '"\n                      ', 'image="HelpIcon.', icon, ...
    '">\n                      ', title, '\n             ', '</tocitem>\n'];

% Find TOC entry of heading
if strcmp(prevname, 'START')
    % Method or operator is at the beginning of the list
    headingexp = ['<tocitem\s*target="', fullfile('html', hpage), ...
        '"((\s)*image=".*?")?>\s*', heading, '\n'];
else
    % Insert after prevname entry
    headingexp = ['<tocitem\s*target="', prevnamepath, ...
        '"\s*(image=".*?")?>.*?\n\s*</tocitem>\s*\n'];
end
[~, matchend] = regexp(toc, headingexp);

% If heading entry doesn't exist, just use main heading
while isempty(matchend) && ~strcmp(prevname, 'START')
    headingexp = ['<tocitem\s*target="', fullfile('html', hpage), ...
       '"((\s)*image=".*?")?>\s*', heading, '\n'];
    [~, matchend] = regexp(toc, headingexp);
end

% Insert entry after matchend
arraytoc = {toc};
beginning = arraytoc{1}(1:matchend);
finish = arraytoc{1}(matchend+1:end);
toc = sprintf([beginning, entry, finish]);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function title = getexampletitle(hbname, toctext)
    % Get title from the helptoc.xml page
    pathtohtml = fullfile('html', regexprep(hbname, '\.m', '.html'));
    helptocexp = ['<tocitem\s*target="', pathtohtml, '"((\s)*image=".*?")?>(.*?)</tocitem>'];
    tokenstring = regexp(toctext, helptocexp, 'tokens', 'once');
    
    % If you don't find it on the helptoc.xml page, type one in
    if isempty(tokenstring) == 1
        title = input(['Enter a title for the ', hbname, ' page:\n'], 's');
        % Add the helptoc.xml entry for the example
    else
        tokenstring = tokenstring{2};
        title = strtrim(tokenstring);
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function publishexample(path, name)
% Publish example to html
    opts = struct('outputDir', fullfile(path, 'html'));
    publish(name, opts);
    fprintf([name(1:end-2), '.html updated.\n']);
    close all;
end