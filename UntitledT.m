dataTable=refinedData.dataTable;%(:,1);
dataTable2=dataTable(:,runParams.dataColStart:end);
aIndex=dataTable(:,1);

idxA=find(aIndex==100);
idxT=find(aIndex==103);

indexs={};
for K=1:200
    
    i = randperm(size(dataTable2,2));
    j = randi(length(i)-2) +2;
    i=i(1:j);
    
    indexs{K}=i;
    dt1=dataTable2(idxA,i);
    dt2=dataTable2(idxT,i);
    
    ratings=vertcat(dt1 ,dt2 );
    
  %  score=ratings;
    w = 1./var(ratings);
    [wcoeff,score,latent,tsquared,explained] = pca(ratings,...
        'VariableWeights',w);
    
    score1=score(1:length(idxA),:);
    score2=score(length(idxA)+1:end,:);
    
    figure(1);clf;
    for I=1:size(score1,2)
        for J=I+1:size(score1,2)
            Untitled3
%             clf
%             scatter(score1(:,I),score1(:,J));
%             hold all;
%             scatter(score2(:,I),score2(:,J));
           
        end
    end
end