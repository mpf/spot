How the Spot Help Browser Works
===============================
Frances Russell, August 8 2012

The spot/doc folder contains the files necessary for Spot to show up in the Matlab help browser. I have written a few functions to automatically update these files when Spot changes. If you want to export Spot to a .zip file, first run spothelpbrowser.m, then commit your changes to git, and finally run spotexport.m. This is because spotexport.m uses the version of Spot most recently commited to git.

>> SPOTHELPBROWSER.M

You can update the whole help browser by running spothelpbrowser.m from Matlab. Here is what it does:

- If there are new or altered examples in the website folder (spotdoc/web/matlab_published/mfiles), it copies them and puts them in spot/doc, renaming them with 'doc' in the file name, editing them so that they will work in the help browser, and publishing them
- Updates the html help files for all the Spot methods and operators in spot/doc/html/htmlhelp
- Ensures that every html help file and example has an entry in helptoc.xml
- Ensures that every html help file and example is listed in the appropriate help browser page (such as spot_methods.m)
- Publishes the main help browser pages

spothelpbrowser.m will prompt you to enter the path to the spotdoc folder. Make sure that this includes 'spotdoc' itself, for example:

C:/Users/Joe/projects/spotdoc

If you have added a new Spot operator, it will ask you which category to put it under (e.g. 'Elementary Operators' or 'Random Ensembles'). If you don't like the order that the function has listed things in the help browser files or helptoc.xml, you can manually rearrange them. spothelpbrowser.m relies on makehtmlhelp.m and strcmpc.m, so make sure to leave these functions in spot/doc.

>> HELPTOC.XML

This is the table of contents file. It has to have this name. You can add new sections and pages to it as you like.

>> SPOT/DOC

This folder contains several .m files that are the main help browser pages (e.g. elementary_operators.m). It also contains the examples taken from the website folder, which have names like docguide_circulant.m. To add a new help browser page that isn't just an example or an operator or method help page (for example, a new category of operator):

- Save it as a .m file in spot/doc
- Add an entry for it in helptoc.xml
- Add it to spothelpbrowser.m. Near the very top of the spothelpbrowser.m file is a variable called 'mainpages'. Add your page to the list.

>> SPOT/DOC/HTML

These pages are all the html pages that will show up in the help browser (as long as they are in helptoc.xml).

>> SPOT/DOC/HTML/HTMLHELP

These are the pregenerated html help pages for the Spot methods and operators. This is done by makehtmlhelp.m, which is called by spothelpbrowser.m. If there are some methods and operators that for whatever reason don't have any available help, you can leave them out of the help browser by adding them to the 'nohelp' list in spothelpbrowser.m. This is a variable defined near the top of the file, just under 'mainpages'.

