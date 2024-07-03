InitializeDLLs
clear pathnames;

%masterPath ='S:\Research\BrianAnalysis\Stacked Junctions\20140103_IBM_A_05_GACT_data_repeat\Files for Brian';
%masterPath ='S:\Research\BrianAnalysis\Stacked Junctions\20140123_IBM_A_05_RIE2_ACTG_data\For Brian analysis';
masterPath ='S:\Research\BrianAnalysis\Stacked Junctions\20140204_IBM_A_05_RIE2_ATCG_repeat';
folders = dir(masterPath);

cc=1;
for I=3:length(folders)
    
    if (folders(I).isdir==true)
        pathnames{cc}=[masterPath '\' folders(I).name];
        cc=cc+1;
    end
end

names={'Control','dAMP','dTMP','dCMP', 'dGMP'};

longData =[];
lI = [];

UsedFiles={};
for I=1:length(pathnames)
    pathname=pathnames{I};
    files = dir([pathname '\\*.abf']);
    tFiles={};
    cc=1;
    for J=1:length(files)
        if findstr(files(J).name,'Ref_N100mV')
            if findstr(files(J).name,'400mV')
                tFiles{cc}=files(J).name;
                cc=cc+1;
            end
        end
    end
    
    idxs{I}=1:length(tFiles);
    UsedFiles{I}=tFiles;
end

cc=1;
loadedFiles ={};
cc2=1;
clf;
traces ={};
rinses =[];
Xrinse=[];
allSmoothed =cell([length(pathnames) 10]);
 ccPlot=5;
 ccPlot2=35;
 obj_fits ={};
for K=1:length(pathnames)
    pathname=pathnames{K};
    files = UsedFiles{K};
    idx=idxs{K};
    cc3=cc;
   
    Xm=[];
    longData=[];
    for J=1:length(files)
        fn=files{J};
        file= [pathname '\' fn]
        loadedFiles{cc2}=file;
        cc2=cc2+1;
        [shortData] = abfload(file,'start',0)';
        shortData= shortData(1,:);

        bottom = zeros([1 floor(length(shortData)/1000)]);
        cc2=1;
        for M=1:1000:length(shortData)
            try
                bottom(cc2)=min(shortData(M:M+999));
                cc2=cc2+1;
            catch mex
            end
        end
%         X=(1:length(bottom))*1000;
% %         f1=fit(X',bottom','poly5','Robust','Bisquare')
%         shortData = shortData - feval(f1,1:length(shortData))';%+ feval(f1,1);
%         
        X=(1:length(shortData))+cc;
        cc=cc+length(shortData);
        figure(1);
        plot(X(1:3:end),shortData(1:3:end));
        hold all;
        drawnow;
        
        if isempty(findstr(fn,'Rinse'))==false || (K==1) %#ok<FSTR>
            rinses=[rinses  shortData]; %#ok<AGROW>
            Xrinse=[Xrinse X]; %#ok<AGROW>
        else
            figure(25)
            clf;
            
            n=2;
           % shortData=shortData(1:10000);
%             mn= min(shortData);
%             mx=max(shortData);
%             shortData =255*( shortData - mn)/(mx-mn);
            dst = restore_image2(shortData', 80,5, 200, .1, 5);
%             figure(2);
%             plot(shortData);
%             hold all;
%             plot(dst);
%             
%             shortData = dst*(mx-mn)/255+mn;
            allSmoothed{K,J}=shortData;
            Xm=[Xm X];
            longData=[longData shortData'];
        end
    end
    traces{K,1}=longData;
   
    ccPlot=ccPlot+1;
end

figure(3);
clf;
cc=1;
for I=2:size(traces,1)
    shortData=traces{I,1};
    X=(1:length(shortData))+cc;
    cc=cc+length(shortData);
    figure(3);
    plot(X(1:3:end),shortData(1:3:end));
    hold all;
    drawnow;
end

Nclasses=13;
t=allSmoothed{2,1};
[v,bins]=hist(t,220);
% obj = gmdistribution.fit(t,Nclasses);
% gs=pdf(obj,bins');
% norm =1/max(gs);
% plot(bins,norm*gs);
% hold all;
plot(bins,v/max(v));

% 
% for M=1:Nclasses
%     plot(bins,obj.PComponents(M).*exp(-1*( (bins-obj.mu(M)).^2/ (2*obj.Sigma(M)))));
% end

for I=2:size(allSmoothed,1)
    if I==2
        t=allSmoothed{I,2};
    else
        if I==5
            t=allSmoothed{I,1};
        else
            t=allSmoothed{I,1};
        end
    end
    d=abs(diff(t));
    thresh = std(d(1:200))*2;
    idx=find(d>thresh);
    
    amplitudes = d(idx);
    gaps = idx(2:end)-idx(1:end-1);
    
    
    figure(1)
    [v, bins]=hist(amplitudes,100);
    plot(bins,v);
    xlabel('Amplitude (pA)');
    ylabel('count');
    hold all;
    
    
    figure(2)
    binsT=1:10:1000;
    v=hist(gaps);
    v(end)=0;
    semilogy(binsT/20000*1000,v);
    xlabel('time (ms)');
    ylabel('count');
    hold all
    
%     figure(3);
%     scatter(amplitudes(1:length(gaps)),gaps);
%     hold all
end