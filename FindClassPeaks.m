
% 
% 
% cShortData=cShortData(200:end-200)';
% shortData=shortData(200:end-200)';
% classed=classed(200:end-200)';

dClass = classed(2:end)-classed(1:end-1);

idx=find(dClass~=0);

idx=[1 idx' length(cShortData)];



peakValues = zeros([1 length(idx)-1]);
peakValuesM = zeros([1 length(idx)-1]);
widths = zeros([1 length(idx)-1]);
for I=2:length(idx)
    seg= cShortData(idx(I-1):idx(I));
    widths(I-1)=length(seg);
    peakValues(I-1)=mean(seg);
    peakValuesM(I-1)=mode(seg);
end
figure(13);clf;hist(peakValues,200);
figure(12);clf;hist(peakValuesM,200);
dPeakValues =diff( peakValues);


% idx=find(peakValues>95);
idx=1:length(dPeakValues);

figure(14);hist(abs(dPeakValues),200);hold all;
figure(15);hold all;
scatter(widths(1:end-1),dPeakValues,2);
drawnow;