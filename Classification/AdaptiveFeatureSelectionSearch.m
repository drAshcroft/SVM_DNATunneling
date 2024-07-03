function   AdaptiveFeatureSelectionSearch(experiment_Index,conn, refinedData,  runParams, SVMParams,analyteNames,description)
% refinedData.colNames=refinedData.colNames(1:30);
% refinedData.dataTable=refinedData.dataTable(:,1:30);
% colNames=refinedData.colNames(1:30)';


trainableIDX = find(refinedData.dataTable(:,5)==0);
trainTable=refinedData.dataTable(trainableIDX,:);

colNames=refinedData.colNames(:)';

analytes = unique(trainTable(:,1));
halfAnalyte = analytes(fix(end/2));
C = 10;

% in order to properly reproduce the results presented in the NIPS paper
% one has to select C and Sigma using a span estimate criterion

positiveIDX = find(trainTable(:,1)>halfAnalyte);
negativeIDX = find(trainTable(:,1)<=halfAnalyte);

labels =zeros([1 size(trainTable,1)]);
labels(positiveIDX)=1;
labels(negativeIDX)=-1;

% sigma tuning

option  = runParams.Adaptive_Feature_Method  ; %['wbfixed','wfixed','lbfixed','lfixed','lupdate'].
pow = 1 ;
dataTable=refinedData.dataTable;
testAccur =[];
for i=1:100
    try
        d=size(trainTable,2)-runParams.dataColStart+1;
        
        Sigma =0.01*ones(1,d);
        
        idxP=randperm(length(positiveIDX),min([length(positiveIDX) 500]));
        idxN=randperm(length(negativeIDX),min([length(negativeIDX) 500]));
        
        indapp=[  positiveIDX(idxP)' negativeIDX(idxN)'];
        x=trainTable(indapp,runParams.dataColStart:end);
        y=labels(indapp)';
        
        if isempty(x)
            break;
        end
        %------------------------------------------------------------------%
        %                       Feature Selection and learning
        %------------------------------------------------------------------%
        [Sigma,Xsup,Alpsup,w0,pos,nflops,crit,SigmaH] = svmfit(x,y,Sigma,C,option,pow,0);
        nsup=size(Xsup,1);
        
        badParams=find(Sigma==0)+runParams.dataColStart-1;
        
        if length(badParams)>2
            idx=randperm(length(badParams));
            badParams=badParams(idx(1:2));
        end
        
        if (isempty(badParams)==true)
            [v idx]=sort(Sigma);
            
            Sigma2=Sigma==.01;
            Sigma2(Sigma2==1)=[];
            if isempty(Sigma2) || isnan(std(Sigma))
                idx=randperm(length(Sigma));
            end
            if (length(idx)==1)
                break;
            end
            
            if (length(idx)>7)
                badParams = idx(1:8)+runParams.dataColStart-1;
            else
                 badParams = idx(1:2)+runParams.dataColStart-1;
            end
        end
        
        disp('=====================bad Params===================');
        fprintf( '%s\n', colNames{badParams});
        
        
        cols=1:size(dataTable,2);
        cols(badParams)=[];
        
        
        dataTable=dataTable(:,cols);
        trainTable=trainTable(:,cols);
        colNames=colNames(cols);
        
        if length(cols)>runParams.dataColStart
            %make sure to do a placeholder, just in case two of these are
            %running at the same time.
            sql =['insert into svm_results (SVM_R_Experiment_Index, SVM_R_parameters,SVM_R_parameterMethod) VALUES (' num2str(experiment_Index) ...
                ',''' sprintf('%s,', colNames{1:end}) ''',''Adaptive' description ''');'];
            exec(conn,sql);
            
            %sql ='select max(SVM_R_ParameterSet_Index) as m from svm_results';
            sql =['select SVM_R_ParameterSet_Index from svm_results where SVM_R_Experiment_Index=' num2str(experiment_Index)   ' AND SVM_R_parameters=''' sprintf('%s,', colNames{1:end}) ''';'];
            ret = fetch(exec(conn,sql));
            parameterSet_Index=ret.Data.SVM_R_ParameterSet_Index(1);
          
            accur= TrainAndTest(experiment_Index,parameterSet_Index,conn,analyteNames, colNames, dataTable,runParams, SVMParams);
            sql = ['update svm_results set SVM_R_LostPercent=' num2str(accur) ' where SVM_R_ParameterSet_Index=' num2str(parameterSet_Index) ';'];
            exec(conn,sql);
        end
    catch mex
        fprintf([mex.message '\n']);
        for I=1:length(mex.stack)
            try
                disp(mex.stack(I));
                fprintf([ mex.stack(I).name '\n' mex.stack(I).line '\n']);
            catch
            end
        end
    end
end

end

