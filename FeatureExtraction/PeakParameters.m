function [peakParams]=PeakParameters(chunk, chunkempty,nComponents, runParams,minFFTSize, peakParams)

% peakParams(nPeaks)=struct('clusterIndex',0,'peakIndex',0,'P_maxAmplitude',0, ...
%     'P_averageAmplitude',0,'P_topAverage',0,'P_peakWidth', 0 , 'P_roughness', 0,...
%     'P_totalPower',0,'P_iFFTLow',0,'P_iFFTMedium',0,'P_iFFTHigh',0, 'P_frequency',0,...
%     'P_peakFFT',zeros([1 nComponents]),'P_highLow_Ratio',0, 'P_Odd_FFT',0, 'P_Even_FFT',0, ...
%     'P_OddEvenRatio',0);

max_amplitude = max(chunk);
averageAmplitude = mean(chunk(2:(length(chunk)-2)));
top=find(chunk>averageAmplitude);
topAmp=mean(chunk(top));
peakwidth = length(top )/50000*1000;
roughness = std( chunk(top)/topAmp  );%/averageAmplitude;

%peakParams.peakIndex=currPeakIndex;
peakParams.P_maxAmplitude=max_amplitude;
peakParams.P_averageAmplitude=averageAmplitude;
peakParams.P_topAverage=topAmp;
peakParams.P_peakWidth=peakwidth;
peakParams.P_roughness=roughness;

FFT_Sizen=length(chunk);
if FFT_Sizen<minFFTSize
    FFT_Sizen=minFFTSize;
end

[TotalPowerW,powerspecW]= DenoiseSpecWhole(chunk,chunkempty,256);
peakParams.P_peakFFT_Whole=powerspecW;

[TotalPower,powerspec]=DenoiseSpec(chunk,chunkempty,FFT_Sizen);

specLength =length(powerspec);

n1=round(specLength/2);
n2=specLength-5;

peakParams.P_totalPower=TotalPower;
peakParams.P_iFFTLow=powerspec(5)+powerspec(6)+powerspec(7);
peakParams.P_iFFTMedium=powerspec(n1)+powerspec(n1+1)+powerspec(n1+2);
peakParams.P_iFFTHigh=powerspec(n2)+powerspec(n2+1)+powerspec(n2+2);

x=(2:length(powerspec))';
f=fit(x,powerspec(2:end),'exp1');
f=f.a*exp(f.b*x);% + f.c*exp(f.d*x);
powerspec(2:end)=powerspec(2:end)-f;

peakParams.P_Even_FFT = sum( powerspec(1:2:specLength));
peakParams.P_Odd_FFT = sum( powerspec(2:2:specLength));
peakParams.P_OddEvenRatio=peakParams.P_Odd_FFT/peakParams.P_Even_FFT;

    
peakCoef = zeros([nComponents 1]);
indxs = round( specLength * (0: (1/nComponents) :1).^3);
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
    
    
%reduce the complexity to just a few parameters.  Since the spacing is
%only dependant on
% for k=1:(specLength)
%     bin =floor( k/(specLength)*(nComponents-1))+1;
%     peakCoef(bin) = peakCoef(bin)+powerspec(k);
% end
peakParams.P_peakFFT=peakCoef;
peakParams.P_highLow_Ratio=peakCoef(round(end*.75))/peakCoef(1);

end