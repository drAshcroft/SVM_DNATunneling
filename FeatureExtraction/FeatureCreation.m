function [folderNSamples folderNPeaks folderNClusters folderBaseLine]=FeatureCreation(conn,analyteName, folder_Index,  folderPath, runParams , isControl)

folderNSamples=0;
folderNPeaks=0;
folderNClusters=0;
folderBaseLine=0;

disp('===============================')
disp('LOADING EXPERIMENT FILES')
%do all the experiment files

files = dir([folderPath '\\*.tdms']);

if isempty(files)
    files = dir([folderPath '\\*.abf']);
end


csvFile =false;
if isempty(files)
    files = dir([folderPath '\\*.csv']);
    csvFile=true;
end


csvFile =false;
if isempty(files)
    files = dir([folderPath '\\*.mat']);
    csvFile=true;
end

bDataFile=false;
if isempty(files)
    bDataFile=true;
    files = dir([folderPath '\\*.dat']);
end

if isempty(files)
    disp('no files found for folder');
    fprintf('%s\n',folderPath);
    return
end

[pathstr,dname,ext] = fileparts(folderPath) ;
[pathstr,dname2,ext] = fileparts(pathstr) ;
dname=[dname dname2];


halfWindow = runParams.clusterSize/2;
sigma =  halfWindow;
impulse =exp(-1*( (-halfWindow:halfWindow) ./(2*sigma)).^2);

