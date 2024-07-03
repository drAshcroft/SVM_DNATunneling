
voltColors{260}=[0 0 0];
voltColors{280}=[1 0 0];
voltColors{300}=[0 1 1];
voltColors{320}=[0 1 0];
voltColors{330}=[.9 .75 0];
voltColors{350}=[1 0 1];
voltColors{380}=[0 0 1];
voltColors{400}=[0 0 0];

ControlCol=[0 0 1];
ACol=[0 1 0];
CCol=[0 0 1];
TCol=[.9 .75 0];
GCol=[1 0 0];

concentrationColors = {[0 0 0] [0 0 1] [.9 .75 0] [1 0 0] [0 1 0] [1 0 1] [0 0 1] [0 0 0] [0 0 0] [0 0 1] [.9 .75 0] [1 0 0] [0 1 0] [1 0 1] [0 0 1] [0 0 0]};
colors={[0 1 1] [0 0 0] [0 0 0] [0 0 0] [0 0 0] [0 0 0] [0 0 0] [0 0 1] [.9 .75 0]  [1 0 0] [0 0 0] [0 0 1] [.9 .75 0] [1 0 0]};
colors={ ControlCol ACol ACol ACol CCol TCol GCol ACol CCol TCol GCol ACol CCol TCol GCol  };
concentrationColors = {TCol CCol TCol GCol ACol [1 0 1] CCol TCol TCol CCol TCol GCol ACol [1 0 1] CCol TCol};

concentrations=[];
col=[0 1 1];
foundVoltagesX=cell([1 500]);
skips=1;
removeBackGround=false;
peakThresh=40;

analyteMode=1;
voltageMode=2;
concentrationMode =3;

plotMode =voltageMode;


figure(1);clf;
figure(2);clf;
figure(3);clf;
figure(4);clf;
figure(5);clf;
figure(6);clf;
figure(7);clf;
figure(8);clf;
figure(9);clf;

timeHistX=1:50:1000;
ampHistX=-100:2:450;
offHistX=-100:5:1000;

ampHist=cell([1  length(pathnames)]);
ampHistPeaks=cell([1  length(pathnames)]);
timeHistPeaks=cell([1  length(pathnames)]);

concByFolder=cell([1  length(pathnames)]);
platHeights=[];
spikeHeights=[];
weightedOnTime =[];
allIndexs=[];
onTime=[];
voltages=[];
offBig=[];
offStarts=[];

