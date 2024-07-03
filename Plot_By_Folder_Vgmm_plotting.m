figure(10);clf;
  figure(cFolder+20);clf;
template=[];
ampX=0:.5:800;
ampXshifted=ampX;
for cNames =2:4
    col=colors{cNames};
    
    cData = byFolder(cNames,:);
    fTests=1;
    for J=1:length(cData)
        
        t=cData{J};
        if (isempty(t)==false)
            
            figure(1);
            plot(t.nShortData);
            tt=t.peakValues*1;%scaleFactor(K);
            
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
            
            if J==1%isempty(template)
%                                 sD= t.shortData(1:50:end);
%                                 label=vbgm(sD',20);
%                                 mu=[];
%                                 for I=1:max(label)
%                                     mu(I)=mean(sD(label==I));
%                                 end
%                                 mu=sort(mu);
                baseline=0;%mu(1);
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
        end
    end
end
xlabel('Peak Height (pA)');
ylabel('normalized frequency');

