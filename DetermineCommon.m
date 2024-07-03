function commonSVM=DetermineCommon(analytes,reducedData,runParams, SVMParams)

%oneSVM=cell([1 length(analytes)]);
%removal all points that are listed as mixed or test
idx=find(reducedData(:,5)==0);
reducedData = reducedData(idx,:);

cc=1;
for K=1:length(analytes)
    idx =find( reducedData(:,1)==analytes(K) );
    %reduce the number of points to a managable amount
    if isempty(idx)==false
        idx = idx( randperm(length(idx), min([ length(idx) 300])));
        tSingleGroup= reducedData(idx,runParams.dataColStart:end);

        oneSVM{cc}=CreateOneClass(tSingleGroup,CopyKernalParameters(SVMParams)) ;
        predictedGroups = svmoneclassval(tSingleGroup,oneSVM{cc}.xsup,oneSVM{cc}.alpha,oneSVM{cc}.rho,oneSVM{cc}.kernel,oneSVM{cc}.kerneloption);
        t=sort(predictedGroups);
        if (length(t)<2)
            oneSVM{cc}.threshold = mean(t(:));    
        else
            oneSVM{cc}.threshold = t(round(end*runParams.Common_Strictness_filter));
        end
        cc=cc+1;
    end
end

% randomize the data so that the stop when full does not bias the data
idx =  randperm( size(reducedData,1),min([1000 size(reducedData,1)]) ) ;

tSingleGroup= reducedData(idx,runParams.dataColStart:end);
votes =zeros([length(idx) 1]);

figure(6);
for K=1:length(oneSVM)
    tvotes =zeros([length(idx) 1]);
    for I=1:500:size(tSingleGroup,1)-4
        top = min([ size(tSingleGroup,1) I+500]);
        temp= tSingleGroup(I+1:top,:);
        predictedGroups = svmoneclassval(temp,oneSVM{K}.xsup,oneSVM{K}.alpha,oneSVM{K}.rho,oneSVM{K}.kernel,oneSVM{K}.kerneloption);
        predictedGroups= predictedGroups>oneSVM{K}.threshold;
        tvotes(I+1:top)=tvotes(I+1:top)+predictedGroups;
    end
    
    votes=votes + tvotes;
    
    if K==1
        [t, idx]=sort(votes);
        tSingleGroup=tSingleGroup(idx,:);
        votes = votes(idx);
    else
        t =votes;
    end
    [t, idx]=sort(votes);
    plot(t/K);
    hold all
    drawnow;
end
hold off;

commonPeaks = tSingleGroup(votes>= length(oneSVM)-1 ,: );

if isempty(commonPeaks)==false
    
    commonSVM=CreateOneClass(commonPeaks,SVMParams);
    
    predictedGroups = svmoneclassval(commonPeaks,commonSVM.xsup,commonSVM.alpha,commonSVM.rho,commonSVM.kernel,commonSVM.kerneloption);
    [t idx]=sort(predictedGroups,'descend');
    
    idxT=round(length(t)*runParams.Common_Strictness_filter);
    if (idxT==0)
        idxT=1;
    end
    commonSVM.threshold =t(idxT);
else
    commonSVM=[];
end
end