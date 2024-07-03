function SaveFolders(folderPaths, runParams, redoFileload, doControls,conn)

fileCol = 2 + doControls;

fields = {'baseline_Threshold', ...
    'num_ClusterFFT_coef', ...
    'num_peakFFT_coef', ...
    'minimum_Width', ...
    'clusterSize', ...
    'minimum_FFT_Size', ...
    'lowPass_Freq', ...
    'minimum_cluster_FFT_Size'};

field = fields{1};
whereSQL = ['WHERE Round(' field ',4)=Round(' num2str( runParams.(field)) ',4)'];
for I=2:length(fields)
    field = fields{I};
    whereSQL=[whereSQL ' AND Round(' field ',4)=Round(' num2str( runParams.(field)) ',4)']; %#ok<AGROW>
end

sql =['select folders.Folder_Index, folders.Folder from folders ' whereSQL ';'];

ret = exec(conn,sql);
ret = fetch(ret);

if isempty(ret.Message)==false || isstruct(ret.Data)==false || redoFileload
    DoFolders = folderPaths;
else
    FolderNames=(ret.Data.Folder);
    cc=1;
    alreadyDone=[];
    for I=1:size(folderPaths,1)
        for J=1:size(FolderNames)
            a=folderPaths{I,fileCol};
            a=strrep(a,'\','/');
            if strcmp(a,char(FolderNames{J}))
                alreadyDone(cc)=I;
                cc=cc+1;
            end
        end
    end
    rows=1:size(folderPaths,1);
    rows(alreadyDone)=[];
    DoFolders = folderPaths(rows,:);
end
% sql = 'SELECT max(Folder_Index) as m from folders;';
% ret = exec(conn,sql);
% ret = fetch(ret);
% 
% try
%     if isnan(ret.Data.m)
%         folder_Index=1;
%     else
%         if isempty(ret.Message)==false  || isstruct(ret.Data)==false
%             folder_Index=1;
%         else
%             folder_Index=ret.Data.m+1;
%         end
%     end
% catch mex
%     disperror(mex);
%     folder_Index=1;
% end
if (redoFileload)
    for I=1:size(DoFolders,1)
        try 
        folderInfo=DoFolders{I,fileCol};
        a=strrep(folderInfo,'\','/');
        sql = ['select Folder_Index from folders where Folder=''' a ''';'];
        ret =exec(conn,sql);
        ret=fetch(ret);
        fIndexs=ret.Data.Folder_Index;
        for J=1:length(fIndexs)
            folder_index=fIndexs(J);
            sql = ['delete from clusters where Folder_Index=' num2str(folder_index) ';'];
            exec(conn,sql);
            sql = ['delete from peaks where Folder_Index=' num2str(folder_index) ';'];
            exec(conn,sql);
            sql = ['delete from files where Folder_Index=' num2str(folder_index) ';'];
            exec(conn,sql);
            sql = ['delete from folders where Folder_Index=' num2str(folder_index) ';'];
            exec(conn,sql);
        end
        catch mex %#ok<NASGU>
            
        end
    
    end
    
end
 
for I=1:size(DoFolders,1)
    folderInfo=DoFolders{I,fileCol}
    a=strrep(folderInfo,'\','/');
    
    sql ='INSERT INTO folders (Folder, Fold_number_Samples, Fold_numPeaks,Fold_numWaterPeaks,Fold_numClusters,Fold_avgBaselineVariance';
    
    for J=1:length(fields)
        field = fields{J};
        sql=[sql ',' field ]; %#ok<AGROW>
    end
    
    sql = [sql  ') VALUES (''' a ''',0,0,0,0,0' ]; %#ok<AGROW>
    for J=1:length(fields)
        field = fields{J};
        sql=[sql ',' num2str( runParams.(field)) ]; %#ok<AGROW>
    end
    sql=[sql ');']; %#ok<AGROW>
    cur= exec(conn,sql);
    
    sql = ['select Folder_Index from folders ' whereSQL ' AND Folder=''' a ''';'];
    ret =exec(conn,sql);
    ret=fetch(ret);
    folder_Index=ret.Data.Folder_Index(1);
    
    sql=['delete from files where Folder_Index=' num2str(folder_Index) ';'];
    ret =exec(conn,sql);
    
    [folderNSamples folderNPeaks folderNClusters folderBaseLine]= FeatureCreation(conn,DoFolders{I,1}, folder_Index,  folderInfo , runParams, false );
    
    
    sql =['Update folders SET Fold_number_Samples=' num2str(folderNSamples) ', '...
          'Fold_numPeaks=' num2str(folderNPeaks) ', ' ... 
          'Fold_numClusters=' num2str(folderNClusters) ', ' ...
          'Fold_avgBaselineVariance=' num2str(folderBaseLine) ' where folder_Index=' num2str(folder_Index)  ';' ];
    
    cur= exec(conn,sql);
   
    
    folder_Index=folder_Index+1;
end





return;


