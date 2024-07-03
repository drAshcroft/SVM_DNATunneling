InitializeDLLs
clear pathnames;

%masterPath ='S:\Research\BrianAnalysis\Stacked Junctions\20140103_IBM_A_05_GACT_data_repeat\Files for Brian';
 masterPath ='S:\Research\BrianAnalysis\Stacked Junctions\20140123_IBM_A_05_RIE2_ACTG_data\For Brian analysis';
% masterPath ='S:\Research\BrianAnalysis\Stacked Junctions\20140204_IBM_A_05_RIE2_ATCG_repeat';
%masterPath ='S:\Research\BrianAnalysis\Stacked Junctions\20140225_IBM_A_27_RIE_ACTG\File_for_Brian';
masterPath ='S:\Research\BrianAnalysis\Stacked Junctions\20140303_IBM_A_17_RIE_ACTG\For Brian analysis';
% masterPath ='S:\Research\BrianAnalysis\Stacked Junctions\20140303_IBM_A_17_RIE_ACTG\For Brian analysis\02_dAMP_10nM_voltage_dependence';
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
%         if findstr(files(J).name,'Ref_100mV')
%             if findstr(files(J).name,'P380mV')
%                 if isempty(findstr(files(J).name,'100uM'))==false
                    tFiles{cc}=files(J).name;
                    cc=cc+1;
%                 end
%             end
%         end
    end
    
    idxs{I}=1:length(tFiles);
    UsedFiles{I}=tFiles;
end

colors={'k' 'r' 'g' 'b' 'y' 'm' 'r' 'k' 'c'  'm' 'r' 'c' 'r'};
colors={'k' 'g' 'y' 'b' 'r' 'm' 'r' 'k' 'c'  'm' 'r' 'c' 'r'};
colors={'b' 'k' 'k' 'k' 'c' 'y' 'r' 'k' 'c' 'y' 'r'};
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
for K=2:1:length(pathnames)
    pathname=pathnames{K};
    files = UsedFiles{K};
    idx=idxs{K};
    cc3=cc;
    
    Xm=[];
    longData=[];
    for J=1:length(files)
        fn=files{J};
        file= [pathname '\' fn]
        % loadedFiles{cc2}=file;
        % cc2=cc2+1;
        [shortData] = abfload(file,'start',0)';
        shortData= shortData(1,1:floor(length(shortData)/3));%1:5000);
        
        % shortData=shortData(2.2e6:2.55e6);
        % plot(shortData);
        bottom = zeros([1 floor(length(shortData)/1000)]);
        cc2=1;
        for M=1:1000:length(shortData)
            try
                bottom(cc2)=min(shortData(M:M+999));
                cc2=cc2+1;
            catch mex
            end
        end
        %                   X=(1:length(bottom))*1000;
        %                 f1=fit(X',bottom','poly1','Robust','Bisquare')
        %                 shortData = shortData - feval(f1,1:length(shortData))';%+ feval(f1,1);
        %
        X=(1:length(shortData))+cc;
        cc=cc+length(shortData);
        figure(1);
        skipSize=50;
