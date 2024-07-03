function [SVMParams]=CrossValidate(experiment_Index,tabledGroups, colNames, runParams)


trainableIDX = find(tabledGroups(:,5)==0);
tabledGroups=tabledGroups(trainableIDX,:);


kernalProps=DefaultKernalParameters();
kernalProps.nbclass =2;

analytes = unique(tabledGroups(:,1));
idx = find(tabledGroups(:,1)==analytes(1));
N=min([400 length(idx)]);
hN=floor(N/2);
idxIDX=randperm(length(idx),N);
idx1=idx(idxIDX);

idx = find(tabledGroups(:,1)==analytes(2));
N=min([400 length(idx) length(idx1)]);
hN=floor(N/2);
idxIDX=randperm(length(idx),N);
idx2=idx(idxIDX);

idxTr= [idx1(1:hN+1)' idx2(1:hN+1)'];
idxTe= [idx1(hN:N-1)' idx2(hN:N-1)'];
mi=min([length(idxTr) length(idxTe)]);
idxTr=idxTr(1:mi);
idxTe=idxTe(1:mi);

Training=tabledGroups(idxTr,runParams.dataColStart:end);
Testing=tabledGroups(idxTe,runParams.dataColStart:end);


Labels =[ones([1 hN])*1 ones([1 (size(Testing,1)-hN)])*2]';

%cycle through the parameters to get the best SVM parameters
maxTraining = 0;
for C=.01:.1:.3
    for gamma=.5:.6:3
        disp('----------------------------------');
        kernalProps.kerneloption=[C gamma];
        [ allPeaksSVM, trainingAccuracy]=  CreateMultiClass(Training,Labels, kernalProps);
        disp(trainingAccuracy);
        predictedGroups  = svmmultivaloneagainstone(Testing,allPeaksSVM.xsup,allPeaksSVM.w,allPeaksSVM.b,allPeaksSVM.nbsv,allPeaksSVM.kernel,allPeaksSVM.kerneloption);
        testAccuracy = length(find(predictedGroups ==Labels))/length(Labels)*100;
        disp(testAccuracy);
        dist =1/ abs(testAccuracy-85);
        if dist>maxTraining
            maxTraining=dist;
            maxC=C;
            maxGamma=gamma;
        end
    end
end
kernalProps.kerneloption=[maxC maxGamma];
SVMParams=kernalProps;

end