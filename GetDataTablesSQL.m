function [colNames, dataTable, controlTable, analyteNames,runParams]=GetDataTablesSQL(conn,experimentIndex,runParams)

sql =sprintf(['select analytes.Analyte_Name, analytes.Analyte_Index from analytes \n' ...
    '   Join experiments \n' ...
    '       on experiments.Experiment_Index = analytes.Analyte_Experiment_Index \n' ...
    ' WHERE experiments.Experiment_Index=' num2str(experimentIndex) ';']);

ret =fetch( exec(conn,sql) );

analyteNames = ret.Data.Analyte_Name;
aN=ret.Data.Analyte_Name;

for I=1:length(ret.Data.Analyte_Index)
    aI(I)=    ret.Data.Analyte_Index(I);
    analyteNames{I,2}=ret.Data.Analyte_Index(I);
end

sql = ['select peaks.*,clusters.* from peaks ' ...
    'join clusters on clusters.Cluster_Index=peaks.Cluster_Index limit 1;'];
cur = exec(conn,sql);
ret=fetch(cur);

fields = fieldnames(ret.Data);
%setdbprefs('DataReturnFormat','numeric');
badCols={'Peak_Index', 'Cluster_Index', 'Folder_Index','File_Index' , 'startIndex' ,'endIndex' ,'SVM_Rating','P_identity' };
colNames = {'analytes.Analyte_Index','peaks.Peak_Index','clusters.Cluster_Index','Folder_Index','Role','identity'};
names = 'analytes.Analyte_Index,peaks.Peak_Index,clusters.Cluster_Index,peaks.Folder_Index,analytefolders.Control,peaks.P_identity';
runParams.dataColStart = length(colNames)+1;
cc=runParams.dataColStart;
for I=1:length(fields)
    bads=0;
    for J=1:length(badCols)
        if isempty(strfind(fields{I}, badCols{J}))==false
            bads = bads +1;
        end
    end
    if bads ==0
        colNames{cc}=fields{I};
        names =[names ',' fields{I}]; %#ok<AGROW>
        cc=cc+1;
    end
end


sql =['select ' names '\n'...
    ' from peaks \n' ...
    '   join folders \n' ...
    '     on folders.Folder_Index = peaks.Folder_Index \n' ...
    '   join analytefolders \n' ...
    '     on analytefolders.Folder_Index = folders.Folder_Index \n' ...
    '   join analytes \n' ...
    '     on analytes.Analyte_Index = analytefolders.Analyte_Index \n' ...
    '   join clusters \n' ...
    '     on clusters.Cluster_Index=peaks.Cluster_Index \n' ...
    ' WHERE analytes.Analyte_Experiment_Index=' num2str(experimentIndex) ' AND analytefolders.Control=1' ];

sql=sprintf(sql);
%controlTable = double(mySQLAdapter.mySQLAdapterClass.GetData_mySQL(['DSN=recognition_L2;UID=' runParams.dbUser ';PASSWORD=' runParams.dbPassword ';'],sql,6,aN,aI));
setdbprefs('DataReturnFormat','numeric');
cur =exec(conn,sql);
ret = fetch(cur);
controlTable =ret.Data;
clear ret;

sql =['select ' names '\n'...
    ' from peaks \n' ...
    '   join folders \n' ...
    '     on folders.Folder_Index = peaks.Folder_Index \n' ...
    '   join analytefolders \n' ...
    '     on analytefolders.Folder_Index = folders.Folder_Index \n' ...
    '   join analytes \n' ...
    '     on analytes.Analyte_Index = analytefolders.Analyte_Index \n' ...
    '   join clusters \n' ...
    '     on clusters.Cluster_Index=peaks.Cluster_Index \n' ...
    ' WHERE analytes.Analyte_Experiment_Index=' num2str(experimentIndex) ' AND analytefolders.Control!=1' ];

sql=sprintf(sql);

cur =exec(conn,sql);
ret = fetch(cur);
dataTable =ret.Data;
clear ret;

%dataTable =  double(mySQLAdapter.mySQLAdapterClass.GetData_mySQL(['DSN=recognition_L2;UID=' runParams.dbUser ';PASSWORD=' runParams.dbPassword ';'],sql,6,aN,aI));

setdbprefs('DataReturnFormat','structure');
sql =['select Folder from folders \n' ...
    '   join analytefolders \n' ...
    '     on analytefolders.Folder_Index = folders.Folder_Index \n' ...
    '   join analytes \n' ...
    '     on analytes.Analyte_Index = analytefolders.Analyte_Index \n' ...
    ' WHERE analytes.Analyte_Experiment_Index=' num2str(experimentIndex) ' AND analytefolders.Control!=1' ];

sql=sprintf(sql);

cur = exec(conn,sql);
ret=fetch(cur);

disp('Experiment folders that are being used:');

for I=1:length(ret.Data.Folder)
    fprintf('%s\n',ret.Data.Folder{I});
end

end