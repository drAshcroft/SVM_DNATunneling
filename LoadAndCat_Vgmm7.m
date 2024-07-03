InitializeDLLs
clear pathnames;
pause on;

%masterPath ='S:\Research\BrianAnalysis\Stacked Junctions\20140103_IBM_A_05_GACT_data_repeat\Files for Brian';
% masterPath ='S:\Research\BrianAnalysis\Stacked Junctions\20140123_IBM_A_05_RIE2_ACTG_data\For Brian analysis';
% masterPath ='S:\Research\BrianAnalysis\Stacked Junctions\20140204_IBM_A_05_RIE2_ATCG_repeat';
%masterPath ='S:\Research\BrianAnalysis\Stacked Junctions\20140225_IBM_A_27_RIE_ACTG\File_for_Brian';
masterPaths{1} ='S:\Research\BrianAnalysis\Stacked Junctions\20140303_IBM_A_17_RIE_ACTG\For Brian analysis';
masterPaths{2} ='S:\Research\BrianAnalysis\Stacked Junctions\20140401_IBM_A_11_RIE_APGCmCAb';
masterPaths{3} ='S:\Research\BrianAnalysis\Stacked Junctions\20140402_IBM_A_11_RIE_AGCTmC';
masterPaths{4} ='S:\Research\BrianAnalysis\Stacked Junctions\20140414_IBM_A_13_RIE_AGC_1nM\Files for Brian';

