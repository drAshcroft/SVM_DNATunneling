function [colNames,dataTable, controlTable]= ScaleData2(colNames,dataTable, controlTable,runParams)


nCols=size(dataTable,2);

trainableIDX = find(dataTable(:,5)==0);

 
t=dataTable(trainableIDX,:);

means = median(t );
deviations = median(abs( bsxfun(@minus, t, means) ));



badCols=[];
for L=runParams.dataColStart:nCols
    if isnan(deviations(L))==true || deviations(L)==0
        badCols=[badCols L];
    else
        dataTable(:,L)=(dataTable(:,L)-means(L))/deviations(L);
    end
end

if (isempty( controlTable)==false )
    for L=runParams.dataColStart:nCols
        %     if isnan(cDeviations(L))==true || deviations(L)==0
        %         badCols=[badCols L];
        %     else
        controlTable(:,L)=(controlTable(:,L)-means(L))/deviations(L);
        %     end
    end
end

cols=1:nCols;
cols(badCols)=[];
dataTable=dataTable(:,cols);
controlTable=controlTable(:,cols);
colNames =colNames(cols);
end