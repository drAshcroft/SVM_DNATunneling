figure(1);clf;
figure(2);clf;

figure(4);clf;
figure(5);clf;
figure(6);clf;
figure(7);clf;
figure(8);clf;
figure(9);clf;
figure(10);clf;
figure(11);clf;
figure(12);clf;
figure(13);clf;
figure(14);clf;
figure(15);clf;
Xcc=1;
for I=2:size(allSmoothed,1)
    if I==2
        t=allSmoothed{I,1};
    else
        if I==5
            t=allSmoothed{I,1};
        else
            t=allSmoothed{I,1};
        end
    end
    t=t/255;
    %t=t(floor(4.1e5):floor(4.7e5));
    figure(4)
    plot((1:length(t))/20000,t);
    X=Xcc+(1:length(t));
    Xcc=X(end)+1;
    figure(10);
%     plot(X(1:300:end),t(1:300:end));
    hold all;
    
    
    figure(7)
    [v, bins]=hist(t,1:10:700);
%     plot(bins,v/sum(v),'LineWidth',2);
    xlabel('Amplitude(pA)');
    ylabel('count');
    hold all;
    
    peaks =( peakfinder(v-100,200,20,1));
    
    v=v/max(v);
    for J=peaks(1):length(bins)
        if v(J)<.2
            middle = sum(bins(1:J).*v(1:J))/sum(v(1:J));
            break;
        end
    end
    t=t-middle;
    
    figure(11)
    [v, bins]=hist(t,-100:10:250);
%     plot(bins,v/max(v),'LineWidth',2);
    xlabel('Amplitude(pA)');
    ylabel('count');
    hold all;
    
    d=(diff(t));
    thresh = std(d(1:200))*3;
    idxP=peakfinder(d,1,thresh,1);
    idxN=peakfinder(d*-1,1,thresh,1);
    
    assignment = zeros(size(t));
    assignment(idxP)=1;
    assignment(idxN)=-1;
    pairFound =true;
    pairs=zeros([2 size(idxP,1)]);
    cPairs =1;
    
    lastP=length(assignment);
    J=1;
    Found =100;
    while Found >10
        Found=0;
        
        for J=1:length(assignment)
            if assignment(J)>0
                lastP=J;
            end
            if assignment(J)==-1 && J>lastP
                assignment(lastP)=0;
                assignment(J)=0;
                pairs(1,cPairs)=lastP;
                pairs(2,cPairs)=J;
                cPairs=cPairs+1;
                Found =Found+1;
                lastP=length(assignment);
            end
        end
        Found
    end
    pairs=pairs(:,1:(cPairs-1));
    
    
