% Generate and plot image
img = zeros(64,64);
img(6:32,6:32) = 0.5;
[x,y] = meshgrid(1:64,1:64);
z = ((x-32).^2+(y-32).^2) < 12^2; % Circle of radius 12 around (32,32);
img(z) = 1;

figure(1); subplot(3,3,1);
pcolor(img), shading flat, colormap gray; set(gca,'YDir','reverse');

% Create finite difference operator
d1 = [0,1,-1];
d2 = [1,-2,1];

d = d2;
M = spdiags(repmat(d,64,1),-1:1,64,64);
M(1,end) = d(1);
M(end,1) = d(3);

M = opMatrix(M);

figure(1); subplot(3,3,2);
pcolor(M*img), shading flat, colormap gray; set(gca,'YDir','reverse');

figure(1); subplot(3,3,3);
pcolor(img*M'), shading flat, colormap gray; set(gca,'YDir','reverse');

figure(1); subplot(3,3,4);
pcolor(M*img + img*M'), shading flat, colormap gray; set(gca,'YDir','reverse');

figure(1); subplot(3,3,5);
M2 = opKron(opEye(64),M) + opKron(M,opEye(64));
pcolor(reshape(M2*img(:),64,64)), shading flat, colormap gray; set(gca,'YDir','reverse');

figure(1); subplot(3,3,6);
rng('default');
imgNoisy = img + 0.3*randn(64,64);
pcolor(imgNoisy), shading flat, colormap gray; set(gca,'YDir','reverse');

b = [imgNoisy(:);zeros(64*64,1)];


figure(1); subplot(3,3,7);
delta = .1; A = [opEye(64*64); delta * M2];
x = A \ b;
pcolor(reshape(x(1:64^2),64,64)), shading flat, colormap gray; set(gca,'YDir','reverse');

figure(1); subplot(3,3,8);
delta = 1; A = [opEye(64*64); delta * M2];
x = A \ b;
pcolor(reshape(x(1:64^2),64,64)), shading flat, colormap gray; set(gca,'YDir','reverse');

figure(1); subplot(3,3,9);
delta = 5; A = [opEye(64*64); delta * M2];
x = A \ b;
pcolor(reshape(x(1:64^2),64,64)), shading flat, colormap gray; set(gca,'YDir','reverse');

