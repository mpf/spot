function FigConvolution

prefix     = mfilepath(mfilename('fullpath'));
linewidth  = 2;
markerSize = 6;
fontSize   = 20;

g = [linspace(0,1,15),ones(1,13),zeros(1,5)]';

f1 = zeros(100,1); f1(10) = 0.5;
f2 = zeros(100,1); f2(45) = 1;
f3 = zeros(100,1); f3(60) = 2;
f4 = zeros(100,1); f4(90) = 1;
f = f1+f2+f3+f4;

Cr = opConvolve(100,1,g,15,'regular');
Ct = opConvolve(100,1,g,15,'truncated');
Cc = opConvolve(100,1,g,15,'cyclic');


% Plot mask and anchor
figure(1); clf; gca; set(gca,'FontSize',fontSize);
h = plot(1:length(g),g,'k-',15,g(15),'b*',[15,15],[0,g(15)],'b--');
set(h,'Linewidth',linewidth,'MarkerSize',markerSize);
ylim([0,2.5]); xlim([1,length(g)]);
ExportFigurePDF(prefix,'FigSparcoConvMask.pdf');

% Plot f
v = f; v(v == 0) = NaN;
figure(2); clf; gca; set(gca,'FontSize',fontSize);
h = stem(v);
set(h,'Linewidth',linewidth,'MarkerSize',markerSize);
ylim([0,4]);
ExportFigurePDF(prefix,'FigSparcoConvFun.pdf');


% Regular convolution
figure(3); clf; gca; hold on; box on;
h1 = stem(v,'b--');
h2 = plot(-13:118,Cr*f1,'k-', -13:118,Cr*f2,'k-', ...
          -13:118,Cr*f3,'k-', -13:118,Cr*f4,'k-');
h3 = plot([1,1],[0,4],'b--',[100,100],[0,4],'b--');
hold off
set(h2,'Linewidth',linewidth);
set(h3,'Color',[0.6,0.6,0.7]);
set(gca,'FontSize',fontSize); ylim([0,4]); xlim([-13,118]);
ExportFigurePDF(prefix,'FigSparcoConvRegular1.pdf');

h1 = plot(-13:118,Cr*f,'k-'); hold on;
h2 = plot([1,1],[0,4],'b--',[100,100],[0,4],'b--'); hold off;
set(h1,'Linewidth',linewidth);
set(h2,'Color',[0.6,0.6,0.7]);
set(gca,'FontSize',fontSize); ylim([0,4]); xlim([-13,118]);
ExportFigurePDF(prefix,'FigSparcoConvRegular2.pdf');



% Truncated convolution
figure(4); clf; gca; hold on; box on;
h1 = stem(v,'b--');
h2 = plot(1:100,Ct*f1,'k-', 1:100,Ct*f2,'k-', ...
          1:100,Ct*f3,'k-', 1:100,Ct*f4,'k-');
hold off
set(h2,'Linewidth',linewidth);
set(gca,'FontSize',fontSize); ylim([0,4]);
ExportFigurePDF(prefix,'FigSparcoConvTrunc1.pdf');

h = plot(1:100,Ct*f,'k-');
set(h,'Linewidth',linewidth);
set(gca,'FontSize',fontSize); ylim([0,4]);
ExportFigurePDF(prefix,'FigSparcoConvTrunc2.pdf');


% Cyclic convolution
figure(5); clf; gca; hold on; box on;
h1 = stem(v,'b--');
h2 = plot(1:100,Cc*f1,'k-', 1:100,Cc*f2,'k-', ...
          1:100,Cc*f3,'k-', 1:100,Cc*f4,'k-');
hold off
set(h2,'Linewidth',linewidth);
set(gca,'FontSize',fontSize); ylim([0,4]);
ExportFigurePDF(prefix,'FigSparcoConvCycl1.pdf');

h = plot(1:100,Cc*f,'k-');
set(h,'Linewidth',linewidth);
set(gca,'FontSize',fontSize); ylim([0,4]);
ExportFigurePDF(prefix,'FigSparcoConvCycl2.pdf');

