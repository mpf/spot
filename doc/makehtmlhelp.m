function makehtmlhelp
%MAKEHTMLHELP  Produce HTML version of Spot's help.
 
% Get parent directory and path of examples
fullpath = mfilename('fullpath');
idx      = find(fullpath == filesep);
docpath = fullpath(1:idx(end));

   % Make the 'htmlhelp' dir
   htmlpath = fullfile(docpath, 'html', 'htmlhelp');
   [~,~,~] = mkdir(htmlpath);
   
   % Augmented d with H1, fullpath, etc.
   d1 = dir(fullfile(spot.path,'*.m'));   
   d1 = getfileinfo(d1,spot.path);

   % Augmented d with H1, fullpath, etc.
   d2 = dir(fullfile(spot.path,'@opSpot','*.m'));   
   d2 = getfileinfo(d2,fullfile(spot.path,'@opSpot'));
   
   d = [d1;d2];

   % Create individual help file.
   for i=1:numel(d)
       fprintf('Processing %20s\n',d(i).name);
       htmlfile = fullfile(htmlpath,sprintf('%s.html',d(i).mfilename));
       htmlfid = fopen(htmlfile,'w+');
       htmlout = help2html(fullfile(d(i).fullpath,d(i).mfilename));
       fprintf(htmlfid,'%s',htmlout);
       fclose(htmlfid);
   end
   
   % Create a contents file
   htmlfid = fopen(fullfile(htmlpath, 'Contents.html'),'w+');
   for i=1:numel(d)
       fprintf(htmlfid,'%s\n',d(i).h1);
   end
   fclose(htmlfid);
end

function d = getfileinfo(d,dir)
   maxNameLen = 0;
   killIndex = [];
   for n = 1:length(d)
      d(n).mfilename = regexprep(d(n).name,'\.m$','');
      d(n).fullpath = dir;
      if strcmp(d(n).mfilename,'Contents')
         % Special case: remove the Contents.m file from the list
         % Contents.m should not list itself.
         killIndex = n;
      else
         d(n).h1 = getdescription(d(n).name);
         maxNameLen = max(length(d(n).mfilename), maxNameLen);
      end
   end
   d(killIndex) = [];
end   
   

function result = ismfile(file)
%ismfile  return true if file is an m-file.
   [~,~,ext] = fileparts(file);
   result = strcmp(ext,'.m');
end
   