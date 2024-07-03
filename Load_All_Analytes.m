InitializeDLLs
clear pathnames;

masterPath ='S:\Research\BrianAnalysis\Stacked Junctions';
 
for cNames =2:5
    names={'Control','dAMP','dCMP','dTMP', 'dGMP'};
    colors={'k' 'r' 'g' 'b' 'y' 'm' 'r' 'k' 'c'  'm' 'r' 'c' 'r'};
    
    files= FindAllAnalytes('S:\Research\BrianAnalysis\Stacked Junctions',{'1nm','10nm'},names{cNames},'p380mv','ref_n100mv');
    
    figure(2);clf;
    figure(1);clf;
    figure(10);clf;
    cc=1;
    cc2=1;
    ccShort=1;
   
    for J=1:length(files)
        pathname=files{J}.path;
        fn=files{J}.name;
        file= [pathname '\' fn];
        
        [shortData] = abfload(file,'start',0)';
        shortData= shortData(1,1:floor(length(shortData)/1));%1:5000);
        
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
        X=((1:length(shortData))+cc)/20000/60;
        cc=cc+length(shortData);
        figure(1);
        skipSize=1;
        
        %
        if isempty(findstr(fn,'Rinse'))==false %#ok<FSTR>
            rinses=[rinses shortData(1:end)]; %#ok<AGROW>
            Xrinse=[Xrinse X]; %#ok<AGROW>
            plot(X(1:skipSize:end),shortData(1:skipSize:end),'k');
            hold all;
            drawnow;
        else
            plot(X(1:skipSize:end),shortData(1:skipSize:end));
            hold all;
            text(X(1),0, files{J}.conc);
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
            
            
            m=mode(shortData);
            figure(10);
            plot(bins-m,v);
            hold all;
            
            
            sD=shortData(1:5000);
            covar=std(sD);
            pData = restore_image2(shortData',covar ,21,100, .8, 5)';
            
            p=['c:\temp' pathname(3:end)];
            
            if(isdir(p)==0)
                mkdir(p)      %Creates folder containing the plots
            end
            
            save([p '\'  fn '.mat'],'shortData','pData');
            
            figure(2);
            l=length(shortData);
            shortData=shortData( floor(l*.25):floor(l*.35))-m;
            
            X=((1:length(shortData))+ccShort)/20000/60;
            ccShort=ccShort+length(shortData);

            plot(X,shortData);
            hold all;
            text(X(1),-50, files{J}.conc);
            drawnow;
            
            
            
        end
    end
    
    
end
