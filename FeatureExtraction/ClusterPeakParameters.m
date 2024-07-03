function [numPeaks numClusters]= ClusterPeakParameters(conn,assignmentNames, folder_index,file_index,trace, startIndexs, endIndexs,runParams )
%PEAKASSIGNMENT Summary of this function goes here

nComponents=runParams.num_ClusterFFT_coef;

clusterParams=struct('C_peaksInCluster',0,'C_frequency',0, ...
    'C_averageAmplitude',0,'C_topAverage',0,'C_clusterWidth', 0 , 'C_roughness', 0,...
    'C_maxAmplitude',0,'C_totalPower',0,'C_iFFTLow',0,'C_iFFTMedium',0,'C_iFFTHigh',0, ...
    'C_clusterFFT',zeros([1 nComponents]),'C_highLow',0, 'C_freq_Maximum_Peaks',zeros([1 4]), ...
    'C_clusterCepstrum',zeros([1 nComponents]));

%this is used to add all the information to the database.  should only be
%run once when setting everything up
if (false  )
    [names values ] =linearizeParameters_SQL(clusterParams,'');
    sql ='ALTER TABLE clusters ';
    for I=1:length(names)-1
        sql = [sql 'ADD ' names{I} ' double NOT NULL DEFAULT 0,']; %#ok<AGROW>
    end
    I=length(names);
    sql = [sql 'ADD ' names{I} ' double  NOT NULL DEFAULT 0;']; %#ok<*NASGU>
    exec(conn,sql);
end


minFFTSize=runParams.minimum_cluster_FFT_Size;
%make a frequncy window to help identify where the clusters are located
halfWindow = runParams.clusterSize;
sigma =  halfWindow/2;
slidingFreqTrace = zeros([length(trace) 1]);
midPeak =round( (startIndexs+endIndexs)/2);
slidingFreqTrace(midPeak)=1;
impulse =exp(-1*( (-halfWindow:halfWindow) ./sigma).^2);
slidingFreqTrace=conv(slidingFreqTrace,impulse,'same');
assignmentTrace = zeros(size(slidingFreqTrace));

clusterStartI=zeros(size(startIndexs));
clusterEndI=zeros(size(startIndexs));
%now number the clusters
clusterIndex= 1 ;
endIndex = length(trace);
inCluster=false;

idx= find(slidingFreqTrace>.1);
clusterStartI(clusterIndex)=idx(1);
for I=1:length(idx)-1
    if idx(I)+1 ~= idx(I+1)
        clusterEndI(clusterIndex)=idx(I);
        clusterIndex=clusterIndex +1;
        clusterStartI(clusterIndex)=idx(I+1);
    end
end

if length(clusterEndI)~=length(clusterStartI)
    clusterEndI(length(clusterStartI))=length(trace);
end

try
    
    clusterStartI=clusterStartI(1:clusterIndex);
    clusterEndI=clusterEndI(1:clusterIndex);
catch mex
    dispError(mex)
end

if (clusterEndI(clusterIndex)==0)
    clusterEndI(clusterIndex)=length(trace);
end

for I=1:clusterIndex
    assignmentTrace(clusterStartI(I):clusterEndI(I))=I;
end

%assign the peaks and put in the frequency stuff
clusterAssignment = assignmentTrace(midPeak);
slidingFreqTrace=slidingFreqTrace(midPeak);
clusterOccupancy=histc(clusterAssignment,1:max(clusterAssignment));

%clear assignmentTrace;

%assignmentTrace=zeros(size(trace));
%assignmentTrace(trace>runParams.baseline_Threshold/2)=1;
assignmentTrace(assignmentTrace~=0)=1;
impulse =exp(-1*( ((-2*halfWindow):(2*halfWindow)) ./(.25*sigma)).^2);
assignmentTrace=conv(assignmentTrace,impulse,'same');

emptyTrace = trace(assignmentTrace==0);

clear assignmentTrace;

%now refine the start and end of the table
newClusterStart=clusterEndI(:);
newClusterEnd=clusterStartI(:);

