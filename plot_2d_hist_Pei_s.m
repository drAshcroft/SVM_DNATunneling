Fnames = {'Wave_1','Wave_2','Wave_3','Wave_4','Wave_5','Wave_6','Wave_7','Wave_8','Wave_9','Wave_10','Wave_11','Wave_12','Wave_13','Wave_14','Wave_15','Wave_16','Wave_17','Wave_18' ...
    ,'Wave_19','Wave_20','Wave_21','Wave_22','Wave_23','Wave_24','Wave_25','Amplitude'};
% for I=2:length(features)
%     f=features{1,I}.features;
%     f=vertcat(f,features{I}.pks);
%     features{I}.features=f;
% end
saveDir='C:\Data\PeisHist5';
try
 mkdir(saveDir);
catch mex
end

I=2;
sizeI=150;
for J=1:size(features{2}.features,1)
    for M=J+1:size(features{2}.features,1)
        
        
        for I=1:3%length(features)
            layer = mod( I-1,4);
            
%             if layer==3
%                 layer=2;
%             else
%                 if layer ==2
%                     layer =3;
%                 end
%             end
% if layer ==2
%     layer =1;
% else
%     if layer ==3
%         layer =2;
%     else
%         if layer ==4
%             layer =4;
%         else
%             if layer ==1
%                 layer =3;
%             end
%         end
%     end
% end
            
            pks=features{I}.pks;
            pks0=zeros(size(pks))+1;
            if M~=26
                %pks=features{I}.pks;
               
                pks=log(abs(features{I}.features(M,:)./pks0));
            else
                %pks=pks.^.5;
            end
            
            d=log(abs(features{I}.features(J,:)./pks0));
            % d=log(d);
            if  I==1
                [v, bins]=hist(d,45);
                dx=bins(2)-bins(1);
                bins=[ (dx*(-10:-1) + bins(1)) bins (dx*(1:10) + bins(end))];
                
                [v, bins2]=hist(pks,45);
                dx=bins2(2)-bins2(1);
                bins2=[ (dx*(-10:-1) + bins2(1)) bins2 (dx*(1:10) + bins2(end))];
                
                % d=bins(2)-bins(1);
                % bins=[ (d*(-100:-1) + bins(1)) bins (d*(1:100) + bins(end))];
                
                
                
                mX= bins2(1);
                MX =bins2(end);
                lX=(MX-mX);
                
                mY= bins(1);
                MY =bins(end);
                lY=(MY-mY);
                
            end
            ypred2=zeros([sizeI sizeI ]);
            V2x = (pks-mX)/lX;
            V2y = (d-mY)/lY;
            
            
            idxX=round(V2x*sizeI);
            idxY=round(V2y*sizeI);
            idxX(idxX>sizeI)=sizeI;
            idxY(idxY>sizeI)=sizeI;
            idxX(idxX<1)=sizeI;
            idxY(idxY<1)=sizeI;
            idx=find(isnan(idxX));
            idxX(idx)=sizeI;
            idx=find(isnan(idxY));
            idxY(idx)=sizeI;
            pCount=0;
            for K=1:length(idxX)
                if idxX(K)~=sizeI && idxY(K)~=sizeI
                    ypred2(idxX(K),idxY(K))=ypred2(idxX(K),idxY(K))+1;
                    pCount=pCount+1;
                end
            end
            
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % now take the matrix and blur the values to give it a little
            % bit of a histogram feel (the same effect can be produced by
            % just reducing the number of pixels on the image)
            h = fspecial('gaussian', 111, 3);
            ypred2=imfilter(ypred2,h);
            ypred2=1000*ypred2/(sum(ypred2(:)));
            
            %         im=zeros([size(ypred2,1) size(ypred2,2) 3]);
            %         im(:,:,2)=ypred2;
            
            ypred2= ( ypred2-min(ypred2(:))  ).^.5;
            ypred2=round( (ypred2/(max(ypred2(:))))*(235));
            %
            
            % make a nice image
            if layer<4
                if I==1 || I==5
                    im=uint8(zeros([size(ypred2,1) size(ypred2,2) 3]));
                end
                
                if layer==3
                    im(:,:,1)=squeeze(im(:,:,1)) + uint8(round(ypred2));
                    im(:,:,2)=squeeze(im(:,:,2)) + uint8(round(ypred2));
                else
                    im(:,:,layer+1)=squeeze(im(:,:,layer+1)) + uint8(round(ypred2));
                end
                
                if I<5
                    figure(1);
                    
                    imshow(im);
                    title([Fnames{J} ' '  Fnames{M} ' Cycle 1']);
                    imLast = im(:,:,:);
                else
                    figure(2);
                    imshow(im);
                    title([Fnames{J} ' '  Fnames{M} ' Cycle 2']);
                    
                    figure(3);
                    error =abs(imLast-im); 
                    imshow(error);
                    title([Fnames{J} ' '  Fnames{M} ' Error 1']);
                    
                    error=floor(sum(error(:))/sum(imLast(:))*100);
                    drawnow;
                    
                end
            end
        end
        
        
        saveas(1,[ saveDir '\_' Fnames{M}  '_'  Fnames{J} '_Cycle_1.png']);
%         saveas(2,[ saveDir '\_' Fnames{M}  '_'  Fnames{J} '_Cycle_2.png']);
%         saveas(3,[ saveDir '\_' Fnames{M}  '_'  Fnames{J} '_Error_' num2str(error) '.png']);
        
        
        
    end
end