voltColors{200}=[.5 .5 0];
voltColors{260}=[0 0 0];
voltColors{280}=[1 0 0];
voltColors{300}=[0 1 1];
voltColors{320}=[0 1 0];
voltColors{330}=[.9 .75 0];
voltColors{350}=[1 0 1];
voltColors{380}=[0 0 1];
voltColors{400}=[0 .5 .5];


ControlCol=[0 0 1];
ACol=[0 1 0];
AbCol=[1 0 .9];
CCol=[0 0 1];
mCCol=[0 1 1];
TCol=[.9 .75 0];
GCol=[1 0 0];
pep=[.5 .5 0];

mControl =1;
mA=2;
mG=3;
mC=4;
mT=5;
mmC=6;
mPeptide =7;
mABasic =8;

concentrationColors = {[0 0 0] [0 0 1] [.9 .75 0] [1 0 0] [0 1 0] [1 0 1] [0 0 1] [0 0 0] [0 0 0] [0 0 1] [.9 .75 0] [1 0 0] [0 1 0] [1 0 1] [0 0 1] [0 0 0]};
colors={ ControlCol ACol pep ACol GCol CCol mCCol AbCol };
analyteNames = {'Control', 'dAMP', 'aGMP', 'dCMP','dTMP','dmCMP','peptide','A_basic'};
analyteMap = [mControl mA mPeptide mA mG mC mmC  mABasic];

col=[0 1 1];
foundVoltagesX=cell([1 500]);
skips=1;

peakThresh=40;

analyteMode=1;
voltageMode=2;
concentrationMode =3;

plotMode =analyteMode;


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
ampHistX=1:3:450;
ampHist=cell([1  length(pathnames)]);
ampHistPeaks=cell([1  length(pathnames)]);
timeHistPeaks=cell([1  length(pathnames)]);
concByFolder=cell([1  length(pathnames)]);
weightedOnTime =[];
allIndexs=[];
onTime=[];

clear saveAble;

kBaseline=[];

exampleTrace=cell([1 length(pathnames)]);
ccExample=1;
props={};
x=1;
for K=4:min([ size(FileDatas,1) length(pathnames)])
    
    
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
    
    
    noise=[];
    analyteIndexs=[];
    baselines=[];
    baseMode=[];
    skew=[];
    platTimes=[];
    nPlats =[];
    spikes=[];
    
    propAmp=[];
    propLife=[];
    propJump=[];
    
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
                
                
                if isempty(findstr(fn,'10nm'))==false
                    doPlot=true;
                    concentration = '10nm';
                    concColor=concentrationColors{3};
                    if plotMode ==concentrationMode
                        anaylteIndex=-6;
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
                    
                    if isempty(findstr(fn,'1um'))==false
                        doPlot=true;
                        concentration = '10um';
                        concColor=concentrationColors{2};
                        if plotMode ==concentrationMode
                            anaylteIndex=1-6;
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
                end
                
                if doPlot
                    voltage = str2num( fn(12:14));
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
        end
        
        if K==1
            isRinse=true;
            doPlot=true;
        end
        
        
        if doPlot==true
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
                
                if length(exampleTrace)<ccExample
                    exampleTrace{ccExample}=[];
                end
                
                if isempty( exampleTrace{ccExample} ) ==true
                    exampleTrace{ccExample} =shortData(1:50000);
                    ccExample=ccExample+1;
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
                f1=fit(X',bottom','poly1','Robust','Bisquare')
                
                baseMode=[baseMode  mode(shortData)];
               % shortData = shortData - feval(f1,1:length(shortData))';%+ feval(f1,1);
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% find threshold %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                
                bottomGap=1000;
                bottom = zeros([1 floor(length(shortData)/bottomGap)]);
                cc2=1;
                for M=1:bottomGap:floor(length(shortData)-bottomGap/2)
                    try
                        m=max(shortData(M:M+bottomGap));
                        %if m<100
                            bottom(cc2)=m-min(shortData(M:M+bottomGap));
                            
                            cc2=cc2+1;
                        %end
                    catch mex
                    end
                end
                
                noiseSize = min(bottom(1:(cc2-10)));
                %shortData=shortData-noiseSize/2;
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
                %  X=X/20000/60;
                
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
                
                
                if isRinse==true
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
                
                if isRinse==false
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    r=Raws{K,J}';
                    
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
                     bShortData = (r - feval(f1,1:length(shortData)))'-noiseSize;%+ feval(f1,1);
                     bShortData = smooth(bShortData,35);
                    peakThresh=max([10 noiseSize*1.5]);
                    tallIDX = (bShortData>peakThresh);
                   
                    
                    idx=find(tallIDX==1);
                    didx= idx(2:end)-idx(1:end-1);
                    
                    ts = find(didx~=1);
                    
                    allStarts = idx(ts+1);
                    allEnds = idx(ts);
                    
                    if isempty(allStarts)==true
                        allStarts=zeros([1 1]);
                        allEnds=allStarts+1;
                    end
                    if (allEnds(1)<allStarts(1))
                        allEnds(1)=[];
                        disp('problem');
                    end
                    allStarts=allStarts-2;
                    allEnds=allEnds+2;
                    
                    amp=zeros([1 length(allStarts)]);
                    life=zeros([1 length(allStarts)]);
                    jump=zeros([1 length(allStarts)]);
                    
                    dispTrace = zeros([size(shortData)]);
                    for I=2:length(allStarts)-2
                        seg=shortData( allStarts(I):allEnds(I) );
                        dispTrace( allStarts(I):allEnds(I))=100;
                        amp(I-1) =mean(seg);
                        life(I-1)=length(seg);
                        try
                            jump(I-1)=abs(min(seg)-shortData(allStarts(I)+2));
                        catch mex
                            jump(I-1)=0;
                        end
                    end
                    
                    peakTrace=dispTrace/100.* bShortData;
                    peakTrace(peakTrace==0)=[];
                    
                    weightedOnTime =[weightedOnTime sum(peakTrace)];
                    onTime=[onTime sum(dispTrace)/100];
                    allIndexs=[allIndexs anaylteIndex];
                    
