

X=Xrinse;
t=rinses;
s=floor(length(t)/1000);
X=X(1:s:end);
t=t(1:s:end);

p = polyfit(X,t,2);
%p=[0 0];

figure(1);
clf;
plot(X,t);
hold all;
plot(X,polyval(p,X));
hold off;

J=1;
t=traces{J,1};
X=traces{J,2};

t =t- polyval(p,X);

[v, bins]=hist(t,300);
d=bins(2)-bins(1);
bins=[ (d*(-100:-1) + bins(1)) bins' (d*(1:10) + bins(end))];
bins=-100:1:400;
figure(1);
clf;
clear allV;
for J=2:size(traces,1)
    
    t=traces{J,1};
    X=traces{J,2};
    
        e=length(t);
        t=t(floor(e*.66):end);
        X=X(floor(e*.66):end);
    
    t =t- polyval(p,X);
%     t=[];
%     for I=1:100:length(t2)
%         try
%             tm=max(t2(I:I+99))-min(t2(I:I+99));
%             
%             t=[t tm];
%         catch mex
%         end
%     end
    v =hist(t,bins);
    v(1)=0;
    v(end)=0;
    
    v=v/sum(v);
    I=J;
    plot(bins,v,colors{ 1+mod(I-2, length(colors))});
    hold all;
    drawnow
    
    allV(:,J-1)=v(:);
end



legend(names{2:end});