for asdf=1:1%length(masterPaths)
    mI=2;
    masterPath=masterPaths{mI};
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
            fprintf('%s\n',files(J).name);
            fn=files(J).name;
            p=['c:\temp' pathname(3:end)];
            outFilename = [p '\'  fn '_Vgmm19.mat'];
            if exist(outFilename,'file')==false
                
                % if findstr(files(J).name,'CMP')
                %             if findstr(files(J).name,'P380mV')
                %                 if isempty(findstr(files(J).name,'100uM'))==false
                tFiles{cc}=files(J).name;
                cc=cc+1;
                %                 end
                %             end
                %end
            end
        end
        
        idxs{I}=1:length(tFiles);
        UsedFiles{I}=tFiles;
    end
    
    colors={'k' 'r' 'g' 'b' 'y' 'm' 'r' 'k' 'c'  'm' 'r' 'c' 'r'};
    colors={'k' 'g' 'y' 'b' 'r' 'm' 'r' 'k' 'c'  'm' 'r' 'c' 'r'};
    colors={'b' 'k' 'k' 'k' 'c' 'y' 'r' 'k' 'c' 'y' 'r'};
    colors={'b' 'k' 'g' 'k' 'r' 'b' 'g' 'k'};
    %colors={'b' 'r' 'k' 'c'  'm' 'r' 'k' 'c'  'm' 'r' 'c' 'r'};
    
    %colors={'b' 'k' 'c' 'm'  'r' 'k' 'c'  'm' 'r' 'c' 'r'};
    
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
    FileDatas=[];%cell([length(pathnames) 10]);
    FileRinsesRaw=cell([length(pathnames) 10]);
    FileRinses=cell([length(pathnames) 10]);
    FileRinsesX=cell([length(pathnames) 10]);
    FileXs=cell([length(pathnames) 10]);
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
            X=(1:length(bottom))*1000;
            f1=fit(X',bottom','poly1','Robust','Bisquare');
            
            %                 shortData = shortData - feval(f1,1:length(shortData))';%+ feval(f1,1);
            %
            X=(1:length(shortData));
            %cc=cc+length(shortData);
            figure(1);clf;
            skipSize=50;
            
            %
            if isempty(findstr(fn,'Rinse'))==false || (K==1) %#ok<FSTR>
                if (K==1)
                    controlRinse=shortData;
                end
                rawRinseX=[rawRinseX X(floor(length(X)/2):end)];
                rawRinses=[rawRinses shortData(floor(length(shortData)/2):end)];
                
                FileRinsesRaw{K,J}=shortData;
                FileRinsesX{K,J}=X;
                
                sD=shortData(1:5000);
                covar=std(sD);
                % shortData = restore_imageDPGMM(shortData',covar ,21,100, .8, 5)';
                
                FileRinses{K,J}=shortData;
                rinses=[rinses shortData(1:end)]; %#ok<AGROW>
                Xrinse=[Xrinse X]; %#ok<AGROW>
                plot(X(1:skipSize:end)/20000/60,shortData(1:skipSize:end),'k');
                hold all;
                drawnow;
            else
                plot(X(1:skipSize:end)/20000/60,shortData(1:skipSize:end),colors{1+mod(K,length(colors)-1)});
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
                
                shortData = shortData(floor(.25*length(shortData)):floor(.95*length(shortData)));
                sD=shortData(1:5000);
                covar=std(sD);
                %  ttt=shortData(1:500000)';
                stepSize=length(shortData);
                lShortData=[];
                nShortData=[];
                lClassed=[];
                lLevels=[];
                mC=0;
                shift=0;
                lastPoint = shortData(1);
                for chunks =1:stepSize:length(shortData)
                    eI=chunks+stepSize;
                    eI=min([eI length(shortData)]);
                    shift = lastPoint- shortData(chunks);
                    ttt= shortData(chunks:eI) + shift;
                    
                    [tShortData, cShortData, levels, classed] = restore_imageVGMM3(ttt',covar ,6,100, 10, 5);
                    lShortData=vertcat(lShortData, cShortData(1:end-1)); %#ok<AGROW>
                    nShortData=vertcat(nShortData, tShortData(1:end-1)); %#ok<AGROW>
                    lClassed=horzcat(lClassed, classed(1:end-1)' + mC); %#ok<AGROW>
                    lLevels=horzcat(lLevels ,levels); %#ok<AGROW>
                    lastPoint= tShortData(end);
                    mC=max(classed);
                end
                cShortData=lShortData;
                classed=lClassed;
                levels=lLevels;
                
                cShortData=cShortData(200:end-200)';
                shortData=shortData(200:end-200)';
                nShortData=nShortData(200:end-200)';
                classed=classed(200:end-200)';
                
                
                dClass = classed(2:end)-classed(1:end-1);
                
                idx=find(dClass~=0);
                
                idx=[1 idx' length(cShortData)];
                
                peakValues = zeros([1 length(idx)-1]);
                peakValuesM = zeros([1 length(idx)-1]);
                widths = zeros([1 length(idx)-1]);
                for I=2:length(idx)
                    seg= cShortData(idx(I-1):idx(I));
                    widths(I-1)=length(seg);
                    peakValues(I-1)=mean(seg);
                    peakValuesM(I-1)=mode(seg);
                end
                %                 figure(13);clf;hist(peakValues,200);
                %                 figure(12);clf;hist(peakValuesM,200);
                dPeakValues =diff( peakValues);
                
                
                % idx=find(peakValues>95);
                idx=1:length(dPeakValues);
                
                %                 figure(14);hist(abs(dPeakValues),200);hold all;
                %                 figure(15);hold all;
               % scatter(widths(1:end-1),dPeakValues,2);
                drawnow;
                
                
%                 stepsize = 4096*32;
%                 
%                 freq=zeros([1 stepsize]);
%                 sampS = smooth(shortData,1)';
%                 
%                 try
%                     cc=1;
%                     for I=1:stepsize:length(sampS)-stepsize
%                         samp = sampS(I:I+stepsize-1);
%                         freq=freq+abs(fft(samp));
%                         cc=cc+1;
%                     end
%                 catch mex
%                 end
%                 freq=freq/stepsize/cc;
%                 freq=real(abs(freq(1:end/2).^2));
%                 
%                 sLong = smooth(freq,101)';
%                 
%                 s2=smooth(abs(freq-sLong),9);
%                 
%                 plot(log(s2));drawnow;
%                 
%                 levels =[ 1:32 33:5:100 100:15:500 500:50:1000];
%                 
%                 wShortData = cwt(shortData,levels,'sym2','plot');
                
                p=['c:\temp' pathname(3:end)];
                
                if(isdir(p)==0)
                    mkdir(p)      %Creates folder containing the plots
                end
                bottom=feval(f1,1);
                
                save([p '\'  fn '_Vgmm9.mat'],'fn','shortData','cShortData','nShortData','levels','classed','peakValues','peakValuesM','bottom','widths');
                
                mn=min(shortData);
                mx=max(shortData);
                
                FileDatas{K,J}=shortData(1:end);
                FileXs{K,J}=X;
                
            end
        end
        
        ccPlot=ccPlot+1;
    end
    
end