%                     clf;
%                      plot(X(10000:skips:end-10000),bShortData(10000:skips:end-10000),'b');hold all;
%                      plot(X(10000:skips:end-10000),peakThresh+dispTrace(10000:skips:end-10000),'g');hold off;
                    
                    propAmp=[propAmp amp];
                    propLife=[propLife life];
                    propJump=[propJump jump];
                    lifeTimes=life;
                    %lifeTimes = idx(2:end)-idx(1:end-1);
                    
                    tallData = shortData(tallIDX==1);
                    
                    concByFolder{K}=anaylteIndex;
                    
                    if isempty(ampHist{K})
                        ampHist{K}=hist(shortData,ampHistX);
                        ampHistPeaks{K}=hist(tallData,ampHistX);
                        
                        [timeHistPeaks{K},timeHistX]=hist(lifeTimes,timeHistX);
                    else
                        ampHist{K}=ampHist{K}+hist(shortData,ampHistX);
                        ampHistPeaks{K}=ampHistPeaks{K}+hist(tallData,ampHistX);
                        timeHistPeaks{K}=timeHistPeaks{K}+hist(lifeTimes,timeHistX);
                    end
                    %                     figure(4)
                    %                     plot(X(10000:skips:end-10000),offset+r(10000:skips:end-10000),col);
                    %                     hold all;
                    %                     plot(X(10000:skips:end-10000),offset+shortData(10000:skips:end-10000),'g');
                    %
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% global stats %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    
                    
                    [nPlat, nSpikesTime,platTime]=Times(r,shortData,400,2);
                    platTimes=[platTimes platTime];
                    nPlats=[nPlats nPlat];
                    spikes=[spikes nSpikesTime];
                    
                    baselines =[baselines min(shortData)];
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
    
    figure(2);
    scatter(analyteIndexs,noise,3,col,'fill');
    hold all;
    
    figure(5);
    scatter(analyteIndexs,baselines,3,col,'fill');
    hold all;
    
    kBaseline(K)=mean(baseMode);
    
    figure(6);
    scatter(analyteIndexs,skew,3,col,'fill');
    hold all;
    
    figure(7);
    scatter(analyteIndexs,platTimes/20000*1000,3,col,'fill');
    hold all;
    
    figure(8);
    scatter(analyteIndexs,spikes,3,col,'fill');
    hold all;
    
    figure(9);
    scatter(analyteIndexs,nPlats,3,col,'fill');
    hold all;
    
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
xlabel('Analyte(mV)');
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


saveAble.colors=colors;
saveAble.analyteNames=analyteNames;
saveAble.analyteMap=analyteMap;
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
        % b=b/sum(b);
        semilogy(ampHistX,b,'color',col);
        hold all;
    end
