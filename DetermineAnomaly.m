function anomalySVMParams=DetermineAnomaly(analytes,reducedData,runParams, SVMParams)

idx=find(reducedData(:,5)==0);
reducedData = reducedData(idx,:);

idx = randperm(size(reducedData,1),500);
temp= reducedData(idx,runParams.dataColStart:end);
anomalySVMParams=CreateOneClass(temp,SVMParams);


predictedGroups = svmoneclassval(temp,anomalySVMParams.xsup,anomalySVMParams.alpha,anomalySVMParams.rho,anomalySVMParams.kernel,anomalySVMParams.kerneloption);
t =sort(predictedGroups,'descend');

anomalySVMParams.threshold =t(round(end*runParams.Anomaly_Strictness_filter));


end