exampleTrace=cell([1 length(pathnames)*4]);
ccExample=1;
props={};
x=1;
kBaselines=[];
for K=2:2%min([ size(FileDatas,1) length(pathnames)])
    
    
    foundVoltages=zeros([1 500]);
    cCol=1;
    concentration='';
    concColor='b';
    pathname=pathnames{K};
    files = dir([pathname '\\*.abf']);
    dts={};
    for J=1:length(files)
        dts{J}=files(J).date;
    end
    
    [dts idx]=sort(dts);
    
    files=files(idx);
    for I=1:length(files)
        disp(files(I).name);
    end
    
    
    noise=[];
    analyteIndexs=[];
    baselines=[];
    skew=[];
    platTimes=[];
    nPlats =[];
    spikes=[];
    
    propAmp=[];
    propLife=[];
    propJump=[];
    
    offTimeHistPeaks=cell([1  length(pathnames)]);
    
    for J=1:length(files)
        voltage=400;
        doPlot=false;
        isRinse=false;
        fn=lower(files(J).name);
        
        analyteName='';
        for I=1:length(names)
            if isempty(findstr(fn,lower(names{I})))==false
                analyteName=names{I};
                anaylteIndex=I;
                break;
            end
        end
        
        if isempty(findstr(fn,'ref_n100mv'))==false
            if isempty(findstr(fn,'p300mv'))==false || (plotMode==voltageMode)
                
                
                if isempty(findstr(fn,'10nm'))==false %|| isempty(findstr(fn,'1mm'))==false
                    doPlot=true;
                    concentration = '10nm';
                    concColor=concentrationColors{3};
                    if plotMode ==concentrationMode
                        anaylteIndex=-3;
                    end
                end
                
                if plotMode==concentrationMode
                    
                    if isempty(findstr(fn,'10nm'))==false
                        doPlot=true;
                        concentration = '10nm';
                        concColor=concentrationColors{1};
                        if plotMode ==concentrationMode
                            anaylteIndex=1-9;
                        end
                    end
                    
                    if isempty(findstr(fn,'100nm'))==false
                        doPlot=true;
                        concentration = '100nm';
                        concColor=concentrationColors{1};
                        if plotMode ==concentrationMode
                            anaylteIndex=2-9;
                        end
                    end
                    
                    if isempty(findstr(fn,'10um'))==false
                        doPlot=true;
                        concentration = '10um';
                        concColor=concentrationColors{2};
                        if plotMode ==concentrationMode
                            anaylteIndex=1-6;
                        end
                    end
                    if isempty(findstr(fn,'100um'))==false
                        doPlot=true;
                        concentration = '100um';
                        concColor=concentrationColors{4};
                        if plotMode ==concentrationMode
                            anaylteIndex=2-6;
                        end
                    end
                    
                    if isempty(findstr(fn,'1mm'))==false
                        doPlot=true;
                        concentration = '1mm';
                        concColor=concentrationColors{5};
                        if plotMode ==concentrationMode
                            anaylteIndex=3-6;
                        end
                    end
                    
                    if isempty(findstr(fn,'1um'))==false
                        doPlot=true;
                        concentration = '1um';
                        concColor=concentrationColors{3};
                        if plotMode ==concentrationMode
                            anaylteIndex=-6;
                        end
                    end
                end
                
                if doPlot
                    voltage = str2num( fn(12:14));
                    voltages=[voltages voltage];
                end
                
                
                if isempty(findstr(fn,'rinse'))==false
                    doPlot=true;
                    isRinse=true;
                else
                    
                end
            end
        end
        
        if isempty(findstr(fn,'rinse'))==false
            doPlot=true;
            isRinse=true;
            voltage = str2num( fn(18:20));
            %             anaylteIndex=voltage;
        end
        
        if K==1
            isRinse=true;
            doPlot=true;
        end
        
        
        if  ((plotMode ==concentrationMode && isempty(findstr(fn,'damp'))==true))
            doPlot=false;
            
        end
        
        if (K==6)
            doPlot=true
        end
        
        if doPlot==true
            
            concentrations=[concentrations anaylteIndex];
            fprintf([fn '\n\n']);
            if isRinse==true
                if isempty(FileRinses{K,J})==false
                    shortData=FileRinses{K,J};
                else
                    shortData=FileDatas{K,J};
                end
            else
                shortData=FileDatas{K,J};
            end
            
            
            if isempty(shortData)==false
                try 
                if length(exampleTrace)<ccExample
                    exampleTrace{ccExample}=[];
                    
                end
                if isempty( exampleTrace{ccExample} )==true
                    exampleTrace{ccExample} =shortData(floor(length(shortData)/2):floor(length(shortData)/2)+100000);
                    ccExample=ccExample+1;
                end
                catch mex
                end
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% baseline Corect %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                bottomGap=10000;
                bottom = zeros([1 floor(length(shortData)/bottomGap)]);
                cc2=1;
                for M=1:bottomGap:floor(length(shortData)-bottomGap/2)
                    try
                        bottom(cc2)=min(shortData(M:M+bottomGap));
                        
                        cc2=cc2+1;
                    catch mex
                    end
                end
                X=(1:length(bottom))*bottomGap;
                f1=fit(X',bottom','poly7','Robust','Bisquare')
                background=feval(f1,1:length(shortData));
                if removeBackGround==true
                    shortData = shortData - background';%+ feval(f1,1);
                end
               
                background=mean(background);
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% find threshold %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                
                bottomGap=5000;
                bottom = zeros([1 floor(length(shortData)/bottomGap)]);
                cc2=1;
                for M=1:bottomGap:floor(length(shortData)-bottomGap/2)
                    try
                        m=max(shortData(M:M+bottomGap));
                        if m<100
                            bottom(cc2)=m-min(shortData(M:M+bottomGap));
                            
                            cc2=cc2+1;
                        end
                    catch mex
                    end
                end
                
                noiseSize = mode(bottom(1:max(1,cc2-10)));
                if removeBackGround==true
                    shortData=shortData-noiseSize/2;
                end
                % background=background-noiseSize/2;
                bShortData=shortData;
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% plot smoothed %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %
                Xs=[];% foundVoltagesX{voltage};
                if isempty(Xs)==false
                    if length(Xs)<length(shortData)
                        shortData=shortData(1:length(Xs));
                    else
                        if length(Xs)>length(shortData)
                            Xs=Xs(1:length(shortData));
                        end
                    end
                    % shortData=shortData-2000;
                    X=Xs;
                else
                    X=(1:length(shortData))+x;
                    % foundVoltagesX{anaylteIndex}=X;
                end
                
                x=X(end);
                X=X/20000;%/60;
                
                figure(1);
                if plotMode==analyteMode
                    col=colors{mod(K,length(colors)+1)};
                else
                    if plotMode==voltageMode
                        col=voltColors{voltage};
                    else
                        if plotMode==concentrationMode
                            col=concColor;
                        end
                    end
                end
                
                cCol=cCol+1;
                %                 if K==5
                %                     offset=-2000;
                %                 else
                offset=0;
                %                 end
                
                if isRinse==true
                    plot(X(10000:skips:end-10000),offset+shortData(10000:skips:end-10000),'b');
                    
                else
                    plot(X(10000:skips:end-10000),offset+shortData(10000:skips:end-10000),'color',col);
                end
                hold all
                
                %  plot(X(10000:skips:end-10000),offset+shortData(10000:skips:end-10000),'k');
                
                Y=mean(shortData)+200+offset;
                
                Y=300
                if isRinse==true
                    Y=-5;
                    text(X(1),Y, [ num2str(voltage) ' ' concentration ' Rinse']);%num2str(voltage));
                else
                    if plotMode==analyteMode
                        text(X(1),Y,  analyteName);%
                    else
                        if plotMode==voltageMode
                            text(X(1),Y, [ num2str(voltage) ]);%
                        else
                            if plotMode==concentrationMode
                                text(X(1),Y, [  concentration ]);%
                            end
                        end
                    end
                    %text(X(1),Y, [ num2str(voltage) ' ' concentration ' ' analyteName]);%
                end
                
                if isRinse==isRinse
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    if isRinse==false
                        r=Raws{K,J}';
                        
                        %r=r-feval(f1,1:length(shortData));
                    else
                        r=FileRinsesRaw{K,J}';
                    end
                    
                    if size(r)~=size(shortData)
                        shortData=shortData';
                    end
                    
                    if (length(shortData)<length(r))
                        r=r(1:length(shortData));
                    end
                    if length(shortData)~=length(r)
                        disp('what');
                    end
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% get stats %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    bShortData = (shortData - feval(f1,1:length(shortData)))'-noiseSize/2;%+ feval(f1,1);
                    peakThresh=max([45 noiseSize*1.5]);
                    tallIDX = find(bShortData>peakThresh);
                    dIDX=tallIDX(2:end)-tallIDX(1:end-1);
                    
                    
