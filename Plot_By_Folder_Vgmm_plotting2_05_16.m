% for I=1:100
%     try
% %         if (I<20) || I>29
% %             close(I);
% %         else
%             figure(I);clf;
% %         end
%     catch mex
%     end
% end
%close all;

clear scatters

PossibleBottom=0;
for cFolder=1:length(curFolder)
    figure(20+cFolder);clf;
    figure(40+cFolder);clf;
    figure(70+cFolder);clf;
    figure(80+cFolder);clf;
    byFolder=allFolders{cFolder};
    flats =[];
    flats2=[];
    ccFlats =1;
    figure(1);
    template=[];
    ampX=0:1:800;
    dAmpX = 0:.1:300;
    ampXshifted=ampX;
    for cNames =2:min([4 size(byFolder,1)])
        col=colors{cNames};
        
        cData = byFolder(cNames,:);
        fTests=1;
        cFiles=1;
        for J=1:2:1%length(cData)
            
            t=cData{J};
            if (isempty(t)==false)
                cFiles=cFiles+1;
                if cFiles==30
                    cFiles=1;
                    break;
                end
                figure(1);clf;hold all;
                %plot(smooth(t.shortData,21));
                plot((t.shortData));%(5.05e5:5.085e5)));
                plot(t.cShortData);%(5.05e5:5.085e5),'r');
                
                
                tt=t.peakValues*1;%-t.bottom;
                dTT= diff(t.peakValues);
                
                if cNames==2 && J==1 && cFolder>1
                    PossibleBottom=t.bottom;
                end
                
                if (true)
                    for KKK=1:1
                        classes = t.classed;
                        levels = t.levels;
                        mu=[];
                        for I=1:length(levels)
                            mu(I)=levels{I}.m;
                        end
                        [v,idx]=sort(mu);
                        levels=levels(idx);
                        tClasses = zeros(size(classes));
                        for I=1:length(levels)
                            tClasses(classes==idx(I))=I;
                        end
                        classes = tClasses;
                        
                        mC = min(classes);
                        MC = max(classes);
                        
                        rcurPeaks =[];
                        rcurWidths =[];
                        rcurPeaksM =[];
                        rcurPeaksJ=[];
                        rcurPeaksDiff=[];
                        ccRC=1;
                        ttBaseline=zeros(size(t.nShortData));
                        ttBaseline(1:end) =levels{mC}.m-t.bottom;%levels{mC}.m;% zeros(size(t.nShortData));
                        for I=mC:MC
                            idx = find(classes<=I)' ;
                            %                     if (idx(1)~=1)
                            %                         idx=[1 idx];
                            %                     end
                            %                     if (idx(end)~=length(classes))
                            %                         idx = [idx length(classes)];
                            %                     end
                            
                            d=idx(2:end)-idx(1:end-1);
                            idx2=find(d~=1);
                            if isempty(idx2)==false
                                sI=idx(idx2);
                                if idx2(end)==length(idx)
                                    idx2(end)=[];
                                    eI=idx(idx2+1);
                                else
                                    eI=idx(idx2+1);
                                end
                                
                                
                                for K=1:length(sI)
                                    seg=t.nShortData(sI(K):eI(K));
                                    rcurPeaks(ccRC) =mean(seg)-t.bottom;
                                    rcurWidths(ccRC) =length(seg);
                                    rcurPeaksM(ccRC) =median(seg)-t.bottom;
                                    rcurPeaksDiff(ccRC) = abs( median(seg)-median(ttBaseline(sI(K):eI(K))));
                                    if sI(K)>1
                                        rcurPeaksJ(ccRC)=abs(t.nShortData(sI(K)-1) - t.nShortData(sI(K)+1));
                                    else
                                        rcurPeaksJ(ccRC)=0;
                                    end
                                    ttBaseline(sI(K):eI(K))= rcurPeaksM(ccRC);%t.levels{I+1}.m; %
                                    ccRC=ccRC+1;
                                end
                                ttBaseline(1:sI(1))=t.levels{I+1}.m-t.bottom;
                                ttBaseline(eI(end):length(ttBaseline))=t.levels{I+1}.m-t.bottom;
                                
                            end
                            plot(ttBaseline);
                            drawnow;
                        end
                        
                        col=colors{cNames};
                        %                         figure(60+cFolder);hold all
                        %                         scatter(rcurPeaksM(1:10:end),rcurWidths(1:10:end),3,col);
                        %                         set(gca, 'YScale', 'log')
                        %
                        %                         if cFolder==3
                        %                             rcurPeaksDiff=rcurPeaksDiff-80;
                        %                         end
                        if cFolder==2
                            rcurPeaksDiff=rcurPeaksDiff-PossibleBottom+30;
                        else
                            rcurPeaksDiff=rcurPeaksDiff-PossibleBottom;
                        end
                        figure(70+cFolder);hold all
                        [bins xxs]=hist(rcurPeaksDiff,200);
                        bins=bins/sum(bins);
                        idx=find(bins>.0005);
                        if cNames==2 && cFolder==1
                            %       scatter(rcurPeaksDiff(1:10:end)-xxs(idx(1))-15 ,rcurWidths(1:10:end),3,col);
                            rcurPeaksDiff=rcurPeaksDiff-xxs(idx(1))-15 ;
                        else
                            if cNames==4 && cFolder==4
                                %           scatter(rcurPeaksDiff(1:10:end)-xxs(idx(1))-10 ,rcurWidths(1:10:end),3,col);
                                rcurPeaksDiff=rcurPeaksDiff-xxs(idx(1))-10 ;
                            else
                                if cNames==2 && cFolder==4
                                    %             scatter(rcurPeaksDiff(1:10:end)-xxs(idx(1))-5 ,rcurWidths(1:10:end),3,col);
                                    rcurPeaksDiff=rcurPeaksDiff-xxs(idx(1))-5 ;
                                else
                                    %    scatter(rcurPeaksDiff(1:10:end)-xxs(idx(1)) ,rcurWidths(1:10:end),3,col);
                                    rcurPeaksDiff=rcurPeaksDiff-xxs(idx(1)) ;
                                end
                            end
                        end
                        scatter(rcurPeaksDiff(1:10:end) ,rcurWidths(1:10:end),3,col);
                        
