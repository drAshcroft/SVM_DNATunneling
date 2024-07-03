InitializeDLLs
clear pathnames;

%masterPath ='S:\Research\BrianAnalysis\Stacked Junctions\20140103_IBM_A_05_GACT_data_repeat\Files for Brian';
% masterPath ='S:\Research\BrianAnalysis\Stacked Junctions\20140123_IBM_A_05_RIE2_ACTG_data\For Brian analysis';
% masterPath ='S:\Research\BrianAnalysis\Stacked Junctions\20140204_IBM_A_05_RIE2_ATCG_repeat';
%masterPath ='S:\Research\BrianAnalysis\Stacked Junctions\20140225_IBM_A_27_RIE_ACTG\File_for_Brian';
%masterPath ='S:\Research\BrianAnalysis\Stacked Junctions\20140401_IBM_A_11_RIE_APGCmCAb';
%masterPath ='S:\Research\BrianAnalysis\Stacked Junctions\20140402_IBM_A_11_RIE_AGCTmC';
masterPath ='S:\Research\BrianAnalysis\Stacked Junctions\20140414_IBM_A_13_RIE_AGC_1nM\Files for Brian';
folders = dir(masterPath);

cc=1;
for I=3:length(folders)
    
    if (folders(I).isdir==true)
        pathnames{cc}=[masterPath '\' folders(I).name];
        cc=cc+1;
    end
end

names={'Control','dAMP','dCMP','dTMP', 'dGMP'};

longData =[];
lI = [];

UsedFiles={};
for I=1:length(pathnames)
    pathname=pathnames{I};
    files = dir([pathname '\\*.abf']);
    dts={};
    for J=1:length(files)
        dts{J}=files(J).date;
    end
    
    [dts idx]=sort(dts);
    
    files=files(idx);
    
    tFiles={};
    cc=1;
    for J=1:length(files)
        %         if findstr(files(J).name,'Ref_100mV')
        %             if findstr(files(J).name,'P380mV')
        %                 if isempty(findstr(files(J).name,'100uM'))==false
        tFiles{cc}=files(J).name;
        cc=cc+1;
        %                 end
        %             end
        %         end
    end
    
    idxs{I}=1:length(tFiles);
    UsedFiles{I}=tFiles;
end

colors={'k' 'r' 'g' 'b' 'y' 'm' 'r' 'k' 'c'  'm' 'r' 'c' 'r'};

figure(1);clf;
cc=1;
loadedFiles ={};
cc2=1;
clf;
traces =cell([length(pathnames) 2]);
rawRinseX=[];
rawRinses=[];
rinses =[];
controlRinse =[];
Xrinse=[];
FileDatas=[];
FileRinsesRaw=cell([length(pathnames) 10]);
FileRinses=cell([length(pathnames) 10]);
FileRinsesX=cell([length(pathnames) 10]);
FileXs=cell([length(pathnames) 10]);


fDatas={};
ffDatas={};
ccFDatas=1;

Raws=[];
ccPlot=5;
ccPlot2=35;
obj_fits ={};
for K=2:length(pathnames)
    pathname=pathnames{K};
    files = UsedFiles{K};
    idx=idxs{K};
    cc3=cc;
    
    Xm=[];
    longData=[];
    for J=1:length(files)
        fn=files{J};
        file= [pathname '\' fn]
        
        [shortData] = abfload(file,'start',0)';
        shortData= shortData(1,1:floor(length(shortData)/1));%1:5000);
        
        
        bottom = zeros([1 floor(length(shortData)/1000)]);
        cc2=1;
        for M=1:1000:length(shortData)
            try
                bottom(cc2)=min(shortData(M:M+999));
                cc2=cc2+1;
            catch mex
            end
        end
      
        X=(1:length(shortData))+cc;
        cc=cc+length(shortData);
        figure(1);
        skipSize=50;
       
        if isempty(findstr(fn,'Rinse'))==false || (K==1) %#ok<FSTR>
            if (K==1)
                controlRinse=shortData;
            end
            rawRinseX=[rawRinseX X(floor(length(X)/2):end)];
            rawRinses=[rawRinses shortData(floor(length(shortData)/2):end)];
            
            FileRinsesRaw{K,J}=shortData;
            FileRinsesX{K,J}=X;
            
          %  sD=shortData(1:5000);
          %  covar=std(sD);
          %  shortData = restore_image2(shortData',covar ,21,100, .8, 5)';
            
            FileRinses{K,J}=shortData;
            rinses=[rinses shortData(1:end)]; %#ok<AGROW>
            Xrinse=[Xrinse X]; %#ok<AGROW>
            plot(X(1:skipSize:end)/20000/60,shortData(1:skipSize:end),'k');
            hold all;
            drawnow;
        else
            plot(X(1:skipSize:end)/20000/60,shortData(1:skipSize:end),colors{K});
            hold all;
            drawnow;
            
            steps=500;
            bottom = zeros([1 floor(length(shortData)/steps)-1]);
            cc2=1;
            for M=1:steps:length(shortData)-steps
                try
                    bottom(cc2)=min(shortData(M:M+steps));
                    cc2=cc2+1;
                catch mex
                end
            end
            figure(30);
            bins=1:2:500;
            [v bins]=hist(shortData,bins);
            v(1)=[];
            v(end)=[];
            bins=bins(2:end-1);
            
            bar(bins,v);
            
            bins=[bins' v'];
            
            Raws{K,J}=shortData;
            
            sD=shortData(1:5000);
            covar=std(sD);
           % shortData = restore_image2(shortData',covar ,21,100, .8, 5)';
            p=['c:\temp' pathname(3:end)];
            fileName=[p '\'  fn '.mat'];
            
            try
                d=load(fileName);
                
                shortData =d.shortData;
                cShortData=d.pData';
                
                idx= randperm( length(shortData));
                n=length(shortData)/200;
                t=cShortData(idx(1:n));
                p=dpmm(t,100);
                pp=p(end).classes;
                X=min(t):.25:max(t);
                
                clf;
                bins=hist(t,X);
                bins=bins/max(bins);
                plot(X,bins);
                hold all;
                minMu = [];
                minS = [];
                minX=X(end);
                ccLevels=1;
                for I=1:max(pp)
                    idx=find(pp==I);
                    if (length(idx)>15)
                        VV=t(idx);
                        bins=hist(VV,X);
                        
                        plot(X,bins);
                        hold all;
                        
                        [v vX]=max(bins);
                        vX=X(vX);
                        
                        minMu(ccLevels)=mode(VV);
                        minS(ccLevels)=std(VV);
                        ccLevels=ccLevels+1;
                        
                        if (minX>vX)
                            minX=vX;
                        end
                    end
                end
                
                ddd.baseline = minX;
                ddd.levels = minMu;
                ddd.covar = minS.^2;
                ddd.shortData = shortData-minX;
                ddd.fileName = fn;
                
                fDatas{ccFDatas}=ddd;
                ffDatas{ccFDatas}=shortData;
                ccFDatas=ccFDatas+1;
            catch mex
                disp(mex);
            end
            
%             FileDatas{K,J}=shortData(1:end);
%             FileXs{K,J}=X;
            
        end
    end
    
    ccPlot=ccPlot+1;
end

t=cShortData(1:5000:end);
p=dpmm(t,30);
pp=p(end).classes;
X=20:.25:100;

clf;
bins=hist(t,X);
bins=bins/max(bins);
plot(X,bins);
hold all;
minMu = max(X);
minX=X(end);
for I=1:max(pp)
    idx=find(pp==I);
    if (length(idx)>15)
        bins=hist(t(idx),X);
       
        plot(X,bins);
        hold all;
        
        [v vX]=max(bins);
        vX=X(vX);
        
        if (minX>vX)
           minX=vX;
        end
    end
end

