
figure(1);clf;
figure(2);clf;
figure(12);clf;
voltages =[ 200 230 250 280 300 350 400];
cc=1;
plotCC=1;


spikeHeightCut=2;

for K=1:2%length(shorts)-1% length(pathnames)
    pathname=pathnames{K};
    files = UsedFiles{K};
    idx=idxs{K};
    cc3=cc;
    
    Xm=[];
    longData=[];
    m=min([length(files) 7]);
    for J=1:m
        fn=files{J};
        file= [pathname '\' fn]
        loadedFiles{cc2}=file;
        cc2=cc2+1;
        
%         if K==2
%             shortData=raws{J};
%         else 
            [shortData] = abfload(file,'start',0)';
%         end
        
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
        %X=(1:length(bottom))*1000;
        %         f1=fit(X',bottom','poly5','Robust','Bisquare')
        %         shortData = shortData - feval(f1,1:length(shortData))';%+ feval(f1,1);
        %
        X=(1:length(shortData))+cc;
        cc=cc+length(shortData);
        figure(1);
        plot(X(1:300:end)/20000*1000,shortData(1:300:end));
        hold all;
        drawnow;
        
        if isempty(findstr(fn,'Rinse'))==false || (K==1) %#ok<FSTR>
            
            
%             mn= min(shortData);
%             mx=max(shortData);
%             shortData =255*( shortData - mn)/(mx-mn);
%             dst = restore_image(shortData', 80, 200, .1, 100);
%             figure(2);
%             plot(shortData);
%             hold all;
%             plot(dst);
%             
%             shortRinse = dst*(mx-mn)/255+mn;
            
            
%             rinses=[rinses  shortData]; %#ok<AGROW>

%               output=WienerScalart96(vertcat(rinses', shortData'),50000,length(rinses)/(length(shortData)));
%               p = output(end-length(shortData):end-1)';
 p=wRinses;
 
          %  p=shortData;
            peakSizeControl(J)=rms(p);
            sNoiseBeforeControldRB(J)= std(shortData);
            
            noise =std(p);
            idx=find(p< ( 4*noise+min(p)));
            offsetBaselineControl(J)=mean(p(idx));

            
            peakThreshold = (p-mean(p))./noise;
            envelope=[];
            cc3=1;
            for I=1:1000:length(peakThreshold)-1000
                envelope(cc3)=max(peakThreshold(I:I+1000));
                cc3=cc3+1;
            end
            peakThreshold=(3*mode( envelope)+max(envelope))/4;
             envelope=[];
             
            npeakThreshold =-1* (p-mean(p))./noise;
            envelope=[];
            cc3=1;
            for I=1:1000:length(npeakThreshold)-1000
                envelope(cc3)=max(npeakThreshold(I:I+1000));
                cc3=cc3+1;
            end
            npeakThreshold=(3*mode( envelope)+max(envelope))/4;
            envelope=[];
 
            shortData=shortData(1:length(p))-p;
            
            meanAfterControlRA(J)=mean(shortData);
            noiseAfterControl(J)=std(shortData);
            kurtosisControlA(J)=kurtosis(shortData);
            skewnessControl(J)=skewness(shortData);
           
            x =( (p-mean(p))/noise );
            idxP= peakfinder(x,1,peakThreshold,1);
            idxN=peakfinder(x,1,npeakThreshold,-1);
 
            level = 1;
            [c,l] = wavedec(x,level,'haar');
            
            wCoefP=zeros([level,length(idxP)]);
            wCoefN=zeros([level,length(idxN)]);
            for I=1:level
                d1 =( detcoef(c,l,I));
                d1=interpft(d1,round(length(x)/length(d1))*length(d1));
                d1P=d1(idxP);
                wCoefP(I,:)=abs(d1P);
                wCoefN(I,:)=d1(idxN);
            end
            
            s1=wCoefP(1,:);
            idxSpike1 = find(s1>spikeHeightCut);
            spike1C=length(idxSpike1 );
            
            spike1AC=mean( s1(idxSpike1))*noise;
            
            s1=wCoefN(1,:);
            idxSpiken1 = find(s1<-1*spikeHeightCut);
            spiken1C=length(idxSpiken1 );
            
            spiken1AC=abs(mean( s1(idxSpiken1))*noise);
            
            figure(12)
            hold all;
            X=(1:length(p))+plotCC;
            plot(X(1:3:end)/20000*1000,p(1:3:end));
            plotCC=X(end);
            
        else
            p=shorts{J};
            p=p(1:end);
            %raws{J}=shortData;
            peakSize(J)=rms(p);
           
            sNoiseBeforedB(J)= std(shortData);
            
            try 
              shortData=shortData-p;
            catch mex
                try 
                p=p';
                shortData=shortData-p;
                catch mex
                    if length(p)>length(shortData)
                        p=p(1:length(shortData))';
                        shortData=shortData-p;
                    else
                        shortData=shortData(1:length(p));
                        shortData=shortData-p;
                    end
                end
            end
            
            shortData =shortData(floor(.1*length(shortData)):end);
            p=p(floor(.1*length(shortData)):end);
            
            meanAfter(J)=mean(shortData);
           
            noiseAfter(J)=std(shortData);
            kurtosisA(J)=kurtosis(shortData);
            sA(J)=skewness(shortData);
            
            x =( (p-mean(p))/noise );
            idxP= peakfinder(x,1,peakThreshold,1);
            idxN=peakfinder(x,1,npeakThreshold,-1);
%             [v,bins]=hist(x(idx),50);
%             plot(bins,v);
            level = 1;
            [c,l] = wavedec(x,level,'haar');
            
            wCoefP=zeros([level,length(idxP)]);
            wCoefN=zeros([level,length(idxN)]);
            for I=1:level
                d1 =( detcoef(c,l,I));
                d1=interpft(d1,round(length(x)/length(d1))*length(d1));
               
                wCoefP(I,:)=abs(d1(idxP));
                wCoefN(I,:)=d1(idxN);
            end
            
            s1=wCoefP(1,:);
            idxSpike1 = find(s1>spikeHeightCut);
            spikeNumber(J)=length(idxSpike1 );
            
            spike1Amplitude(J)=mean( s1(idxSpike1))*noise;
            
            s1=wCoefN(1,:);
            idxSpiken1 = find(s1<-1*spikeHeightCut);
            spiken1(J)=length(idxSpiken1 );
            
            spikeNeg_Amplitude(J)=abs(mean( s1(idxSpiken1))*noise);
            
            
            idx=find(p< ( 4*noise+min(p)));
            offsetBaseline(J)=mean( p(idx));
            
          %  p=p-mean( p(idx));

            %p=p(1:60000);
            ps=p(:)-offsetBaseline(J);
            for I=10:length(idxP)-10
                ps((idxP(I)-3):(idxP(I)+3))=-10000;
            end
            for I=10:length(idxN)-10
                ps((idxN(I)-3):(idxN(I)+3))=-10000;
            end
            
            ps(ps==-10000)=[];
            p2=ps(:);
            ps=abs(ps-smooth(ps,5));
            
%             figure(1);clf;
%             plot(p);
%             hold all
%             plot(ps);
            
            idx=find(ps<3);
            idx2=find( p2(idx)>25);
            
            PlatAmplitude(J)=mean(p2(idx2));
            
            idx=  idx(idx2);
            didx=idx(2:end)-idx(1:end-1);
            idx2=  find(didx~=1);
            didx=idx2(2:end)-idx2(1:end-1);
            didx(didx<3)=[];
            
            PlatNumber(J)=length( didx);
%             PlatLengthA(J)=mean( didx);
%             PlatLengthm(J)=mode( didx);
%             PlatLengthM(J)=max( didx);
           
            figure(1);clf
            plot(x);
            
            
            figure(12)
            hold all;
            X=(1:length(p))+plotCC;
            plot(X(1:3:end)/20000*1000,p(1:3:end));
            plotCC=X(end);
          
        end
    end
    ccPlot=ccPlot+1;
end

figure(8);clf;
semilogy(voltages,spikeNumber,'linewidth',3);
hold all;
semilogy(voltages,PlatNumber,'linewidth',3);
semilogy(voltages,spiken1,'linewidth',3);
scatter([400],spike1C,'fill');
% semilogy(voltages,spike3);
title('SpikeType');
legend('Spikes','Plat.','Neg. Spikes','control spikes');
xlabel('Gap Voltage');
ylabel('Number Peaks');

figure(9);clf;
plot(voltages,spike1Amplitude,'linewidth',3);
hold all;
plot(voltages,spikeNeg_Amplitude,'linewidth',3);
plot([400],spiken1AC,'+','linewidth',3);
plot(voltages,PlatAmplitude,'linewidth',3);

xlabel('Gap Voltage');
ylabel('pA');
legend('Pos. Spike Amp.','Neg Spike Amp.','Spike Control','Plat. Amplitude');



% figure(11);clf;
% scatter(voltages,spike9);
% title('spike9');


figure(1);clf;
scatter(voltages,kurtosisA);
hold all;
scatter(400,kurtosisControlA,'fill');
title('kurtosis');
xlabel('Gap Voltage');
ylabel('pA');




figure(2);clf;
scatter(voltages,offsetBaseline,'fill');
hold all;
scatter(400,offsetBaselineControl,'fill');
title('baseline offset');
xlabel('Gap Voltage');
ylabel('pA');



figure(3);clf;
scatter(voltages,sNoiseBeforedB,'fill');
hold all;
scatter(400,sNoiseBeforeControldRB);
title('noise before');
xlabel('Gap Voltage');
ylabel('pA');


figure(4);clf;
scatter(voltages,meanAfter,'fill');
hold all;
scatter(400,meanAfterControlRA,'fill');
title('mean after');
xlabel('Gap Voltage');
ylabel('pA');

figure(5);clf;
scatter(voltages,noiseAfter,'fill');
hold all;
scatter(400,noiseAfterControl);
title('noise after');
xlabel('Gap Voltage');
ylabel('pA');

figure(6);clf;
scatter(voltages,sA,'fill');
hold all;
scatter(400,skewnessControl,'fill');
title('skew after');
xlabel('Gap Voltage');
ylabel('pA');


figure(7);clf;
scatter(voltages,peakSize,'fill');
hold all;
scatter(400,peakSizeControl,'fill');
title('peak size');
xlabel('Gap Voltage');
ylabel('pA');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

tableE = zeros([10 length(voltages)]);

tableE(1,:)=voltages;
tableE(2,:)=spikeNumber;
tableE(3,:)=PlatNumber;
tableE(4,:)=spiken1;
tableE(5,:)=spikeNeg_Amplitude;
tableE(6,:)=PlatAmplitude;
tableE(7,:)=spikeNeg_Amplitude;
tableE(8,:)=kurtosisA;
tableE(9,:)=offsetBaseline;
tableE(10,:)=sNoiseBeforedB;
tableE(11,:)=meanAfter;
tableE(12,:)=noiseAfter;
tableE(13,:)=sA;
tableE(14,:)=peakSize;

colNames ={'Voltage','# Pos Spikes','# Plat.','# Neg Spikes','Spike Amp','Plat. Amp', ...
    'Neg Spike Amplitude','Kurtosis','Baseline shift','Raw Noise','Sample Average','Raw Noise After','Skewness','RMS'};

cTable=[];
for I=1:length(voltages)
    cTable{1,I}=colNames{I};
    for J=1:size(tableE,1)
        cTable{I+1,J}=tableE(J,I);
    end
end
