clc;
a=round(10*rand(50));
b=round(10*rand(50));
diviseurs=1;

for i=2:2500
    if mod(2500,i) == 0
        diviseurs=[diviseurs,i];
    end
end

time=zeros(length(diviseurs));

for i=1:length(diviseurs)
    i
    a=reshape(a,diviseurs(i),2500/diviseurs(i));
    cost(i)=(size(a,1)-size(a,2))/2500;
    for j=1:length(diviseurs)
        j
        b=reshape(b,diviseurs(j),2500/diviseurs(j));
        A=opKron(a,b);
        tic;
        double(A);
        time(i,j)=toc;
    end
end


