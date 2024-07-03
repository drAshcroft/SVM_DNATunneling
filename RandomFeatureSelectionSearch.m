function   RandomFeatureSelectionSearch(experiment_Index,conn, refinedData,  runParams, SVMParams,analyteNames,description)
% refinedData.colNames=refinedData.colNames(1:30);
% refinedData.dataTable=refinedData.dataTable(:,1:30);
% colNames=refinedData.colNames(1:30)';
colNames=refinedData.colNames(:)';

dataTable=refinedData.dataTable;
maxN= size( dataTable,2)-runParams.dataColStart;
for i=1:20
    try
        
        n=randi(50)+length(colNames)-50-runParams.dataColStart-1;
        idx = randperm(maxN);

        badParams = idx(1:n)+runParams.dataColStart-1;
       
        cols=1:size(dataTable,2);
        cols(badParams)=[];
        
       
        
         disp('=====================good Params===================');
        fprintf( '%s\n', colNames{cols});

        
        dataTable2=  dataTable(:,cols);
        colNames2=colNames(cols);
        
        if length(cols)>runParams.dataColStart
            %make sure to do a placeholder, just in case two of these are
            %running at the same time.
            sql =['insert into svm_results (SVM_R_Experiment_Index, SVM_R_parameters,SVM_R_parameterMethod) VALUES (' num2str(experiment_Index) ...
                ',''' sprintf('%s,', colNames2{1:end}) ''',''Random' description ''');'];
            exec(conn,sql);
            
            %sql ='select max(SVM_R_ParameterSet_Index) as m from svm_results';
            sql =['select SVM_R_ParameterSet_Index from svm_results where SVM_R_Experiment_Index=' num2str(experiment_Index)   ' AND SVM_R_parameters=''' sprintf('%s,', colNames2{1:end}) ''';'];
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