%                     if bShortData(1)>peakThresh
%                        dIDX(1)=0;
%                     end
%                     dIDX(end)=0;
                    
                    idx=find(dIDX~=1);
                    
                    offTimes = dIDX(idx);
                    
                  

                    amp=zeros([1 length(idx)]);
                    life=zeros([1 length(idx)]);
                    jump=zeros([1 length(idx)]);
                    
                    dispTrace = zeros([size(shortData)]);
                    
                 
                    starts =[];
                    if isempty(idx)==false && isempty(tallIDX)==false
                        endPeak=false;
                        startIndex=1;
                        for I=1:length(dIDX)
                        
                            if dIDX(I)==1
                                endIndex=I;
                                endPeak=true;
                                
                                if endIndex-startIndex==1
                                   starts=[starts I]; 
                                end
                            else
                                if endPeak
                                    try 
                                    seg =shortData( (tallIDX(startIndex+1)-100):(tallIDX(endIndex)+103) );
                                     dispTrace( (tallIDX(startIndex+1)-100):(tallIDX(endIndex)+103) )=100;
%                                     figure(2);plot(seg);
%                                     drawnow;
                                    amp(I) =mean(seg);
                                    life(I)=length(seg)-200;
                                    jump(I)=max(seg)-min(seg);
                                    catch mex
                                    end
                                end
                                endPeak=false;
                                startIndex=I;
                            end
                        end
                        
                        starts= starts(2:end)-starts(1:end-1);
                        
                        
