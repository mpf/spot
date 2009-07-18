%--------------------------------------------------------------------------
%	SurfBox-MATLAB (c)
%--------------------------------------------------------------------------
%
%	Yue M. Lu and Minh N. Do
%
%--------------------------------------------------------------------------
%
%	mexcompile.m
%	
%	First created: 12-11-08
%	Last modified: 12-12-08
%
%--------------------------------------------------------------------------

% This routine compiles the mex files used to accelerate the surfacelet
% transform.
%
% Send an email to Yue M. Lu if you have any trouble getting the mex files
% correctly compiled.
%
%
% You need to customize this file by following the instructions below.
%
%--------------------------------------------------------------------------
% Start customization
%--------------------------------------------------------------------------
%
% Step 0: If you have never done so before, type
%
%  mex -setup
%
% in your Matlab command window, and setup your mex configuration.


if ispc
    % ---------------------------------------------------------------------
    % For Windows users, do the following; otherwise, go to the section for
    % Mac and Unix users.
    % ---------------------------------------------------------------------
    %
    % We assume you have Microsoft Visual C++ installed. If you don't, send
    % me an email with the version information of your Matlab and Windows.
    % If available, I will send you a precompiled mex file.
    %
    % Step 1: Download and install the precompiled FFTW package from
    % http://www.fftw.org/install/windows.html
    %
    % In order to link to them from Visual C++, you will need to create
    % .lib "import libraries" using the lib.exe program included with VC++. 
    %
    % Run:
    %
    %   lib /def:libfftw3-3.def
    %   lib /def:libfftw3f-3.def
    %   lib /def:libfftw3l-3.def
    %
    % Note: lib.exe can be found in a subdirectory of your VC++
    % installation. Add that directory to your system search path. If
    % Windows complains about missing dll files, search for the directory
    % where these files are and add the directory to your search path too.
    %
    % Step 2: Customize the following directories according to your setting
    FFTW_include = 'C:/fftw-3.2-dll';
    FFTW_lib = FFTW_include;
    LIB_name = 'libfftw3-3.lib';
    
else
    % ------------------------
    % For Mac and Unix users: 
    % ------------------------
    
    % Step 1: Download and compile the FFTW package from www.fftw.org.
    % Installation can be as simple as
    %
    %  ./configure
    %  make
    %  make install
    %  make check
    %
    % Step 2: Customize the following two directories according to your
    % setting.
    %
    % 2.1 Change the include directory
    FFTW_include = '/usr/local/include'; % where fftw3.h is installed
    
    % 2.2 Change the lib directory
    FFTW_lib = '/usr/local/lib'; % where libfftw3.a is installed
    
    LIB_name = 'libfftw3.a';
end

% For both PC and Unix:
%
% Step 3: Set SURFBOX_dir to be the full path to the directory where you
% installed the SurfBox.
SURFBOX_dir = '/Users/yuelu/Documents/MATLAB/SurfBox';
% for PC: it might be, for example, SURFBOX_dir = 'C:/Documents/MATLAB/SurfBox';

%--------------------------------------------------------------------------
% End customization
%--------------------------------------------------------------------------

cd(SURFBOX_dir);

disp(' ');
disp('Compiling and linking ...');

% Basic SufBox programs
SURFSRC = ['Cpp/HourglassFilterBank.cpp Cpp/NdDirectionalFilterBank.cpp ' ...
 'Cpp/SurfArray.cpp Cpp/SurfMatrix.cpp Cpp/SurfaceletFilterBank.cpp ' ...
    'Cpp/PyramidFilterBank.cpp Cpp/SurfBoxSystem.cpp ' FFTW_lib '/' LIB_name];

% Compile mex files
eval(['mex ' 'mex/mexSurfaceletDec.cpp ' SURFSRC ' -I' FFTW_include ...
        ' -outdir Matlab']);


eval(['mex ' 'mex/mexSurfaceletRec.cpp ' SURFSRC ' -I' FFTW_include ...
        ' -outdir Matlab']);
    
mex Matlab/resampc.c -outdir Matlab;