%                         if cFolder ==3
%                             scatter(rcurPeaksDiff(1:10:end)/4+2.5,rcurWidths(1:10:end),3,col);
%                         else
%                             if cFolder==4
%                                 scatter(rcurPeaksDiff(1:10:end)/4+5,rcurWidths(1:10:end),3,col);
%                             else
%                                 if cFolder==2
%                                     scatter(rcurPeaksDiff(1:10:end)/4+2,rcurWidths(1:10:end),3,col);
%                                 else
%                                     scatter(rcurPeaksDiff(1:10:end)/4,rcurWidths(1:10:end),3,col);
%                                 end
%                             end
%                         end
                        xlim([0 30]);
                        
                        tS.diff= rcurPeaksDiff;
                        tS.width=rcurWidths;
                        scatters{cFolder,cNames,J} = tS;
                        clear tS;
                        set(gca, 'YScale', 'log')
                        if cFolder ~=1
                            xlim([0 80])
                        else
                            xlim([0 250]);
                        end
                    end
                end
                
                
                bins=hist(tt,ampX);
                bins(1)=0;
                [pks,loc]=findpeaks(bins);
                bins=bins./sum(bins);
                
                dbins=hist(-1*dTT,dAmpX);
                dbins(1)=0;
                dbins=dbins./sum(dbins);
                
                
                if  J==1% isempty(template) %
                    %                 sD= t.shortData(1:50:end);
                    %                 label=vbgm(sD',20);
                    %                 mu=[];
                    %                 for I=1:max(label)
                    %                     mu(I)=mean(sD(label==I));
                    %                 end
                    %                 mu=sort(mu);
                    pks=pks/length(tt);
                    idx =find(pks<.001);
                    loc(idx)=[];
                    pks(idx)=[];
                    
                    if cFolder ==4
                        bLines (2)=48;
                        bLines (3)=94;%87
                        bLines (4)=64;%58
                        baseline=bLines(cNames);
                    else
                        if cFolder ==3
                            bLines (2)=103;
                            bLines (3)=120;
                            bLines (4)=125;
                            bLines(6)=130;
                            baseline=bLines(cNames);
                        else
                            if cFolder ==1
                                bLines (2)=68;
                                bLines (3)=90;
                                bLines (4)=92;
                                bLines (5)=40;
                                baseline=bLines(cNames);
                                if cNames==2
                                    %                                  bins(1:round(length(bins)/2))=0;
                                    %                                   bins=bins./sum(bins);
                                    bins=bins*1.5;
                                end
                            else
                                baseline=ampX(loc(1)); %mu(1);%
                            end
                        end
                    end
                    %  baseline=0;
                    template = bins;
                    tBaseline = baseline;
                    ampXshifted=ampX;
                    shift=0;
                    
                    
                else
                    
                    filter1=1;%;blackman(length(template),'symmetric')';
                    
                    Image1=template.*filter1-mean(template);
                    Image2=bins.*filter1-mean(bins);
                    FFT1 =( fft(Image1));
                    FFT2 =conj( (fft(Image2)));
                    FFTR = FFT1.*FFT2;
                    magFFTR = abs(FFTR);
                    FFTRN = (FFTR./magFFTR);
                    result =fftshift( ifft(FFTR));
                    result = smooth(result,5);
                    %                figure(8);clf;plot(result)
                    [v,idx]=max(result);
                    
                    shift=ampX( floor(length(template)/2))-ampX(idx);
                    
                    %shift=0
                    disp(shift);
                    ampXshifted=ampX-shift;
                end
                ampXshifted=ampXshifted-tBaseline;
                
                %                 if cNames==5
                %                 shift=0;
                %                 end
                tt=t.peakValues*1-shift-tBaseline;
                flats(1:length(t.peakValues),ccFlats)=tt;
                ccFlats=ccFlats+1;
                
                bins=hist(tt,ampX);
                bins(1)=0;
                bins=bins./sum(bins);
                
                figure(cFolder+20);hold all;
                %                 if J<=2
                %                     plot(ampXshifted,bins,col);
                %                 else
                %                     plot(ampXshifted,bins,col,'linewidth',2);
                %                 end
                if J<=2
                    plot(ampX,bins,col);
                else
                    plot(ampX,bins,col,'linewidth',2);
                end
                
                if cFolder ~=1
                    xlim([-10 200]);
                else
                    xlim([-10 400]);
                end
                
                 col=colors{cNames};
                figure(cFolder+80);hold all;
                
                thresh = mean(t.cShortData)+1.5*std(t.cShortData);
                peakLoc=zeros(size(t.nShortData));
                peakLoc(t.cShortData>thresh) = 1;
                peakLoc=smooth(peakLoc,10);
                peakLoc(peakLoc>0)=1;
                dpl = diff(peakLoc);
                idx = find(dpl~=0);
                peakLoc(1:idx(1))=min(t.nShortData(1:idx(1))   );
                for I=2:length(idx)-1
                     peakLoc(idx(I):idx(I+1))=min(t.nShortData(idx(I):idx(I+1) )   );
                end
                data = t.nShortData - peakLoc';
                
                %data = t.nShortData(t.cShortData>thresh)-t.bottom;
                data = data(t.cShortData>thresh);
                flats2(1:length(data),ccFlats)=data;
                bData = hist(data,ampX);
                plot(ampX,bData/sum(bData),col);
                
                
                figure(cFolder+40);hold all;
               
                Y=t.widths(2:100:end);
                R=rand([1 length(Y)]);
                Y=Y+R*.8;
                scatter(  t.peakValues(2:100:end)-tBaseline,Y,3,col);
                xlim([-3 80]);
                ylim([10 600]);
                set(gca, 'YScale', 'log')
                
                %                 figure(cFolder+30);hold all;
                %                 if J<=2
                %                     plot(dAmpX,dbins,col);
                %                 else
                %                     plot(dAmpX,dbins,col,'linewidth',2);
                %                 end
                
                %                 figure(cFolder+40);hold all;
                %                 col=colors{cNames};
                %                 scatter(dTT(1:100:end),t.widths(2:100:end),3,col);
                %                 set(gca, 'YScale', 'log')
            end
            
        end
        ccFlats=ccFlats+1;
    end
    
    
%     filename = ['c:\temp\BaselineAligned_' curFolder{cFolder} '.csv'];
%     csvwrite(filename,flats);
%     
%     
%     filename = ['c:\temp\HighPeaks_' curFolder{cFolder} '.csv'];
%     csvwrite(filename,flats2);
    
    
    figure(cFolder+20);
    xlabel('Peak Height (pA)');
    ylabel('normalized frequency');
    
    %     figure(cFolder+30);
    %     xlabel('Peak Jump (pA)');
    %     ylabel('normalized frequency');
    %
    %     figure(cFolder+40);
    %     xlabel('Peak Jump (pA)');
    %     ylabel('Peak Width (pA)');
end