clear clusterEndI;
clear clusterStartI;

for I=1:length(startIndexs)
    
    if startIndexs(I)<newClusterStart(clusterAssignment(I))
        newClusterStart(clusterAssignment(I))=startIndexs(I);
    end
    if endIndexs(I)>newClusterEnd(clusterAssignment(I))
        newClusterEnd(clusterAssignment(I))=endIndexs(I);
    end
end

for I=1:length(newClusterStart)
    if abs(newClusterStart(I)-newClusterEnd(I))<minFFTSize
        gap = round( (minFFTSize-abs( newClusterStart(I)-newClusterEnd(I)))/2);
        newClusterStart(I)=newClusterStart(I)-gap;
        newClusterEnd(I)=newClusterStart(I)+minFFTSize-1;
    end
end

newClusterStart=newClusterStart-100;
newClusterEnd=newClusterEnd+100;

newClusterStart(newClusterStart<1)=1;
newClusterEnd(newClusterEnd>length(trace)-1)=length(trace)-1;


try
    sql ='SELECT max(Cluster_Index) as maxC from clusters';
    ret =fetch(exec(conn,sql));
    startClusterIndex =ret.Data.maxC +1;
    if isnan(startClusterIndex)
        startClusterIndex =0;
    end
catch %#ok<CTCH>
    startClusterIndex =0;
end


sql ='INSERT INTO clusters VALUES ' ;
aIndex =[  num2str(folder_index) ','  num2str(file_index)];

emptyTrace=emptyTrace*1000;
% if (exist('c:\temp\empty.mat','file'))
%    e= load('c:\temp\empty.mat');
%    emptyTrace =vertcat(e.emptyTrace, emptyTrace);
% end
% save('c:\temp\empty.mat','emptyTrace');
% return

%    e= load('c:\temp\empty.mat');
%    emptyTrace =(e.emptyTrace);

numClusters=length(newClusterStart);
%get the parameters for the whole cluster
valueList=cell([1 500]);
cc=1;
for I=1:length(newClusterStart)
    try
        chunk =trace(newClusterStart(I):newClusterEnd(I));
        amplitude = max(chunk);
        if isempty(amplitude)==false
           
            clusterParams=ClusterFeatures(minFFTSize,nComponents,1000*chunk, ...
                emptyTrace,clusterOccupancy(I), clusterParams,runParams);
            
            if (I==1)
                [names, values ] =linearizeParameters_SQL(clusterParams,'');
                sql='insert into clusters (Folder_Index,File_Index,C_startIndex,C_endIndex,C_SVM_Rating';
                sql =[sql sprintf(',%s',names{:})]; %#ok<AGROW>
                sql =[sql ') VALUES ']; %#ok<AGROW>
            end
            
            [values] = linearizeValues_SQL( clusterParams  );
            
            b=sprintf(',%4.8f',values);
%             tableValues =['(' num2str(startClusterIndex+I) ',' aIndex ',' ...
%                 num2str(newClusterStart(I)) ',' num2str(newClusterEnd(I)) ',-1' b ')' ];
               tableValues =['('  aIndex ',' ...
                num2str(newClusterStart(I)) ',' num2str(newClusterEnd(I)) ',-1' b ')' ];
            
            
            valueList{cc} =tableValues;
            
            if mod(cc,400)==0 || I>length(newClusterStart)-2
                sql2=[sql valueList{1} ];
                for J=2:cc
                    sql2=[sql2 ',' valueList{J}];
                end
                
                ret= exec(conn,[sql2 ';']);
                
                if isempty(ret.Message)==false
                    disp(ret.Message);
                    disp('error in cluster save clusterpeakparameters');
                end
                
                clear sql2
                cc=0;
            end
            cc=cc+1;
            
            
        end
    catch me
        disp( me);
        disp( me.stack(1,1));
    end
end

numPeaks=SinglePeakParameters(conn,assignmentNames,trace,emptyTrace,folder_index,file_index,slidingFreqTrace,  startIndexs, endIndexs,startClusterIndex+clusterAssignment,runParams );

end