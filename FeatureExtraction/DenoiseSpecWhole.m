function [TotalPower,powerspec]=DenoiseSpecWhole(chunk,traceEmpty, FFTSize)


l=length(chunk);
if l<FFTSize
    l=FFTSize;
end

cEFFT= zeros([l 1]);
%get a nice bit of the empty signal to call the noise
cc=1;
for I=1:100
    if (I+1)*l-1<length(traceEmpty)
        cE=traceEmpty(I*l:(I+1)*l-1);
        if (length(chunk)<FFTSize)
            cE = vertcat(cE, ones([FFTSize - length(cE),1])*cE(end));     %#ok<AGROW>
        end
        
        cEFFT =cEFFT + abs(fft(cE));
        cc=cc+1;
    end
end

sigma =cEFFT / cc;

if (length(chunk)<FFTSize)
    chunk = vertcat(chunk, ones([FFTSize - length(chunk),1])*chunk(end));
end

alpha=.5;
N = size(chunk,1);
Yf = fft(chunk)/N;
Pyf = abs(Yf).^2;

sigma=abs(sigma).^2/N^2;
W=((1-alpha)*Pyf-alpha*sigma)./Pyf;
W(W<0)=0;
spec = (W.*Yf);

spec=real(abs(spec(1:round(end/2))));
spec=spec.*(   ( 1:length(spec))' );
%spec=spec.^2;

spec(1)=0;
spec(2)=0;
TotalPower=mean(spec(1:end));
spec=(spec./TotalPower+ .001).^.1;

indxs = round( l/2 * (0: (1/FFTSize) :1).^2);
if indxs(1)==0;
    indxs=indxs+1;
end

for iI=2:length(indxs)
    if  indxs(iI)==indxs(iI-1)
        indxs(iI:end)=indxs(iI:end) + 1;
    end
end

indxs(indxs>length(spec))=length(spec);
powerspec=zeros([FFTSize 1]);

cc3=1;
for k=1:FFTSize
    try
        powerspec(cc3) =mean(  spec(indxs(k):indxs(k+1) )) ;
    catch mex
        disp (mex);
    end
    cc3=cc3+1;
end

powerSpec2=zeros([1 51]);
step = floor(length(powerspec)/51);
for I=1:51
    powerSpec2(I)=powerspec(I*step);
end

powerspec=powerSpec2;
end