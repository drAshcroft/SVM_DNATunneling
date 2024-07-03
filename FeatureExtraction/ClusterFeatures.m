function [clusterParams]=ClusterFeatures(minFFTSize,nComponents,chunk, ...
    chunkEmpty,peaksInCluster, clusterParams,runParams)

importantChunk = chunk(chunk>(runParams.baseline_Threshold*300));
%chunk =chunk;
%chunkEmpty=chunkEmpty;
averageAmplitude = mean(chunk);
top=find(chunk>averageAmplitude);
topAmp=mean(chunk(top));
peakwidth = (length(top)/50000*1000);
roughness = std( chunk(top)/topAmp  );%/averageAmplitude;


clusterParams.C_peaksInCluster=peaksInCluster;
clusterParams.C_frequency=peaksInCluster/length(chunk)*1000;
clusterParams.C_averageAmplitude=averageAmplitude;
clusterParams.C_topAverage=topAmp;
clusterParams.C_clusterWidth=peakwidth;
clusterParams.C_roughness=roughness;
clusterParams.C_maxAmplitude=( max(chunk(2:(length(chunk)-2))) -min(chunk(2:(length(chunk)-2)))   );

FFTSize=max([length(chunk) minFFTSize]);

try
    
    [TotalPowerW,powerspecW]= DenoiseSpecWhole(chunk,chunkEmpty,256);
    clusterParams.C_clusterFFT_Whole=powerspecW;
    
    [TotalPower,powerspec]=DenoiseSpec(chunk,chunkEmpty,FFTSize);
    
    Lspec=powerspec(3:end-15);
    Lspec = smooth(Lspec,31);
    Lspec=Lspec-Lspec(end)+.01;
    Lspec=Lspec./sum(Lspec);
    %Lspec=Lspec.*(1:length(Lspec))';
    x=1:length(Lspec);
    try
        try
            f=fit(x',Lspec,'exp2');
            
            f=f.a*exp(f.b*x) + f.c*exp(f.d*x);
            f(isnan(f))=0;
            if isnan(sum(f))
                disp('nan in clusterfeatures');
            end
            e=mean(powerspec(end-20:end))*2;
            Lspec= (e + Lspec)./ ( e + f)'-1;
        catch mex
            
            f=smooth(Lspec,101);
            f(isnan(f))=0;
            if isnan(sum(f))
                disp('nan in clusterfeatures');
            end
            e=mean(powerspec(end-20:end))*2;
            Lspec= (e + Lspec)./ ( e + f)-1;
        end
    catch mex
        disp('nan in clusterfeatures');
    end
    specLength =length(powerspec);
    
    n=specLength;
    n1=round(specLength/2);
    n2=n-5;
    
    clusterParams.C_totalPower=TotalPower;
    clusterParams.C_iFFTLow= powerspec(5)+powerspec(6)+powerspec(7);
    clusterParams.C_iFFTMedium=powerspec(n1)+powerspec(n1+1)+powerspec(n1+2);
    clusterParams.C_iFFTHigh=powerspec(n2)+powerspec(n2+1)+powerspec(n2+2);
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    [pks loc]=findpeaks(Lspec);
    
    locs=loc;
    
    KK=2;
    while KK<length(locs)
        if abs(locs(KK)-locs(KK-1))<51
            locs(KK)=[];
            pks(KK)=[];
        else
            KK=KK+1;
        end
    end
    
    [v idx]=sort(pks,'descend');
    locs=locs(idx);
    
    %make sure to put it into the form of a ratio to deal with the
    %different run lengths
    locs = vertcat(locs ,zeros([4 1]));
    locs = locs./length(Lspec);
    
    clusterParams.C_freq_Maximum_Peaks=locs(1:4)*25;
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    specLength =length(powerspec);%round(length(powerspec)/2);
    peakCoef = zeros([nComponents 1]);
    %reduce the complexity to just a few parameters.  Since the spacing is
    %only dependant on
    
    indxs = round( specLength * (0: (1/nComponents) :1).^2);
    if indxs(1)==0;
        indxs=indxs+1;
    end
    
    for iI=2:length(indxs)
        if  indxs(iI)==indxs(iI-1)
            indxs(iI:end)=indxs(iI:end) + 1;
        end
    end
    
    indxs(indxs>length(powerspec))=length(powerspec);
    cc3=1;
    
    for k=1:nComponents
        try
            peakCoef(cc3) =mean(  powerspec(indxs(k):indxs(k+1) ));
        catch mex
            disp (mex);
        end
        cc3=cc3+1;
    end
    
    clusterParams.C_clusterFFT=peakCoef;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    clusterParams.C_highLow=mean(peakCoef(round(end*.75):end))/ mean( peakCoef(1:round(end*.25)));
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %now handle the cepstrum to get the underlying structure of the
    %data
    peakCoef = zeros([nComponents 1]);
    cepstrum = fft(powerspec(2:end));
    cepstrum = cepstrum /length(cepstrum);
    cepstrum=cepstrum(1:round(end/2));
    cepstrum=abs(cepstrum).^2;
    cepstrum(1)=0;
    
    %     x=(2:length(cepstrum))';
    %     f=fit(x,cepstrum(2:end),'exp1');
    %     f=f.a*exp(f.b*x);
    %     cepstrum(2:end)=cepstrum(2:end)-f;
    
    %reduce the complexity to just a few parameters.  Since the spacing is
    %only dependant on
    % cepstrum=cepstrum./specLength;
    specLength=length(  cepstrum);
    for k=1:(specLength)
        bin =floor( k/(specLength)*(nComponents-1))+1;
        peakCoef(bin) = peakCoef(bin)+cepstrum(k);
    end
    
    clusterParams.C_clusterCepstrum=peakCoef;
    
catch mex
    dispError(mex);
    disp(mex.stack(1,1));
end