

X=Xrinse;
t=rinses;
s=floor(length(t)/1000);
X=X(1:s:end);
t=t(1:s:end);

p=mean(t(1:200));
%p = polyfit(X,t,2);
p=[0 0];

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
bins=0:.2:100;%[ (d*(-100:-1) + bins(1)) bins' (d*(1:100) + bins(end))];

figure(1);
clf;
features={};
cc=1;
for J=2:size(traces,1)
    
    t=traces{J,1};
    X=traces{J,2};
    
    e=length(t);
    t=t(floor(e*2/3):end);
    X=X(floor(e*2/3):end);
    
    t =t- polyval(p,X);
    
    [pks,loc]=findpeaks(t,'minpeakdistance',150);
    
    sizeWindow=150;
    for K=1:length(loc);
       sI=max([1 loc(K)-sizeWindow]);
       eI=min([length(t) loc(K)+sizeWindow]);
       pks(K)=max(t(sI:eI))-min(t(sI:eI));
    end
   
    t=t-mean(t);
    t=t./std(t);
    lev   = 25;
    wname = 'sym2';
    nbcol = 64;
    [c,l] = wavedec(t,lev,wname);
    
    %Expand the discrete wavelet coefficients for visualization
    
    len = length(t);
    cfd = zeros(lev,len);
    for k = 1:lev
        d = detcoef(c,l,k);
        d = d(:)';
        d = d(ones(1,2^k),:);
        cfd(k,:) = wkeep1(d(:)',len);
    end
    cfd =  cfd(:);
    I = find(abs(cfd)<sqrt(eps));
    cfd(I) = zeros(size(I));
    cfd = reshape(cfd,lev,len);
    cfd = wcodemat(cfd,nbcol,'row');
    
    datapack.features = zeros([size(cfd,1) length(loc)]);
    for K=1:length(loc)
        try
            sI=max([0 loc(K)-sizeWindow]);
            eI=min([length(t) loc(K)+sizeWindow]);
            me=mean(cfd(:,sI:eI),2);
            datapack.features(:,K)=me;
        catch mex
            me=mean(cfd(:,loc(K)));
            datapack.features(:,K)=me;
        end
    end
    
   % datapack.features =cfd(:,loc);
    clear cfd;
    
    datapack.pks=pks;
    clear pks;
    v =hist(datapack.pks,bins);
    v(1)=0;
    v(end)=0;
    
    v=v/sum(v);
    I=J;
    plot(bins,v,colors{ 1+mod(I-2, length(colors))});
    hold all;
    drawnow
    
    features{cc}=datapack;
    cc=cc+1;
    clear datapack;
end

legend(names{2:end});