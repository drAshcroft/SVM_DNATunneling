InitializeDLLs
clear pathnames;

masterPath ='S:\Research\BrianAnalysis\Stacked Junctions\20140103_IBM_A_05_GACT_data_repeat\Files for Brian';
%masterPath ='S:\Research\BrianAnalysis\Stacked Junctions\20140123_IBM_A_05_RIE2_ACTG_data\For Brian analysis';
%masterPath ='S:\Research\BrianAnalysis\Stacked Junctions\20140204_IBM_A_05_RIE2_ATCG_repeat';
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

%names={'Control','dGMP','dAMP','dCMP', 'dTMP','dAMP','dCMP','dTMP', 'dGMP'};
% pathnames{1} ='S:\Research\BrianAnalysis\Stacked Junctions\20131020_Stcked_Junction_data_for_Brian_SVM\Ion Milling Etch\2013_0929_IBM_R3_32';
% pathnames{2} = 'S:\Research\BrianAnalysis\Stacked Junctions\20131020_Stcked_Junction_data_for_Brian_SVM\Ion Milling Etch\2013_0929_IBM_R3_32\dAMP';
% pathnames{3} = 'S:\Research\BrianAnalysis\Stacked Junctions\20131020_Stcked_Junction_data_for_Brian_SVM\Ion Milling Etch\2013_0929_IBM_R3_32\dGMP';
% pathnames{4} = 'S:\Research\BrianAnalysis\Stacked Junctions\20131020_Stcked_Junction_data_for_Brian_SVM\Ion Milling Etch\20131006_IBM_R3_32_repeat';
% pathnames{5} = 'S:\Research\BrianAnalysis\Stacked Junctions\20131020_Stcked_Junction_data_for_Brian_SVM\Ion Milling Etch\20131006_IBM_R3_32_repeat\dAMP';
% pathnames{6} = 'S:\Research\BrianAnalysis\Stacked Junctions\20131020_Stcked_Junction_data_for_Brian_SVM\Ion Milling Etch\20131006_IBM_R3_32_repeat\dGMP';
% pathnames{7} = 'S:\Research\BrianAnalysis\Stacked Junctions\20131020_Stcked_Junction_data_for_Brian_SVM\Ion Milling Etch\20131009_IBM_D_18_not too much data';
% pathnames{8} = 'S:\Research\BrianAnalysis\Stacked Junctions\20131020_Stcked_Junction_data_for_Brian_SVM\Ion Milling Etch\20131009_IBM_D_18_not too much data\dAMP';
% pathnames{9} = 'S:\Research\BrianAnalysis\Stacked Junctions\20131020_Stcked_Junction_data_for_Brian_SVM\Ion Milling Etch\20131009_IBM_D_18_not too much data\dGMP';
% pathnames{10} = 'S:\Research\BrianAnalysis\Stacked Junctions\20131020_Stcked_Junction_data_for_Brian_SVM\Ion Milling Etch\20131020_IBM_D_25';
% pathnames{11} = 'S:\Research\BrianAnalysis\Stacked Junctions\20131020_Stcked_Junction_data_for_Brian_SVM\Ion Milling Etch\20131020_IBM_D_25\dAMP';
% pathnames{12} = 'S:\Research\BrianAnalysis\Stacked Junctions\20131020_Stcked_Junction_data_for_Brian_SVM\Ion Milling Etch\20131020_IBM_D_25\dGMP';
% pathnames{13} = 'S:\Research\BrianAnalysis\Stacked Junctions\20131020_Stcked_Junction_data_for_Brian_SVM\RIE_Etch\20130916_RIE etch';
% pathnames{14} = 'S:\Research\BrianAnalysis\Stacked Junctions\20131020_Stcked_Junction_data_for_Brian_SVM\RIE_Etch\20130916_RIE etch\dAMP';
% pathnames{15} = 'S:\Research\BrianAnalysis\Stacked Junctions\20131020_Stcked_Junction_data_for_Brian_SVM\RIE_Etch\20130916_RIE etch\dGMP';
% pathnames{16} = 'S:\Research\BrianAnalysis\Stacked Junctions\20131020_Stcked_Junction_data_for_Brian_SVM\RIE_Etch\20131024_D_04_RIE';
% pathnames{17} = 'S:\Research\BrianAnalysis\Stacked Junctions\20131020_Stcked_Junction_data_for_Brian_SVM\RIE_Etch\20131024_D_04_RIE\Step1_dGMP';
% pathnames{18} = 'S:\Research\BrianAnalysis\Stacked Junctions\20131020_Stcked_Junction_data_for_Brian_SVM\RIE_Etch\20131024_D_04_RIE\Step2_dAMP';
% pathnames{19} = 'S:\Research\BrianAnalysis\Stacked Junctions\20131020_Stcked_Junction_data_for_Brian_SVM\RIE_Etch\20131024_D_04_RIE\Step3_dGMP2';
%
% pathnames{1} ='S:\Research\Brian\From Pei\20130402\1mM_PB';
% pathnames{2} = 'S:\Research\Brian\From Pei\20130402\100uM_dAMP';
%
% pathnames{3} = 'S:\Research\Brian\From Pei\20120904\For Brian';
% pathnames{4} = 'S:\Research\Brian\From Pei\20120925\Imidazole_35hours\Add_1mM_PB_buffer';
% pathnames{5} = 'S:\Research\Brian\From Pei\20120925\Imidazole_35hours\Add_dGMP';


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
            if findstr(files(J).name,'400mV')
                tFiles{cc}=files(J).name;
                cc=cc+1;
            end
        end
    end
    
    idxs{I}=1:length(tFiles);
    UsedFiles{I}=tFiles;
