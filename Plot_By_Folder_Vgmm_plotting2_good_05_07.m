figure(10);clf;
figure(cFolder+20);clf;
figure(cFolder+30);clf;
figure(cFolder+40);clf;
figure(60+cFolder);clf;hold all;
figure(70+cFolder);clf;hold all;
figure(1);
template=[];
ampX=0:.5:800;
dAmpX = 0:.1:300;
ampXshifted=ampX;
for cNames =2:7
    col=colors{cNames};
    
    cData = byFolder(cNames,:);
    fTests=1;
    for J=1:length(cData)
        
        t=cData{J};
        if (isempty(t)==false)
            
            figure(1);clf;hold all;
            plot(t.shortData);
            plot(t.cShortData,'r');
            
            
            tt=t.peakValues*1;
            dTT= diff(t.peakValues);
            
            if (true)
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
                ttBaseline(1:end) = levels{mC}.m;% zeros(size(t.nShortData));
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
                            rcurPeaksDiff(ccRC) = abs( mean(seg)-median(ttBaseline(sI(K):eI(K))));
                            if sI(K)>1
                                rcurPeaksJ(ccRC)=abs(t.nShortData(sI(K)-1) - t.nShortData(sI(K)+1));
                            else
                                rcurPeaksJ(ccRC)=0;
                            end
                            ttBaseline(sI(K):eI(K))= rcurPeaksM(ccRC);%t.levels{I+1}.m; %
                            ccRC=ccRC+1;
                        end
                        ttBaseline(1:sI(1))=t.levels{I+1}.m;
                        ttBaseline(eI(end):length(ttBaseline))=t.levels{I+1}.m;
                    end
%                     plot(ttBaseline);
%                     drawnow;
                end
                
                col=colors{cNames};
                figure(60+cFolder);
                scatter(rcurPeaksM(1:10:end),rcurWidths(1:10:end),3,col);
                set(gca, 'YScale', 'log')
                
                figure(70+cFolder);
                scatter(rcurPeaksDiff(1:10:end),rcurWidths(1:10:end),3,col);
                set(gca, 'YScale', 'log')
            end
            %             tt=abs(tt(2:end)-tt(1:end-1));
            %             idx=find(tt<15);
            %             tt(idx)=[];
            
            for K=1:length(t.levels)
                if t.levels{K}.s~=0
                    %baseline  =t.levels{K}.m;
                    break;
                end
            end
            
            bins=hist(tt,ampX);
            bins(1)=0;
            bins=bins./sum(bins);
            
            dbins=hist(dTT,dAmpX);
            dbins(1)=0;
            dbins=dbins./sum(dbins);
            
            
            if J==1%isempty(template)
                %                 sD= t.shortData(1:50:end);
                %                 label=vbgm(sD',20);
                %                 mu=[];
                %                 for I=1:max(label)
                %                     mu(I)=mean(sD(label==I));
                %                 end
                %                 mu=sort(mu);
                baseline=0%mu(1);
                template = bins;
                tBaseline = baseline;
                ampXshifted=ampX;
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
            
            figure(cFolder+20);hold all;
            if J<=2
                plot(ampXshifted,bins,col);
            else
                plot(ampXshifted,bins,col,'linewidth',2);
            end
            
            figure(cFolder+30);hold all;
            if J<=2
                plot(dAmpX,dbins,col);
            else
                plot(dAmpX,dbins,col,'linewidth',2);
            end
            
            figure(cFolder+40);hold all;
            col=colors{cNames};
            scatter(dTT(1:100:end),t.widths(2:100:end),2,col);
        end
    end
end

figure(cFolder+20);
xlabel('Peak Height (pA)');
ylabel('normalized frequency');

figure(cFolder+30);
xlabel('Peak Jump (pA)');
ylabel('normalized frequency');

figure(cFolder+40);
xlabel('Peak Jump (pA)');
ylabel('Peak Width (pA)');