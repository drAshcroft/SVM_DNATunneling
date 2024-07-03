
score1X=score1(:,I);
score1Y=score1(:,J);
score2X=score2(:,I);
score2Y=score2(:,J);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% do a little normalization
joinX= vertcat(score1X(:), score2X(:));
joinY= vertcat(score1Y(:), score2Y(:));

mX=median(joinX);
sX=7* median(abs(joinX-mX)); %(sum(abs(joinX-mX))/length(joinX));

mY=median(joinY);
sY=7* median(abs(joinY-mY));%(sum(abs(joinY-mY) )/length(joinY));

mnX= max([ mX-sX min(joinX)]);
mxX= min([ mX+sX max(joinX)]);

mnY= max([ mY-sY min(joinY)]);
mxY= min([ mY+sY max(joinY)]);

%finish the normalization
score1X=(score1X-mnX)/(mxX-mnX);
score2X=(score2X-mnX)/(mxX-mnX);

score1Y=(score1Y-mnY)/(mxY-mnY);
score2Y=(score2Y-mnY)/(mxY-mnY);

%put all the numbers into a pixel grid for plotting
sizeI=500;
ypred1 =zeros([sizeI,sizeI]);
ypred2 =zeros([sizeI,sizeI]);

idxX=round(score1X*sizeI);
idxY=round(score1Y*sizeI);
idxX(idxX>sizeI)=sizeI;
idxY(idxY>sizeI)=sizeI;
idxX(idxX<1)=sizeI;
idxY(idxY<1)=sizeI;

pCount =0;
for K=1:length(idxX)
    if idxX(K)~=sizeI && idxY(K)~=sizeI
        ypred1(idxX(K),idxY(K))=ypred1(idxX(K),idxY(K))+1;
        pCount=pCount+1;
    end
end

idxX=round(score2X*sizeI);
idxY=round(score2Y*sizeI);
idxX(idxX>sizeI)=sizeI;
idxY(idxY>sizeI)=sizeI;
idxX(idxX<1)=sizeI;
idxY(idxY<1)=sizeI;

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
h = fspecial('gaussian', 111, 5);
ypred1=imfilter(ypred1,h);
ypred2=imfilter(ypred2,h);


ypred1=1000*ypred1/(sum(ypred1(:)));
ypred2=1000*ypred2/(sum(ypred2(:)));

im=zeros([size(ypred1,1) size(ypred1,2) 3]);
im(:,:,1)=ypred1;
im(:,:,2)=ypred2;
imM=max(im,[],3);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% now calculate the probability by finding which one is the
% max, and dividing by the sum of the two

denom= (ypred1+ypred2);
accurMap = ( imM );
totalAccur=sum( accurMap(:) ) / sum(denom(:)) *100
drawnow;

if (totalAccur>65)
    %normalize the values from 0 to 255, and do the square root
    %for visibility
    ypred1=  (ypred1-min(ypred1(:)) ).^.5;
    ypred1=round(  (ypred1/(max(ypred1(:))))*254);
    %
    ypred2= ( ypred2-min(ypred2(:))  ).^.5;
    ypred2=round( (ypred2/(max(ypred2(:))))*254);
    %
    
    % make a nice image
    im=uint8(zeros([size(ypred1,1) size(ypred1,2) 3]));
    im(:,:,1)=round(ypred1);
    im(:,:,2)=round(ypred2);
    
    imshow(im);
    %title([colNames{selected(I)} ' '  colNames{selected(J)}]);
    drawnow;
    
    %     saveas(1,[ saveDir '\A' num2str(round(totalAccur)) '_' ...
    %         colNames{selected(I)} '-'  colNames{selected(J)} '-' ...
    %         num2str(I) '_' num2str(J) '_' num2str(pCount) '_' ...
    %         analytePair '.png']);
    disp('=====');
    saveas(1,['c:\temp\AT2\fig_' num2str(I) '_' num2str(J) '_'  num2str(K) '.jpg']);
    
end