%     ccX=1;
%     for I=1:size(pairs,2)
%         w=t(pairs(1,
%         plot(
%         
%     end
    
    
    level = 1;
    [c,l] = wavedec(t,level,'haar');
    wAmplitude =zeros([1 cPairs-1]);
    
    for J=1:level
        d1 =( detcoef(c,l,J));
        d1=interpft(d1,round(length(t)/length(d1))*length(d1));
        for K=1:cPairs-1
            wAmplitude(K)=max( d(pairs(1,K):pairs(2,K)));
        end
    end
    
    
    pAmplitude =zeros([1 cPairs-1]);
    dAmplitude =zeros([1 cPairs-1]);
    for J=1:cPairs-1
        pAmplitude(J)=mean( t(pairs(1,J):pairs(2,J)));
        dAmplitude(J)=max( d(pairs(1,J):pairs(2,J)));
    end
    %idx=find(d>thresh);
    idx=[idxP' idxN'];
    d=abs(d);
    amplitudes = d(idx);
    gaps = pairs(2,:)-pairs(1,:);%idx(2:end)-idx(1:end-1);
    idx=find(gaps<4);
    spikeAmplitudes = pAmplitude(idx);
    diffSpikeAmplitudes = dAmplitude(idx);
    platAmplitudes = pAmplitude;
    platAmplitudes(idx)=[];
    wAmplitude=wAmplitude(idx);
    %     idx=find(gaps~=1);
    %     gaps = idx(2:end)-idx(1:end-1);
    
    amplitudes(amplitudes<20)=[];
    figure(1)
    [v, bins]=hist(amplitudes,1:5:150);
%     plot(bins,(v)/sum(v),'LineWidth',2);
    xlabel('Amplitude Change (pA)');
    ylabel('count');
    hold all;
    
    
    figure(12)
    [v, bins]=hist(pAmplitude,-50:10:300);
%     plot(bins,v/sum(v),'LineWidth',2);
    xlabel('Peak Amplitude(pA)');
    ylabel('count');
    hold all;
    
    figure(14)
    [v, bins]=hist(platAmplitudes,-50:10:300);
%     plot(bins,v/sum(v),'LineWidth',2);
    xlabel('Plat Amplitude(pA)');
    ylabel('count');
    hold all;
    
    figure(15)
    [v, bins]=hist(wAmplitude,0:5:200);
%     plot(bins,v/sum(v),'LineWidth',2);
    xlabel('Wave 1 Spike Amplitude(pA)');
    ylabel('count');
    hold all;
    
    figure(13)
    [v, bins]=hist(spikeAmplitudes,-50:16:350);
%     plot(bins,v/sum(v),'LineWidth',2);
    xlabel('Spike Peak Amplitude(pA)');
    ylabel('count');
    hold all;
    
    figure(9)
    [v, bins]=hist(diffSpikeAmplitudes,-50:16:250);
%     plot(bins,v/sum(v),'LineWidth',2);
    xlabel('Diff Spike Peak Amplitude(pA)');
    ylabel('count');
    hold all;
    
    for K=1:length(gaps)
        allGaps(K,I)=gaps(K);
    end
    
    figure(2)
    if I==2
        [v, binsT]=hist(gaps,10);
        binsT=[binsT (binsT + binsT(end))];
        [v]=hist(gaps,binsT);
    else
        [v]=hist(gaps,binsT);
    end
    
    b2=binsT(:);
    idx=find(v==0);
    b2(idx)=[];
    v(idx)=[];
    % binsT=1:10:1000;
    % v=hist(gaps,binsT);
    v(end)=0;
    semilogy(b2/20000*1000,v,'-','LineWidth',2);
    xlabel('plateau time (ms)');
    ylabel('count');
    hold all
    
    
    
    cc2=1;
    step =10000
    bottom = zeros([1 floor(length(t)/step)]);
    for M=1:step:length(t)
        try
            bottom(cc2)=min(t(M:M+step-1));
            cc2=cc2+1;
        catch mex
        end
    end
    bottom=[bottom(1:cc2-4) t(end)];
    figure(5)
    X=(1:length(bottom))*step ;
    X(end)=length(t);
    f1=fit(X',bottom','poly1','Robust','Bisquare');
    %     plot(feval(f1,1:length(t)));
    %     hold all
    %     plot(X,bottom);
    bottomSub = bottom - feval(f1,X)';
    thresh2 =std(bottomSub );
    idx=find( abs(bottomSub)>thresh2);
    
    X(idx)=[];
    bottom(idx)=[];
    
    %     plot(X,bottom+1000);
    
    %t = t - feval(f1,1:length(t));%+ feval(f1,1);
    t = t - spline(X,bottom,1:length(t))';
    if I==2
        t=t+50;
    end
    
    t=smooth(t,1000);
    
    plot(t);
    disp(length(t));
    hold off
    
    
    figure(8)
    [v, bins]=hist(t,-50:1:250);
    plot(bins,(v+1)/max(v),'LineWidth',2);
    xlabel('Amplitude(pA)');
    ylabel('count');
    hold all;
    
    
    idx=find(t>10);
    gapsB = idx(2:end)-idx(1:end-1);
    idx=find(gapsB~=1);
    gapsB = idx(2:end)-idx(1:end-1);
    
    figure(6)
    % binsT=1:10:1000;
    if I==2
        [v, binsB]=hist(gapsB,binsT*5);
        %  binsB=  binsT
    else
        [v]=hist(gapsB,binsB);
    end
    v(end)=0;
    semilogy(binsB/20000*1000,v,'LineWidth',2);
    xlabel('molecule(?) time (ms)');
    ylabel('count');
    hold all
    %     figure(3);
    %     scatter(amplitudes(1:length(gaps)),gaps);
    %     hold all
end
figure(1);
legend(names(2:end));
figure(2);
legend(names(2:end));
figure(6);
legend(names(2:end));
figure(7);
legend(names(2:end));
figure(8);
legend(names(2:end));
figure(9);
legend(names(2:end));
figure(10);
legend(names(2:end));

figure(11);
legend(names(2:end));
figure(12);
legend(names(2:end));
figure(13);
legend(names(2:end));
figure(14);
legend(names(2:end));

figure(15);
legend(names(2:end));
