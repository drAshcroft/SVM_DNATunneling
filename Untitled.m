labels=dataTable(:,1);
analytes = unique(labels);


X=1:1:200;
for J=7:270
    clf;
    for I=1:length(analytes)
        A=analytes(I);
        idx=find(labels==A);
        amps=dataTable(idx,J);
        s=std(amps);
        m=mean(amps);
        X=m-2*s:s/200:m+2*s;
        v=hist(amps,X);
        v=v./sum(v);
        plot(X,v);
        hold all;
    end
end