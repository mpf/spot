% random_phases.m
%
% Create array of random phases, with symmetries for a real-valued 3D
% image.
%
function PHS = random_phasesND(dims)

p1 = exp(1i*2*pi*rand(dims));
p2 = fftn(real(ifftn(p1)));
PHS = p2./abs(p2);