canvas=[];
for k=1:length(files)
    try
        %determine if this file has already been encoded with the correct
        %parameters
        fileName =[folderPath '\' files(k).name];
        
        a=strrep(fileName,'\','//');
        
        sql =['SELECT file_Index FROM files where FileName=''' a '''' ...
            'AND Folder_Index=' num2str(folder_Index) ';'];
        
        ret=fetch(exec(conn,sql));
        
        if isstruct(ret.Data)
            alreadyDone =true;
            file_Index = ret.Data.File_Index;
        else
            alreadyDone = false;
            sql =['INSERT INTO files (Folder_Index,FileName,Fl_numSamples,Fl_numPeaks,Fl_numClusters,Fl_BaselineVariance,Fl_60Hz) VALUE (' ...
                num2str( folder_Index) ',''temp'',0,0,0,0,0);' ];
            exec(conn,sql);
            
            sql = ['SELECT file_Index as m from files where Folder_Index=' num2str( folder_Index) ' and FileName=''temp'';'];
            ret = exec(conn,sql);
            ret = fetch(ret);
            
            file_Index=ret.Data.m;
%             try
%                 if isnan(ret.Data.m)
%                     file_Index=1;
%                 else
%                     if isempty(ret.Message)==false  || isstruct(ret.Data)==false
%                         file_Index=1;
%                     else
%                         file_Index=ret.Data.m+1;
%                     end
%                 end
%             catch
%                 file_Index=1;
%             end
        end
        
        if (alreadyDone == false)
            %if it has not, then do the collection
            disp(['Loading: ']); %='21May2012_001.tdms';
            disp (k);
            disp('*******************************')
            disp('LoadAndFilter')
            %load the trace from this file, remove the background and the
            %high frequencies
           % [trace ] =LoadAndFilter(folderPath,files(k).name,runParams);
            [trace,assignmentNames ] = LoadAndFilterDat(folderPath,files(k).name,runParams);
            drawnow;
            
            %a datafile does not have peaks, it is all signal, so we just
            %subdivide it.
            if bDataFile==true
                
                
                idx=find(strcmp(assignmentNames,'NN')==false);
                idx2=[idx(2:end)-idx(1:end-1)];
                edges = find(idx2~=1)';
                
                ccPeaks=1;
                if idx2(1)==1
                    edges =[1 edges];
                end
                if idx2(end)==1
                    edges=[edges length(idx2)];
                end
                
                allStarts=[];
                allEnds=[];
                ccPeaks=1;
                for I=1:length(edges)-1
                    if idx2(edges(I)+1)==1
                        allStarts(ccPeaks)=idx(edges(I)+1)-1;
                        allEnds(ccPeaks)=idx(edges(I+1)-1)+2;
                        ccPeaks=ccPeaks+1;
                    end
                end
                
                if length(allStarts)~=length(allEnds)
                   allEnds=allEnds(1:length(allStarts)); 
                end
                
                diffends=allEnds-allStarts;
                idx=find(diffends<4);
                allStarts(idx)=[];
                allEnds(idx)=[];
                
                clear edges;
                clear idx;
                clear idx2;
                clear diffends;
            
            else
                if (csvFile==true)
                     [allStarts, allEnds] = WPeakFinder(trace,runParams,dname,k );
                    % [allStarts, allEnds] = PeakRangeFinder( trace,  runParams );
                else
                    [allStarts, allEnds] = PeakRangeFinder( trace,  runParams );
                end
            end
            
            
            if (runParams.examplePeaks==true && isempty(allEnds)==false)
                lCheck = allEnds-allStarts;
                lCheck=lCheck(1:end-10);
                if (isempty(canvas)==true)
                    m=500;%floor(mean(lCheck) + std(lCheck)*3.5);
                    h=250;
                    
                    minT=min(trace);
                    maxT=max(trace);
                    d=.1*(maxT-minT);
                    minT=minT-d;
                    cH=(h-1)/ ((d+ maxT) - minT);
                    
                    canvas = zeros([h m]);
                    m=m-1;
                end
                try
                    for I=1:length(allStarts)
                        L=allEnds(I)-allStarts(I);
                        M=min([allStarts(I)+L*1 length(trace)]);
                        t=floor(cH* ( trace(allStarts(I):M) -minT))+1;
                        
                        X=1:length(t);
                        idx=find(X>m);
                        X(idx)=[];
                        t(idx)=[];
                        
                        idx=(find(X<1));
                        X(idx)=[];
                        t(idx)=[];
                        
                        idx=(find(t<1));
                        X(idx)=[];
                        t(idx)=[];

                        idx=(find(t>h));
                        X(idx)=[];
                        t(idx)=[];

                        t=h-t;
                        for J=1:length(X)
                            canvas(t(J),X(J))=canvas(t(J),X(J))+1;
                        end
                    end
                catch mex
                    dispError(mex)
                end
                canvas =log(canvas+1).^.5;
                canvas=255*canvas./max(canvas(:));
                im=uint8(zeros([size(canvas,1) size(canvas,2) 3]));
                im(:,:,1)=round(canvas);
                im(:,:,2)=round(canvas);
                im(:,:,3)=round(canvas);
                
                figure(1);
                clf;
                imshow(im);
                
                filename = [runParams.outputPath '\typical_'  dname  '.jpg'];
                saveas(1,filename);
                
                
            end
            
            
            if isempty(allStarts)==false
                if bDataFile==false && csvFile==false 
                   %  assignmentTrace=zeros(size(trace));
%                     for L=1:length(allStarts)
%                         assignmentTrace(allStarts(L):allEnds(L))=1;
%                     end
%                     
%                     assignmentTrace=conv(assignmentTrace,impulse,'same');
%                     figure(3);
%                     clf;
%                     plot(trace);
%                     hold all;
%                     emptyTrace = trace(assignmentTrace==0);
                  
                end
                
                if (length(assignmentNames)==1)
                    assignmentNames={analyteName};
                end
                
                [numPeaks, numClusters]= ClusterPeakParameters(conn,assignmentNames,folder_Index,file_Index,trace, allStarts, allEnds,runParams );
                    
                [ Hz60, baseLine  ] = GetTraceQuality( trace );
            else
                numPeaks=0;
                numClusters=0;
                Hz60=1000;
                baseLine=1000;
            end
            
            if isnan(Hz60)==true
                Hz60=0;
            end
            
            %   sql =['INSERT INTO files (Folder_Index,FileName,Fl_numSamples,Fl_numPeaks,Fl_numClusters,Fl_BaselineVariance,Fl_60Hz) VALUE (' ...
            %    num2str( folder_Index) ',''temp'',0,0,0,0,0);' ];
            sql = ['update files set FileName=''' a ''', Fl_numSamples='  num2str(length(trace)) ',Fl_numPeaks=' num2str(numPeaks) ...
                ',Fl_numClusters=' num2str(numClusters) ',Fl_BaselineVariance='  num2str(baseLine)  ',Fl_60Hz='  num2str(Hz60)  ...
                ' where File_Index=' num2str(file_Index) ';']
            
%             sql =['INSERT INTO files (Folder_Index,FileName,Fl_numSamples,Fl_numPeaks,Fl_numClusters,Fl_BaselineVariance,Fl_60Hz) VALUE (' ...
%                 num2str( folder_Index)  ',''' a ''',' num2str(length(trace)) ',' num2str(numPeaks) ',' num2str(numClusters) ',' num2str(baseLine) ',' num2str(Hz60) ');' ];
            ret= exec(conn,sql);
            
            if isempty( ret.Message)==false
               disp(ret.Message); 
            end
            
            folderNSamples=folderNSamples + length(trace);
            folderNPeaks=folderNPeaks +numPeaks ;
            folderNClusters=folderNClusters + numClusters;
            folderBaseLine=folderBaseLine + baseLine;
        end
    catch mex
        dispError(mex)
       
        
    end
end
% sql=['INSERT or REPLACE INTO runParams (folderPath, folder_index, nPeaks, nClusters, nSamples) VALUES ('];
folderBaseLine=folderBaseLine/k;
end