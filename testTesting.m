disp('testing trainging');
[extraInfo,GeneralStatsTesting, perGroupStatsTesting,wholeTruePositive,runTable, calls]=TestData(reorganizedGroups,runParams, colNumbers, commonSVM ,anomolySVM, allPeaksSVM,extraInfo);


%   plotColorCodedPeaks(I,extraInfo)




if isempty(runTable)==false
    
    cell2csv([runParams.Output_Folder '\acurRuns' num2str(superIteration) '_' num2str(I) '_.csv'],runTable);
end

generalStats {1} =GeneralStatsTop;
generalStats {2} =GeneralStatsTraining;


generalStats  =horzcat(generalStats, GeneralStatsTesting); %#ok<AGROW>


%        paramSig = zeros([length(allColNames) 1]);
% paramOcc = zeros(size(paramSig));
% paramOpt= zeros(size(paramSig));
%
% for J=1:length(colNumbers)
%     paramOcc(colNumbers(J))= paramOcc(colNumbers(J))+1;
%     paramSig(colNumbers(J))= paramSig(colNumbers(J))+Accuracy{I,3};
%     paramOpt(colNumbers(J))= paramOpt(colNumbers(J))+Accuracy{I,3}*GoodForTesting;
% end

cc=cc+1;
disp('recording data');
RecordStats(cc,superIteration,experimentName,parameterColNames,runParams,wholeTruePositive,generalStats,perGroupStatsTesting);


for JJ=1:size(calls,2)
    callTable(1,JJ+1)={reorganizedGroups.Peaks{JJ}.GroupName};
    callTable(2+JJ,1)={reorganizedGroups.Peaks{JJ}.GroupName};
end

for KK=1:size(calls,1)
    for JJ=1:size(calls,2)
        callTable{KK+1,JJ+1}=calls(KK,JJ);
    end
end


cell2csv([runParams.Output_Folder '\calls' num2str(superIteration) '_' num2str(I) '_.csv'],callTable);