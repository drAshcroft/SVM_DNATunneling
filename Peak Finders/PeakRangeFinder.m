function [ allStarts allEnds ] = PeakRangeFinder( trace,  peakFindParams )
% x=-75:75;
% impulse = exp(-1*( x./30).^2)./(length(x)^.5);
% 
% %plot(trace(1:2000),'r');hold all;
% 
% trace = conv(trace,impulse);
% trace=trace(75:end);
%plot(trace(75:2075),'b');


thresh = peakFindParams.baseline_Threshold;

%finds the high point for each peak
[indexs]= peakfinder(trace, 4, thresh,1);

possiblePeaks = length(indexs);

minimumPeakSize = peakFindParams.minimum_Width;
maximumPeaksSize = peakFindParams.clusterSize/2;
%clusterWindowSize=peakFindParams.clusterSize;


allStarts=zeros([possiblePeaks 1]);
allEnds = zeros([possiblePeaks 1]);

peakCount=1;
endPeak=0;
%now cycle through all the peaks and determine the start and end of each
%peak
for k=1:possiblePeaks

  if (indexs(k)>endPeak)
    startPeak=indexs(k); 
    % find the beginning of the peak
    while indexs(k)-startPeak<maximumPeaksSize && trace(startPeak)>0 && startPeak>2
        startPeak=startPeak-1;
    end

    endPeak=indexs(k); 
  
    % find the end of the peak
    while endPeak-indexs(k)<maximumPeaksSize && trace(endPeak)>0 && endPeak<length(trace)
        endPeak=endPeak+1;
    end
    
    if (endPeak>length(trace)-1)
        endPeak = length(trace)-1;
    end
    
    if (endPeak-startPeak>minimumPeakSize)
        %allPeaks{peakCount} =struct('StartIndex',startPeak-100,'EndIndex',endPeak+100);
        allStarts(peakCount)=startPeak-30;
        allEnds(peakCount)=endPeak+30;
        peakCount=peakCount+1;
        endPeak = endPeak+100;
    end
    endPeak = endPeak +3;
  end
end

allStarts =allStarts(2:peakCount-2);
allEnds =allEnds(2:peakCount-2);

end