end
ylabel('Amplitudes (pA)');


saveAble.ampHistX=ampHistX;
saveAble.ampHist=ampHist;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure(11);clf
cc=1;
lNames = {};
t=[];
for I=1:length(ampHistPeaks)
    
    b=ampHistPeaks{I};
    if isempty(ampHistPeaks{I})==false && sum(b)>0
        if plotMode ==concentrationMode
            col=concentrationColors{mod(I,length(concentrationColors)+1)};
        else
            col=colors{mod(I,length(colors)+1)};
        end
     t=   horzcat(t,b');
        
        b=b/sum(b);
        plot(ampHistX,b,'color',col);
        hold all;
        
         lNames{cc}=analyteNames{analyteMap(I)};
         cc=cc+1;
    end
end
xlabel('Peak Amplitudes (pA)');
legend(lNames);

saveAble.ampHistX=ampHistX;
saveAble.ampHistPeaks=ampHistPeaks;
saveAble.ampHistPeaksBlock=t;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure(12);clf
X=timeHistX;
X(end)=[];
cc=1;
lNames = {};
t=[];
for I=1:length(timeHistPeaks)
    
    b=timeHistPeaks{I};
    if isempty(timeHistPeaks{I})==false && sum(b)>1
        b(end)=[];
        if plotMode ==concentrationMode
            col=concentrationColors{mod(I,length(concentrationColors)+1)};
        else
            col=colors{mod(I,length(colors)+1)};
        end
         t=   horzcat(t,b');
        b=b/sum(b);
        plot(X/2000*1000,b,'color',col);
        hold all;
        
         lNames{cc}=analyteNames{analyteMap(I)};
         cc=cc+1;
    end
end
xlabel('Peak Times (ms)');
legend(lNames);

saveAble.timeHistX=timeHistX;
saveAble.timeHistPeaks=timeHistPeaks;
saveAble.timeHistPeaksBlock=t;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure(23);clf;
cc=1;
lNames = {};
coords =[];
ident = [];
for I=1:length(props)
    aprops=props{I};
    if isempty(aprops)==false && length(aprops.propAmp)>3
        if plotMode ==concentrationMode
            col=concentrationColors{mod(I,length(concentrationColors))+1};
        else
            col=colors{mod(I,length(colors)+1)};
        end
        
        t = horzcat(aprops.propAmp', log( aprops.propLife+.1)');
        t= horzcat(t, aprops.propJump');
        scatter3(aprops.propAmp,  aprops.propLife,aprops.propJump,4,col);
        hold all
         lNames{cc}=analyteNames{analyteMap(I)};
        cc=cc+1;
        
        
        coords=vertcat(coords,t);
        t = zeros([1 size(t,1)])+I;
        ident=vertcat(ident,t');
    end
end
xlabel('Absolute amplitude (pA)')
ylabel('Lifetime');
zlabel('Jump (pA)');
legend(lNames);

saveAble.props=props;
saveAble.propsBlock=coords;
saveAble.propsBlockIdent=ident;

ratings=coords;
w = 1./var(ratings);
[wcoeff,score,latent,tsquared,explained] = pca(ratings,'VariableWeights',w);

figure(51);clf;
hold all;
for I=1:length(props)
    idx=find(ident==I);
    plot(score(idx,1),score(idx,2),'+')
end
hold off;
xlabel('1st Principal Component')
ylabel('2nd Principal Component')
legend(lNames);

figure(53);clf;
hold all;
for I=1:length(props)
   idx=find(ident==I);
    scatter3(score(idx,1),score(idx,2),score(idx,3))
end
hold off;
xlabel('1st Principal Component')
ylabel('2nd Principal Component')
zlabel('3nd Principal Component')
legend(lNames);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

figure(14);clf;

semilogx(10.^allIndexs, weightedOnTime/2000*1000 );
ylabel('Weighted On Time (ms)');
xlabel('Concentration (M)');

figure(15);clf;

idx=find(onTime>2.6*10^6);
onTime(idx)=[];
allIndexs(idx)=[];

semilogx(10.^allIndexs, onTime/2000*1000 );
ylabel('On Time (ms)');
xlabel('Concentration (M)');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if false
    fid=fopen('c:\data\exampleConcentration.csv','w');
    
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

if true 
    %save('c:\data\\20140401_IBM_A_11_RIE_APGCmCAb-300mV_.mat','saveAble');
end
