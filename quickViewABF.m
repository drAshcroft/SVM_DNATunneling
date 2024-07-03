

%folderPath ='S:\Research\BrianAnalysis\20131020_Stcked_Junction_data_for_Brian_SVM\Ion Milling Etch\20131009_IBM_D_18_not too much data\dGMP';
% folderPath ='S:\Research\BrianAnalysis\20131020_Stcked_Junction_data_for_Brian_SVM\Ion Milling Etch\20131020_IBM_D_25\dGMP';
% folderPath ='S:\Research\BrianAnalysis\20131020_Stcked_Junction_data_for_Brian_SVM\RIE_Etch\20130916_RIE etch\dAMP';
% folderPath ='S:\Research\BrianAnalysis\20131020_Stcked_Junction_data_for_Brian_SVM\RIE_Etch\20131024_D_04_RIE\Step1_dGMP';

%folderPath ='S:\Research\BrianAnalysis\20131020_Stcked_Junction_data_for_Brian_SVM\Ion Milling Etch\20131006_IBM_R3_32_repeat\dAMP';
%folderPath ='S:\Research\BrianAnalysis\20131020_Stcked_Junction_data_for_Brian_SVM\Ion Milling Etch\2013_0929_IBM_R3_32\dAMP';

 folderPath ='S:\Research\Brian\Brain\2013_11_06_reruns 50 nm\Data';

ret = strsplit(folderPath,'\');
outFile =['c:\data\toCSV\' ret{end-1}  '.' ret{end}  '.csv'];





files = dir([folderPath '\\*.tdms']);

if isempty(files)
    files = dir([folderPath '\\*.abf']);
end

if isempty(files)
    return
end
[fid, errormessage]=fopen(outFile,'w');
lD=[];

for k=1:length(files)
figure(k)    
    %determine if this file has already been encoded with the correct
    %parameters
    fileName =[folderPath '\' files(k).name];
    
    [shortData] =abs( abfload(fileName,'start',0));
  
    shortData=shortData(1:50:end,1);
    
    plot(shortData(:,1));
    xlabel('Time(samples)');
    ylabel('Current (pA)');
    v=axis;
    axis([v(1) v(2) 15 36]);
    title(files(k).name)
    fprintf(fid,'%d\n',shortData(:,1));
  
    lD=[lD shortData'];
    
    drawnow;
end
fclose(fid);
figure(15);
plot(lD)
xlabel('Time(samples)');
ylabel('Current (pA)');