%                         idxMapE=tallIDX(idx);
%                         idxMapS=tallIDX(idx-1);
%                         for I=2:length(idx)
%                             seg=shortData( idxMapS(I):idxMapE(I) );
%                             figure(2);plot(seg);
%                             dispTrace( idxMapS(I):idxMapE(I) )=100;
%                             amp(I-1) =mean(seg);
%                             life(I-1)=length(seg);
%                             try
%                                 jump(I-1)=abs(min(  shortData((idxMap(I-1)-7):idxMap(I-1)))  -  mean( shortData(idxMap(I-1)+2:idxMap(I)-1)));
%                             catch mex
%                                 jump(I-1)=0;
%                             end
%                         end
                        
                        peakTrace=dispTrace/100.* bShortData';
                        peakTrace(peakTrace==0)=[];
                    else
                        peakTrace=0;
                    end
                    
                    weightedOnTime =[weightedOnTime sum(peakTrace)];
                    onTime=[onTime length(idx)/length(shortData)*20000];
                    allIndexs=[allIndexs anaylteIndex];
                    
                    %  plot(X(10000:skips:end-10000),dispTrace(10000:skips:end-10000),'g');
                    
                    propAmp=[propAmp amp];
                    propLife=[propLife life];
                    propJump=[propJump jump];
                    lifeTimes=life;
                    %lifeTimes = idx(2:end)-idx(1:end-1);
                    
                    tallData = shortData(tallIDX);
                    
                    concByFolder{K}=anaylteIndex;
                    
                    
                    if (length(voltages)<5)
                       if (length(voltages)==1) 
                          offBig = offTimes;
                       else
                           offBig=[offBig offTimes];
                           offStarts=[offStarts starts];
                       end
                    end
                    
%                     [v xxx]=hist(offTimes,200);
%                      offTimeHistPeaks{length(voltages)}=v;
%                       offTimeHistPeaksX{length(voltages)}=xxx;
                    if isempty(ampHist{K})
                        ampHist{K}=hist(shortData,ampHistX);
                        ampHistPeaks{K}=hist(tallData,ampHistX);
                       
                        [timeHistPeaks{K},timeHistX]=hist(lifeTimes,timeHistX);
                    else
                        try 
                        ampHist{K}=ampHist{K}+hist(shortData,ampHistX);
                        ampHistPeaks{K}=ampHistPeaks{K}+hist(tallData,ampHistX);
                       
                        timeHistPeaks{K}=timeHistPeaks{K}+hist(lifeTimes,timeHistX);
                        catch mex
                            disp('x');
                        end
                    end
                    
                   
                    %                     figure(4)
                    %                     plot(X(10000:skips:end-10000),offset+r(10000:skips:end-10000),col);
                    %                     hold all;
                    %                     plot(X(10000:skips:end-10000),offset+shortData(10000:skips:end-10000),'g');
                    %
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% global stats %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    
                    %shortData=shortData(1:floor(length(shortData)/4));
                    [nPlat, nSpikesTime,platTime,platHeight,spikeHeight]=Times(r,shortData,40,2);
                    platHeights=[platHeights platHeight];
                    spikeHeights=[spikeHeights spikeHeight];
                    platTimes=[platTimes platTime];
                    nPlats=[nPlats nPlat];
                    spikes=[spikes nSpikesTime];
                    
                    baselines =[baselines background];
                    r=r-shortData;
                    
                    noise =[noise std( r)];
                    analyteIndexs=[analyteIndexs anaylteIndex];
                    skew=[skew skewness(r)];
                    
                    %                     figure(3);
                    %                     hold all;
                    %                     plot(X(10000:skips:end-10000),offset+r(10000:skips:end-10000),col);
                    %
                    clear r;
                end
                
                drawnow;
            end
            
        end
    end
    
    
%     figure(5);clf;
%     for I=1:length(offTimeHistPeaks)
%         seg=offTimeHistPeaks{I};
%         x=offTimeHistPeaksX{I};
%         if isempty(seg)==false
%             seg(end)=[];
%             %  seg=seg/sum(seg);
%             col=  voltColors{voltages(I)};
%             plot(x(1:end-1),seg,'color',col);
%             hold all;
%         end
%     end
    %     figure(2);
    %     scatter(analyteIndexs,noise,3,col,'fill');
    %     hold all;
    %
    figure(5);
    scatter(analyteIndexs,baselines,3,col,'fill');
    hold all;
    
    kBaselines(K)=mean(baselines);
    %
    %     figure(6);
    %     scatter(analyteIndexs,skew,3,col,'fill');
    %     hold all;
    %
    %     figure(7);
    %     scatter(analyteIndexs,platTimes/20000*1000,3,col,'fill');
    %     hold all;
    %
    %     figure(8);
    %     scatter(analyteIndexs,spikes,3,col,'fill');
    %     hold all;
    %
    %     figure(9);
    %     scatter(analyteIndexs,nPlats,3,col,'fill');
    %     hold all;
    
    aprops=[];
    aprops.propAmp=propAmp;
    aprops.propLife=propLife;
    aprops.propJump=propJump;
    props{K}=aprops;
