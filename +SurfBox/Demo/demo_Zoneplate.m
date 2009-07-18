%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%	SurfBox-MATLAB (c)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%%	Yue Lu and Minh N. Do
%%
%%	Department of Electrical and Computer Engineering
%%	Coordinated Science Laboratory
%%	University of Illinois at Urbana-Champaign
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%%	demo_ZonePlate.m
%%	
%%	First created: 04-22-06
%%	Last modified: 04-23-06
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

disp(' ');
disp(' ');
disp('In this demo, we apply the surfacelet transform to a 3-D zoneplate image.');
disp('We then reconstruct the volume by passing through only one subband to the reconstructor.');
disp('We can see clearly that the surfacelet filters are directional, bandpass,');
disp('and well-localized in the frequency domain.');
disp(' ');
disp('Make sure the Matlab folder of SurfBox is on the search path.');
disp(' ');
disp('Note: It may take a while for Matlab to render the 3-D volumes');


N = 96;
step = 1;

%% Generate a 3-D zoneplate image
x = zoneplate3d(N / 2, 40000, 0.0005);

r = input('Press <enter> to generate the 3-D zoneplate image ...');
h = figure('name', '3-D Surfacelets (Left: 3-D Zoneplate, Right: One Surfacelet Subband)', 'NumberTitle', 'off');
clf; colordef(h, 'white'); colormap jet; set(gcf,'Position',[150,150,640,320]);

subplot(1, 2, 1);
hz=slice(x,[],[],[1:step*6:N]);
alpha('color')
axis tight
set(hz,'EdgeColor','none','FaceColor','interp', 'FaceAlpha','interp');
alphamap('rampdown');
daspect([1 1 1]);
alphamap(0.5 * alphamap);
drawnow;

disp(' ');
r = input('Press <enter> to show one surfacelet subband. This may take a while ...');

%% Surfacelet Decomposition
Pyr_mode = 1;
Lev_array = {[-1 0 0; 0 -1 0; 0 0 -1], [-1 1 1; 1 -1 1; 1 1 -1]};
HGfname = 'ritf';
bo = 12;

[Y, Recinfo] = Surfdec(x, Pyr_mode, Lev_array, HGfname, 'bo', bo);

%% Let only one subband to pass through
U = 3;
V = 2;

for i = 1 : length(Y) - 1
    for j = 1 : 3
        for k = 1 : length(Y{i}{j})
            if (i ~= 2) || (j ~= U) || (k ~= V)
                Y{i}{j}{k} = 0 * Y{i}{j}{k};
            end
        end
    end
end

Y{end} = 0 * Y{end};

%% Now get the reconstruction
rec = Surfrec(Y, Recinfo);

rec = rec / max(rec(:));

h = subplot(1, 2, 2);
hz=slice(rec * 1.5,[],[],[1:step:N]);
alpha('color')
axis tight
set(hz,'EdgeColor','none','FaceColor','interp', 'FaceAlpha','interp');
alphamap('rampdown');
daspect([1 1 1]);
alphamap(0.5 * alphamap - 0.3);
drawnow;

%%	This software is provided "as-is", without any express or implied
%%	warranty. In no event will the authors be held liable for any 
%%	damages arising from the use of this software.
