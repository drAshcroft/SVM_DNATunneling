InitializeDLLs
pathnames{1} ='S:\Research\BrianAnalysis\Stacked Junctions\20131223_A_05_GACT_data\Files for Brian\0230_Control';
pathnames{2} = 'S:\Research\BrianAnalysis\Stacked Junctions\20131223_A_05_GACT_data\Files for Brian\0330_dGMP';
pathnames{3}='S:\Research\BrianAnalysis\Stacked Junctions\20131223_A_05_GACT_data\Files for Brian\0430_dAMP';
pathnames{4}='S:\Research\BrianAnalysis\Stacked Junctions\20131223_A_05_GACT_data\Files for Brian\0530_dCMP';
pathnames{5} ='S:\Research\BrianAnalysis\Stacked Junctions\20131223_A_05_GACT_data\Files for Brian\0630_dTMP';


pathnames{6} ='S:\Research\BrianAnalysis\Stacked Junctions\20140103_IBM_A_05_GACT_data_repeat\Files for Brian\0300_Control';
pathnames{7} = 'S:\Research\BrianAnalysis\Stacked Junctions\20140103_IBM_A_05_GACT_data_repeat\Files for Brian\0335_dGMP';
pathnames{8}='S:\Research\BrianAnalysis\Stacked Junctions\20140103_IBM_A_05_GACT_data_repeat\Files for Brian\0434_dAMP';
pathnames{9}='S:\Research\BrianAnalysis\Stacked Junctions\20140103_IBM_A_05_GACT_data_repeat\Files for Brian\0524_dCMP';
pathnames{10} ='S:\Research\BrianAnalysis\Stacked Junctions\20140103_IBM_A_05_GACT_data_repeat\Files for Brian\0603_dTMP';

longData =[];
lI = [];
idxs{1}=[1,2,3,4];
idxs{2}=[1, 2,3,4, 5,6];
idxs{3}=[1, 2,3,4, 5,6];
idxs{4}=[1, 2,3,4, 5,6];
idxs{5}=[1, 2];

for I=6:length(pathnames)
    pathname=pathnames{I};
    files = dir([pathname '\\*.abf']);
    idxs{I}=1:length(files);
end

cc=1;
loadedFiles ={};
cc2=1;
clf;
traces ={};
for K=6:length(pathnames)
    pathname=pathnames{K};
    files = dir([pathname '\\*.abf']);
    idx=idxs{K};
    cc3=cc;
    longData=[];
    for J=1:length(files)
        fn=files(J).name;
        file= [pathname '\' fn]
        loadedFiles{cc2}=file;
        cc2=cc2+1;
        [shortData] = abfload(file,'start',0)';
        shortData= shortData(1,:);
%         shortData = smooth(shortData,331, 'moving');
         shortData = shortData(1:301:end);
        X=(1:length(shortData))+cc;
        cc=cc+length(shortData);
        plot(X,shortData);
        hold all;
        drawnow;
        longData=[longData shortData];
    end
    traces{K}=longData;
end
figure(1)
clf;
figure(2)
clf
cc=1;
for I=1:length(traces)
   shortData=traces{I};
   
   seg=floor(length(shortData)/512);
   f=[];
   for J=1:seg
      s=shortData((J-1)*512+1:(J-1)*512+512);
      if (J==1)
          J=abs(fft(s)).^2;
      else
          J=abs(fft(s)).^2+J;
      end
   end
   figure(1)
   plot(log(J))
   hold all;
   
   figure(2)
   X=(1:length(shortData))+cc;
   cc=cc+length(shortData);
   plot(X,shortData);
   hold all;
end

hold off;
for I=1:length(loadedFiles)
    disp(loadedFiles{I});
end

clear shortData;
clear indexs;
%controlData=longData;
%output=WienerScalart96(vertcat(controlData', longData'),50000,length(controlData)/(length(longData) + length(controlData) ));
%output =output(length(controlData):end);

output=longData;

output = smooth(output,331, 'moving');
output = output(1:150:end);
lI = lI(1:150:end);
%controlDate =longData;
%  longData=abs(longData);

plot(output);
hold all;
plot(lI);
hold off;

% D=[D output'];
% D2=[D2 lI+20];
%
% idx = find(longData>4.5);
%
% lD=longData - smooth(longData,131,'moving')';
%
% for I=1:length(idx)
%        lD(idx(I)-1000:idx(I)+1000)=-10000;
% end
%
% lD(lD==-10000)=[];
%
% plot(lD);