%                 sD=shortData(1:5000);
%                 covar=6*std(sD);
%                 shortData = restore_image2(shortData',covar ,60,100, 1, 5);
%         
        if isempty(findstr(fn,'Rinse'))==false || (K==1) %#ok<FSTR>
            if (K==1)
                controlRinse=shortData;
            end
            rawRinseX=[rawRinseX X(floor(length(X)/2):end)];
            rawRinses=[rawRinses shortData(floor(length(shortData)/2):end)];
            
            FileRinsesRaw{K,J}=shortData;
            FileRinsesX{K,J}=X;
            
            %             output=WienerScalart96(vertcat(controlRinse', shortData'),100000,length(controlRinse)/(length(controlRinse)+length(shortData)));
            %             shortData = output(end-length(shortData)+1:end);
            sD=shortData(1:5000);
            covar=6*std(sD);
%             shortData = restore_image2(shortData',covar ,9,100, .8, 5)';
            
            FileRinses{K,J}=shortData;
            rinses=[rinses shortData(1:end)]; %#ok<AGROW>
            Xrinse=[Xrinse X]; %#ok<AGROW>
            plot(X(1:skipSize:end)/20000/60,shortData(1:skipSize:end),'k');
            hold all;
            drawnow;
        else
            plot(X(1:skipSize:end)/20000/60,shortData(1:skipSize:end),colors{K});
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
            
            %hold all;
            %             output=WienerScalart96(vertcat(controlRinse', shortData'),100000,length(controlRinse)/(length(controlRinse)+length(shortData)));
            %             shortData = output(end-length(shortData)+1:end);
            %
            sD=shortData(1:5000);
            covar=6*std(sD);
            shortData = restore_image2(shortData',covar ,9,100, .8, 5)';
            
            %             %             clf;
            %             plot(trace);
            %             hold all;
            % plot(shortData);
            
            %             w     = 9;       % bilateral filter half-width
            %             sigma = [25 0.1]; % bilateral filter standard deviations
            %
            %             f=zeros([length(shortData) 1 1]);
            mn=min(shortData)
            mx=max(shortData)
            % f(:,1,1) = (shortData-min(shortData))/(max(shortData)-min(shortData));
            %             bflt_img1 = bfilter2(f,w,sigma);
            %
            %             %             if K==2
            %             %                 [class, smoothData, levels]=ClassifyTraces(shortData,2);
            %             %             else
            %             %                 [class, smoothData, levels]=ClassifyTraces(shortData,2);
            %             %             end
            % %             fileData.bflt_img1=bflt_img1;
            % %             fileData.shortData=shortData;
           %             FileDatas2{K,J}=shortData;%FileDatas{K,J}*(mx-mn)+mn;
%            sD=shortData(1:5000);
%            covar=6*std(sD);
%            shortData = restore_image2(shortData',covar ,60,100, 1, 5);
%            
            FileDatas{K,J}=shortData(1:end);
            FileXs{K,J}=X;
            %             Xm=[Xm X];
            %             longData=[longData shortData];
        end
    end
  %  traces{K,1}=longData;
    
    ccPlot=ccPlot+1;
end

skipSize=200;
figure(2);clf;
% plot(Xrinse/20000/60,rinses,'b');
hold all;
for K=1:size(FileDatas,1)
    for J=1:size(FileDatas,2)
        
        shortData=FileRinsesRaw{K,J}';
        
        if isempty(shortData)==false
            x=  FileRinsesX{K,J};
            plot(x(1:skipSize:end)/20000/60,shortData(1:skipSize:end),'k');
        else
            shortData=Raws{K,J}';
            if isempty(shortData)==false
                x=  FileXs{K,J};
               % raw=Raws{K,J}';
                plot(x(1:skipSize:end)/20000/60,shortData(1:skipSize:end),colors{K});
               % shortData=shortData(1:skipSize:end);
            end
        end
    end
end

if exist('allSmoothed','var')==true
    for K=1:size(FileDatas,1)
        for J=1:size(FileDatas,2)
            shortData=FileRinsesRaw{K,J}';
            if isempty(shortData)==false
                x=  FileRinsesX{K,J};
                %plot(x(1:skipSize:end)/20000/60,shortData(1:skipSize:end),'k');
            else
                shortData=allSmoothed{K,J}'/255;
                if isempty(shortData)==false
                    x=  FileXs{K,J};
                    if length(x)>length(shortData)
                        x=x(1:length(shortData));
                    else
                        if length(shortData)>length(x)
                            shortData=shortData(1:length(x));
                        end
                    end
                    plot(x(1:skipSize:end)/20000/60,shortData(1:skipSize:end),'k');
                end
            end
        end
    end
end

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

% figure(2)
% clf
% 
% plot(Xrinse/20000,rinses,'b');
% hold all;
% colors={'k' 'm' 'c' 'r' 'k' 'm' 'c' 'r'  'k' 'm' 'c' 'r'};
% %colors={'r' 'k' 'm' 'c' 'k' 'm' 'c' 'r'  'k' 'm' 'c' 'r'};
% 
% 
% cc=1;
% for I=2:length(traces)
%     for J=1:3
%         shortData=FileDatas{I,J}';%    traces{I,1}(1:401:end);
%         %shortData =shortData(floor(end/2):floor(end/2)+500000);
%         x=(1:length(shortData))+cc;
%         cc=cc+length(x);
%         
%         figure(2)
%         plot(x/20000,shortData,colors{ 1+mod(I-2, length(colors))});
%         hold all;
%     end
% end
% 
% hold off;

% ccPlot=1;
% for I=1:size(obj_fits,1)
%     
%     for J =1:size(obj_fits,2)
%         fits=obj_fits{I,J};
%         if isempty(fits)==false
%             figure(ccPlot);
%             plot(fits.convergence);
%             ccPlot=ccPlot+1;
%         end
%     end
% end
% 
% 
% ccPlot=100;
% bins=1:30;
% for I=1:size(FileDatas,1)
%     for J=1:size(FileDatas,2)
%         
%         
%         FD=FileDatas{I,J};
%         if isempty(FD)==false
%             class=FD.class;
%             nClasses = max(class);
%             figure(ccPlot)
%             for K=1:nClasses
%                 idx=find(class==K);
%                 idx=find(  (abs(idx(1:end-1)-idx(2:end)) )~=1) ;
%                 idx=abs(idx(1:end-1)-idx(2:end));
%                 [v, bins]=hist(idx,1:150:5000);
%                 semilogy(bins/20000*1000,v+1);
%                 hold all;
%             end
%             hold off;
%             ccPlot=ccPlot+1;
%         end
%     end
%     
% end