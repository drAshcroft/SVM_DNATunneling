 InitializeDLLs
% pathnames{1} ='S:\Research\BrianAnalysis\Stacked Junctions\20131223_A_05_GACT_data\Files for Brian\0230_Control';
% pathnames{2} = 'S:\Research\BrianAnalysis\Stacked Junctions\20131223_A_05_GACT_data\Files for Brian\0330_dGMP';
% pathnames{3}='S:\Research\BrianAnalysis\Stacked Junctions\20131223_A_05_GACT_data\Files for Brian\0430_dAMP';
% pathnames{4}='S:\Research\BrianAnalysis\Stacked Junctions\20131223_A_05_GACT_data\Files for Brian\0530_dCMP';
% pathnames{5} ='S:\Research\BrianAnalysis\Stacked Junctions\20131223_A_05_GACT_data\Files for Brian\0630_dTMP';


dirName='S:\Research\Brian\2013-12-19 angled Junction';
listing = dir(dirName)
cc=1;
for I=1:length(listing)
    if (length(listing(I).name)>5)% && I~=4 && I~=8)
        fprintf('%d %s\n',cc,[dirName '\' listing(I).name]);
        pathnames{cc}=[dirName '\' listing(I).name];
        files = dir([pathnames{cc} '\\*.tdms']);
        idxs{cc}= 1:length(files);
        cc=cc+1;
    end
end
 
longData =[];
lI = [];
cc=1;
loadedFiles ={};
cc2=1;
clf;
for K=13:length(pathnames)
    pathname=pathnames{K};
    files =dir([pathname '\\*.tdms']);
    idx=idxs{K};
    cc3=cc;
    for J=1:length(idx)%length(files)
        I=idx(J);
        fn=files(I).name;
       
        file= [pathname '\' fn]
        loadedFiles{cc2}=file;
        cc2=cc2+1;
        
        [shortData] = readTDMS2([pathname '\\'], fn);
       
       % shortData = smooth(shortData,331, 'moving');
        shortData = shortData(1:150:end);

        longData = [longData shortData'];
        lI =[lI ones(size(shortData))'*K];
        plot(shortData);
        drawnow;
       
    end
    g=1;
end

clear shortData;
clear indexs;
%controlData=longData;
%output=WienerScalart96(vertcat(controlData', longData'),50000,length(controlData)/(length(longData) + length(controlData) ));
%output =output(length(controlData):end);

output=longData;

output = smooth(output,331, 'moving');
output = output(1:330:end);
lI=lI(1:330:end);
plot(abs(output));
hold all;
plot(lI./5);
hold off;

for I=1:length(pathnames)
    fprintf('%s\n',pathnames{I});
end