end

figure(1);
xlabel('minutes');
ylabel('pA');

figure(3);
xlabel('minutes');
ylabel('pA');

figure(2);
xlabel('Gap Voltage(mV)');
ylabel('noise pA');

figure(4);
xlabel('minutes');
ylabel('pA');

figure(5);
xlabel('Analyte');
ylabel('Baseline pA');

figure(6);
xlabel('Analyte');
ylabel('Skew pA');

figure(7);
xlabel('Analyte(mV)');
ylabel('plats ms');

figure(8);
xlabel('Analyte(mV)');
ylabel('spikes (#)');

figure(9);
xlabel('Analyte(mV)');
ylabel('nPlats (#)');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if plotMode ==concentrationMode
    col=concentrationColors{mod(I,length(colors)+1)};
else
    col=colors{mod(I,length(colors)+1)};
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


figure(10);clf
for I=1:length(ampHist)
    
    b=ampHist{I};
    if isempty(ampHist{I})==false
        if plotMode ==concentrationMode
            col=concentrationColors{mod(I,length(concentrationColors)+1)};
        else
            col=colors{mod(I,length(colors)+1)};
        end
        b=b/sum(b);
        plot(ampHistX,b,'color',col);
        hold all;
    end
end
ylabel('Amplitudes (pA)');


figure(11);clf
for I=1:length(ampHistPeaks)
    
    b=ampHistPeaks{I};
    if isempty(ampHistPeaks{I})==false
        if plotMode ==concentrationMode
            col=concentrationColors{mod(I,length(concentrationColors)+1)};
        else
            col=colors{mod(I,length(colors)+1)};
        end
        b=b/sum(b);
        plot(ampHistX,b,'color',col);
        hold all;
    end
end
ylabel('Peak Amplitudes (pA)');

figure(12);clf
timeHistX(end)=[];
for I=1:length(timeHistPeaks)
    
    b=timeHistPeaks{I};
    if isempty(timeHistPeaks{I})==false
        b(end)=[];
        if plotMode ==concentrationMode
            col=concentrationColors{mod(I,length(concentrationColors)+1)};
        else
            col=colors{mod(I,length(colors)+1)};
        end
        b=b/sum(b);
        plot(timeHistX/2000*1000,b,'color',col);
        hold all;
    end
end
ylabel('Peak Times (ms)');

figure(13);clf;
for I=2:length(props)
    aprops=props{I};
    if isempty(aprops)==false
        %     aprops.propAmp=propAmp;
        %     aprops.propLife=propLife;
        %     aprops.propJump=propJump;
        % if plotMode ==concentrationMode
        col=concentrationColors{mod(I,length(concentrationColors))+1};
        % else
             col=colors{mod(I,length(colors)+1)};
        % end
        if isempty(aprops.propAmp)==false
            A=aprops.propAmp(1:20:end);
            L=(1+ aprops.propLife(1:20:end))/20000*1000;
            J=aprops.propJump(1:20:end);
            figure(13);
            scatter3(A,L ,J,4,col);
            hold all
            figure(14);
            plot(A,L,'.','color',col);
            hold all
        end
        
    end
end
figure(13);
xlabel('Absolute amplitude (pA)')
ylabel('Lifetime');
zlabel('Spike Amplitude (pA)');
figure(14);
xlabel('Absolute amplitude (pA)')
ylabel('Lifetime');


figure(14);clf;

% semilogx(10.^allIndexs, weightedOnTime/2000*1000 );
% ylabel('Weighted On Time (ms)');
% xlabel('Concentration (M)');
%
% figure(15);clf;
%
% %idx=find(onTime>2.6*10^6);
% %onTime(idx)=[];
% %allIndexs(idx)=[];
%
% semilogx(10.^allIndexs, onTime/2000*1000 );
% ylabel('Effective Spikes Per Second ');
% xlabel('Concentration (M)');


if false
    fid=fopen('c:\data\exampleConcentration2.csv','w');
    
    for I=1:length(exampleTrace{1})
        for K=1:length(exampleTrace)
            if isempty(exampleTrace{K})==false
                fprintf(fid,'%d,',exampleTrace{K}(I));
            end
        end
        fprintf(fid,'\n');
    end
    
    fclose(fid);
    
end