end

cc=1;
loadedFiles ={};
cc2=1;
clf;
traces =cell([length(pathnames) 2]);
rinses =[];
Xrinse=[];
%FileDatas=cell([length(pathnames) 10]);

ccPlot=5;
ccPlot2=35;
obj_fits ={};
for K=1:1:length(pathnames)
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
        X=(1:length(bottom))*1000;
%                 f1=fit(X',bottom','poly1','Robust','Bisquare')
%                 shortData = shortData - feval(f1,1:length(shortData))';%+ feval(f1,1);
%         
%         %         X=(1:length(shortData))+cc;
        %         cc=cc+length(shortData);
        %         figure(1);
        %         plot(X(1:3:end)/20000*1000,shortData(1:3:end));
        %         hold all;
        %         drawnow;
        sD=shortData(1:5000);
        covar=6*std(sD);
        shortData = restore_image2(shortData',covar ,60,100, 1, 5);
        
        if isempty(findstr(fn,'Rinse'))==false || (K==1) %#ok<FSTR>
            rinses=[rinses  shortData]; %#ok<AGROW>
            Xrinse=[Xrinse X]; %#ok<AGROW>
            FileDatas{K,J}=shortData;
        else
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
            %hold all;
            %                         output=WienerScalart96(vertcat(rinses', shortData'),50000,length(rinses)/(length(shortData)));
            %                         shortData = output(end-length(shortData):end);
            %             clf;
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
            FileDatas{K,J}=shortData;
            
            %             Xm=[Xm X];
            %             longData=[longData shortData];
        end
    end
    traces{K,1}=longData;
    
    ccPlot=ccPlot+1;
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

figure(2)
clf

plot(Xrinse/20000,rinses,'b');
hold all;
colors={'k' 'm' 'c' 'r' 'k' 'm' 'c' 'r'  'k' 'm' 'c' 'r'};
%colors={'r' 'k' 'm' 'c' 'k' 'm' 'c' 'r'  'k' 'm' 'c' 'r'};


cc=1;
for I=2:2%length(traces)
    for J=1:3
        shortData=FileDatas{I,J}';%    traces{I,1}(1:401:end);
        %shortData =shortData(floor(end/2):floor(end/2)+500000);
        x=(1:length(shortData))+cc;
        cc=cc+length(x);
        
        figure(2)
        plot(x/20000,shortData,colors{ 1+mod(I-2, length(colors))});
        hold all;
    end
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