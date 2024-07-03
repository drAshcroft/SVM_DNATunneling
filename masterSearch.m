try
    
    if exist('killFlowThrough','var')==false
        %batchExcel='S:\Research\SVM_Results\Start_Job\FlowThrough_Pyrrole_2pA_TGAmCC.xlsx';
        %batchExcel='C:\Users\bashc\Dropbox\Brian+Predrag\bena4\Fig17\FlowThrough.xlsx';
        batchExcel='C:\Data\REDUCED_FlowThrough_Benzimidazole_4pA_TGAmCC_test1.xlsx';
       % batchExcel='C:\Users\bashc\Dropbox\Brian+Predrag\bena4\Fig21\flowthrough.xlsx';
        
        %batchExcel='C:\Users\bashc\Dropbox\Brian+Predrag\bena4\flowThroughPredrag.xlsx';
    end
    outputPath = 's:\research\svm_results\_';
    dbUser='honcho';
    dbPassword='12Dnadna';
    
    %first we need to get all the execuatebles set up.  This project uses a
    %tdms reader to handle the labview files, and a c# wrapper to deal with the
    %one big data transfer from the database (matlab has a memory leak,
    %resulting in a silly hack to get the data)
    InitializeDLLs
    
    %load the setting file and the data folders
    %rather than make a GUI, I just used a nice excel file.  This allows
    %infinite flexibility in adjusting the settings and makes persistence of
    %the setting very easy
    disp('===============================')
    disp('LoadingXLSParameters')
    % killFlowThrough=false
    
    doAnalysis=true
    if exist('batchExcel','var')==true
        batchExcel
        sprintf('%s\n', batchExcel);
        [folderPaths runParams]=  LoadXLSParameters(batchExcel,'FlowThrough');
    else
        [folderPaths runParams]=  LoadXLSParameters('S:\Research\SVM_Results\Start_Job\Jongone130909FlowThroughSugar2.xlsx','FlowThrough');
    end
    
    disp('===============================')
    
    
    runParams.outputPath =[outputPath runParams.Experiment_Name];
    runParams.dbUser=dbUser;
    runParams.dbPassword=dbPassword;
    
    diary( ['c:\data\' runParams.Experiment_Name   '_diary.txt']);
    
    
    runParams.examplePeaks =0;
    %now we make a ODBC connection.  This requires that a ODBC setting is in
    %the windows registry (once again, trying to get around the matlab memory
    %problems)
    conn=database('recognition_L',runParams.dbUser,runParams.dbPassword);
    setdbprefs('DataReturnFormat','structure');
    
    %this if is just a convience, it is annoyingly expensive to do the water
    %filtering and the svm parameter optimization.  Once the data is loaded, it
    %is best to just keep going.
    
    %single processing and insertion into the database
    SaveFolders(folderPaths, runParams, false,true, conn );
    SaveFolders(folderPaths, runParams, false,false, conn );
    %then all the experimental data
    
    
    %this procedure got misnamed.  It defines the experiment, analyte, and
    %the other database tables that relate to this experiment.
    [experiment_Index, analyteList,runParams ]=LoadData2(folderPaths, runParams, false, conn );
    
    %Now, we really do get all the data from the database.  (This is where
    %the c# code is hidden).  The data is returned as a big ugly datatable
    %with the analyte index, peak index and cluster index as the first
    %three cols.
    [colNames,dataTable, controlTable, analyteNames,runParams]=GetDataTablesSQL(conn,experiment_Index,runParams);
    
    
    if isfield(runParams,'Remove_Clusters')
        if runParams.Remove_Clusters==1
            clusterCols=[];
            for I=1:length(colNames)
                if isempty(findstr(colNames{I},'C_'))==false %#ok<FSTR>
                    clusterCols=[clusterCols I]; %#ok<AGROW>
                end
            end
            colNames(clusterCols)=[];
            dataTable(:,clusterCols)=[];
            clear clusterCols;
        end
    end
    
    try
        rmdir(runParams.outputPath,'s');
    catch
        
    end
    
    try
        mkdir(runParams.outputPath);
    catch
        runParams.outputPath
        mkdir(runParams.outputPath);
    end
    
    try
        copyfile(batchExcel,[runParams.outputPath '\flowthrough.xlsx'],'f');
    catch mex
        dispError(mex);
    end
    
    %the data is now scaled to make it more pleasant for the machine
    %learning routines.
    [colNames,dataTable, controlTable]=ScaleData2(colNames,dataTable, controlTable,runParams);
    
    
    for WaterI=1:1
        for WaterStrict =.2:.3:.2  + WaterI
            try
                runParams.Remove_Water=WaterI;
                runParams.Water_Strictness_filter=WaterStrict;
                
                refinedData.experiment_Index = experiment_Index;
                refinedData.colNames = colNames ;
                refinedData.dataTable = dataTable;
                
                %[refinedData] = PCA_Prefilter(refinedData,runParams);
                % %the water signal is set up with a one class SVM, anything that falls
                % %inside the one class is removed.
                if (runParams.Remove_Water==1 && isempty(controlTable)==false  )
                    disp('===============================');
                    disp('Removing Water Signal');
                    [refinedData, waterPercent,analyteLost]= RemoveWater(conn,refinedData,controlTable,runParams,experiment_Index);
                end
                
                for inGroup = 0:1
                    runParams.Do_In_vs_outgroup=inGroup;
                    for inGroupRating = .1:.2:.1+inGroup*3
                        
                        try
                            runParams.In_Vs_Out_Cutoff=inGroupRating;
                            if runParams.Do_In_vs_outgroup==1
                                [ refinedData] = GoodParameters2( refinedData,  runParams );
                            end
                            
                            for inPCA=0:1
                                try
                                    runParams.Do_PCA=inPCA;
                                    %  runParams.Do_PCA=1;
                                    if runParams.Do_PCA==1
                                        %the PCA will remove correlated features, but loses any meaningful
                                        %information about the feature names.
                                        [refinedData] = PCA_Prefilter(refinedData,runParams,analyteNames );
                                    else
                                        if runParams.Do_Covariance==1
                                            %remove the datapoints that are correlated.  They slow down the processing
                                            %and screw up the svm
                                            %this also converts the data to its final form in the tables
                                            [refinedData] = CovarianceClean(refinedData, runParams.Covariance_Cutoff,runParams);
                                        end
                                    end
                                    disp('===============================');
                                    disp('Cross Validation and Grid search');
                                    SVMParams=CrossValidate(experiment_Index,refinedData.dataTable, refinedData.colNames,runParams);
                                    
                                    disp('Running Parameter Search');
                                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                                    
                                    for Remove_Common_Peaks=0:1
                                        for Common_Strictness_filter=.1:.3:.1+1*Remove_Common_Peaks
                                            for Remove_Anomaly=0:1
                                                for Anomaly_Strictness_filter=.1:.3:.1+1*Remove_Common_Peaks
                                                    for Maintain_Clusters=1:1
                                                        try
                                                            experiment1 =   sprintf('WaterStrict-%s,inGroup-%s,inGroupRating-%s,inPCA-%s,Remove_Common_Peaks-%s', ...
                                                                num2str( WaterStrict),num2str(inGroup),num2str(inGroupRating),num2str(inPCA),num2str(Remove_Common_Peaks));
                                                            experiment2 =  sprintf('Common_Strictness_filter-%s,Remove_Anomaly-%s,Anomaly_Strictness_filter-%s,Maintain_Clusters-%s', ...
                                                                num2str( Common_Strictness_filter),num2str(Remove_Anomaly),num2str(Anomaly_Strictness_filter),num2str(Maintain_Clusters));
                                                            
                                                            experimentDesc = [experiment1 experiment2];
                                                            
                                                            runParams.Remove_Common_Peaks=Remove_Common_Peaks;
                                                            runParams.Common_Strictness_filter=Common_Strictness_filter;
                                                            runParams.Remove_Anomaly=Remove_Anomaly;
                                                            runParams.Anomaly_Strictness_filter=Anomaly_Strictness_filter;
                                                            runParams.Maintain_Clusters=Maintain_Clusters;
                                                            
                                                            
                                                            try
                                                                RandomFeatureSelectionSearchPCA(experiment_Index,conn, refinedData,  runParams, SVMParams,analyteNames,experimentDesc )
                                                            catch mex
                                                            end
                                                            
                                                            try
                                                                RandomFeatureSelectionSearch(experiment_Index,conn, refinedData,  runParams, SVMParams,analyteNames,experimentDesc )
                                                            catch mex
                                                            end
                                                        catch mex
                                                        end
                                                    end
                                                    try
                                                        AdaptiveFeatureSelectionSearch(experiment_Index,conn, refinedData,  runParams, SVMParams,analyteNames ,experimentDesc)
                                                    catch mex
                                                    end
                                                    
                                                    
                                                end
                                            end
                                        end
                                    end
                                    
                                catch mex
                                end
                            end
                            
                        catch mex
                        end
                    end
                end
                
                
            catch mex
            end
        end
        
    end
    
    %  [colNames,dataTable,controlTable ] = GoodParameters( colNames,dataTable, controlTable, runParams );
    %
    % [ extraInfo2]=  RandomSearch(superIteration,expName,reorganizedGroups,runParams,SVMParams,extraInfo);
    % end
    
    disp('===============================')
    PlotAllResults
    
catch mex
    
    dispError(mex)
    
end

if exist('killFlowThrough','var')
    if killFlowThrough
        delete(killFile) ;
    end
end

