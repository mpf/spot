%% Interpolation of partially sampled DCT-Haar signal


%% Create synthesis operators
D = opDCT(512);
H = opHaar(512,8);

%% Create sparse signal
rng(2);
p = randperm(48);
xd = zeros(512,1); xd(p(1:5)) = randn(5,1);
p = randperm(10);
xh = zeros(512,1); xh(p(1:5)) = randn(5,1);
signalD = D' * xd;
signalH = H' * xh;
signal  = signalD + signalH;

%% Create synthesis dictionary
B = [D',H'];

%% Sample at random locations
rng(1);
p = randperm(512);
idx = sort(p(1:85));
plot(1:length(signal),signal,'b-',idx,signal(idx),'r*');

R = opRestriction(512,idx);
A = R*B; % A = B(idx,:);
x = spg_bp(A,signal(idx));

hold on; plot(B*x,'r--'); hold off;

