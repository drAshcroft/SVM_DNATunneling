InitializeDLLs
clear pathnames;

%masterPath ='S:\Research\BrianAnalysis\Stacked Junctions\20140103_IBM_A_05_GACT_data_repeat\Files for Brian';
%masterPath ='S:\Research\BrianAnalysis\Stacked Junctions\20140123_IBM_A_05_RIE2_ACTG_data\For Brian analysis';
masterPath ='S:\Research\BrianAnalysis\Stacked Junctions\20140204_IBM_A_05_RIE2_ATCG_repeat';
folders = dir(masterPath);

cc=1;
for I=3:length(folders)
    
    if (folders(I).isdir==true)
        pathnames{cc}=[masterPath '\' folders(I).name];
        cc=cc+1;
    end
end
% pathnames={};
%names={'Control','dAMP','dCMP','dTMP', 'dGMP','dAMP','dCMP','dTMP', 'dGMP'};
names={'Control','dAMP','dTMP','dCMP', 'dGMP'};

longData =[];
lI = [];

UsedFiles={};
for I=1:length(pathnames)
    pathname=pathnames{I};
    files = dir([pathname '\\*.abf']);
    tFiles={};
    cc=1;
    for J=1:length(files)
        if findstr(files(J).name,'Ref_N100mV')
            % if findstr(files(J).name,'400mV')
            tFiles{cc}=files(J).name;
            cc=cc+1;
            % end
        end
    end
    
    idxs{I}=1:length(tFiles);
    UsedFiles{I}=tFiles;
end

cc=1;
loadedFiles ={};
cc2=1;
clf;
traces ={};
%rinses =[];
Xrinse=[];
%FileDatas=[];

ccPlot=5;
ccPlot2=35;
obj_fits ={};
%shorts=[];
for K=1:2%length(pathnames)
    pathname=pathnames{K};
    files = UsedFiles{K};
    idx=idxs{K};
    cc3=cc;
    
    Xm=[];
    longData=[];
    m=min([length(files) 9]);
    for J=1:m
        fn=files{J};
        file= [pathname '\' fn]
        loadedFiles{cc2}=file;
        cc2=cc2+1;
        [shortData] = abfload(file,'start',0)';
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
%         X=(1:length(bottom))*1000;
%         f1=fit(X',bottom','poly1','Robust','Bisquare')
%         shortData = shortData - feval(f1,1:length(shortData))'+ feval(f1,1);
%         
%         
%         bottom = zeros([1 floor(length(shortData)/1000)]);
%         cc2=1;
%         for M=1:1000:length(shortData)
%             try
%                 bottom(cc2)=min(shortData(M:M+999));
%                 cc2=cc2+1;
%             catch mex
%             end
%         end
%         BaselineA(5,J)=mean(bottom);
        
        %
        X=(1:length(shortData))+cc;
        cc=cc+length(shortData);
        figure(1);
        plot(X(1:300:end)/20000/60,shortData(1:300:end));
        hold all;
        drawnow;
        
        sD=shortData(1:5000);
        covar=6*std(sD);
      %  shortData = restore_image2(shortData',covar ,60,100, 1, 5);
        
        if isempty(findstr(fn,'Rinse'))==false || (K==1) %#ok<FSTR>
          
           cBaselineA(1) = mean(shortData);
           cBaselineA(2)=mode(shortData);
           cBaselineA(3)=min(shortData);
           
           smth = mean(shortData);
           smth=mean(shortData(shortData<smth));
           smth=mean(shortData(shortData<smth));
           cBaselineA(4)=smth;%2*std(shortData(1:3000))+ mean(shortData(shortData< min(shortData)+2*std(shortData(1:3000))));
           
           rinses=[rinses  shortData]; %#ok<AGROW>
           Xrinse=[Xrinse X]; %#ok<AGROW>
        else
            %                                     output=WienerScalart96(vertcat(rinses', shortData'),50000,length(rinses)/(length(shortData)));
            %                                     shortData = output(end-length(shortData)+1:end)';
            % %              shortData=shortData(1:30000);
%             w     = 9;       % bilateral filter half-width
%             sigma = [25 0.1]; % bilateral filter standard deviations
%             
%             f=zeros([length(shortData) 1 1]);
%             mn = min(shortData);
%             mx=max(shortData);
%             f(:,1,1) = (shortData-mn)/(mx-mn);
%             shortData = bfilter2(f,w,sigma);
%             shortData=shortData*(mx-mn)+mn;
            
            BaselineA(1,J) = mean(shortData);
            BaselineA(2,J) = mode(shortData);
            BaselineA(3,J) = min(shortData);
            
            smth = mean(shortData);
            smth=mean(shortData(shortData<smth));
            smth=mean(shortData(shortData<smth));
%             smth=mean smooth(shortData,80)';
%             sDD= shortData(1:length(smth));
%             BaselineA(4,J) =mean(sDD(sDD<smth));
            %std(shortData(1:3000))+ mean(shortData(shortData< min(shortData)+1.5*std(shortData(1:3000))));
            BaselineA(4,J)=smth;
            

            shorts{J}=shortData;
            figure(2)
            hold all;
            X=(1:length(shortData))+cc;
            plot(X(1:3:end)/20000*1000,shortData(1:3:end));
            
            
            Xm=[Xm X];
            %            longData=[longData shortData];
        end
    end
    %  traces{K,1}=longData;
    
    if (K==2)
        
%         w     = 9;       % bilateral filter half-width
%         sigma = [25 0.1]; % bilateral filter standard deviations
%         
%         f=zeros([length(controlRinse) 1 1]);
%         mn = min(controlRinse);
%         mx=max(controlRinse);
%         f(:,1,1) = (controlRinse-mn)/(mx-mn);
%         controlRinse = bfilter2(f,w,sigma);
%         controlRinse=controlRinse*(mx-mn)+mn;
%         
%         disp('hello');
    end
    %   traces{K,2}=Xm;
    ccPlot=ccPlot+1;
end


figure(3);
plot(BaselineA(:,1:7));
%
%
% figure(1)
% clf;
%
% K=2;
% t=traces{K,1};
% x=traces{K,2};
% n=3;
% class=kmeans(t,n);
%
% for I=1:n
%     idx1=find(class==I);
%     X=x(idx1);
%     T=t(idx1);
%     plot(X,T);
%     hold all;
% end
% hold off;

figure(2)
clf

X=(1:length(rinses));
cc=length(X);
plot(X/20000,rinses,'b');

hold all;
colors={'k' 'm' 'c' 'r' 'k' 'm' 'c' 'r'  'k' 'm' 'c' 'r'};
%colors={'r' 'k' 'm' 'c' 'k' 'm' 'c' 'r'  'k' 'm' 'c' 'r'};



for I=2:length(shorts)
    
    shortData=shorts{I};
    X=(1:length(shortData))+cc;
    cc=cc+length(X);
    figure(2)
    plot(X/20000,shortData,colors{ 1+mod(I-2, length(colors))});
    hold all;
end

hold off;

ccPlot=1;
for I=1:size(obj_fits,1)
    
    for J =1:size(obj_fits,2)
        fits=obj_fits{I,J};
        if isempty(fits)==false
            figure(ccPlot);
            plot(fits.convergence);
            ccPlot=ccPlot+1;
        end
    end
end


ccPlot=100;
bins=1:30;
for I=1:size(FileDatas,1)
    for J=1:size(FileDatas,2)
        
        
        FD=FileDatas{I,J};
        if isempty(FD)==false
            class=FD.class;
            nClasses = max(class);
            figure(ccPlot)
            for K=1:nClasses
                idx=find(class==K);
                idx=find(  (abs(idx(1:end-1)-idx(2:end)) )~=1) ;
                idx=abs(idx(1:end-1)-idx(2:end));
                [v, bins]=hist(idx,1:150:5000);
                semilogy(bins/20000*1000,v+1);
                hold all;
            end
            hold off;
            ccPlot=ccPlot+1;
        end
    end
    
end