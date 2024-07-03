
foundVoltagesX=cell([1 500]);
skips=500;
figure(1);clf;
figure(2);clf;
figure(3);clf;
figure(4);clf;
figure(5);clf;
figure(6);clf;
figure(7);clf;
figure(8);clf;
figure(9);clf;

x=1;
for K=1:length(pathnames)
    foundVoltages=zeros([1 500]);
    cCol=1;
    
    pathname=pathnames{K};
    files = dir([pathname '\\*.abf']);
    dts={};
    for J=1:length(files)
        dts{J}=files(J).date;
    end
    
    [dts idx]=sort(dts);
    
    files=files(idx);
    
    
    noise=[];
    voltages=[];
    baselines=[];
    skew=[];
    platTimes=[];
    nPlats =[];
    spikes=[];
    for J=1:length(files)
        doPlot=false;
        isRinse=false;
        fn=lower(files(J).name);
        
        analyteName='';
        for I=1:length(names)
           if isempty(findstr(fn,lower(names{I})))==false
               analyteName=names{I};
               anaylteIndex=I;
               break;
           end
        end
        if isempty(findstr(fn,'ref_n100mv'))==false
            if isempty(findstr(fn,'p200mv'))==false
                if isempty(findstr(fn,'1um'))==false
                    doPlot=true;
                end
                
                if isempty(findstr(fn,'1mm'))==false
                    doPlot=true;
                end
                if isempty(findstr(fn,'rinse'))==false
                    doPlot=true;
                    isRinse=true;
                else
%                     anaylteIndex =str2num(fn(12:14))
%                     if foundVoltages(anaylteIndex)==0
%                         foundVoltages(anaylteIndex)=1;
%                     else
%                         doPlot=false;
%                     end
                end
            end
        end
         if isempty(findstr(fn,'rinse'))==false
                    doPlot=true;
                    isRinse=true;
         end
        
        if doPlot==true
            
            if isRinse==true
                if isempty(FileRinses{K,J})==false
                    shortData=FileRinses{K,J};
                else
                    shortData=FileDatas{K,J};
                end
            else
                shortData=FileDatas{K,J};
            end
            
            if isempty(shortData)==false
                Xs=[];% foundVoltagesX{voltage};
                if isempty(Xs)==false
                    if length(Xs)<length(shortData)
                        shortData=shortData(1:length(Xs));
                    else
                        if length(Xs)>length(shortData)
                            Xs=Xs(1:length(shortData));
                        end
                    end
                    % shortData=shortData-2000;
                    X=Xs;
                else
                    X=(1:length(shortData))+x;
                    foundVoltagesX{anaylteIndex}=X;
                end
                
                x=X(end);
                X=X/20000/60;
                
                figure(1);
                col=colors{mod(K,length(colors)+1)};
                cCol=cCol+1;
%                 if K==5
%                     offset=-2000;
%                 else
                    offset=0;
%                 end
                if isRinse==true
                    plot(X(10000:skips:end-10000),offset+shortData(10000:skips:end-10000),'b');
                    
                else
                    plot(X(10000:skips:end-10000),offset+shortData(10000:skips:end-10000),col);
                end
                hold all
                Y=mean(shortData)+1000+offset;
                if isRinse==true
                    text(X(1),Y, 'Rinse');%num2str(voltage));
                else
                    text(X(1),Y, analyteName);%num2str(voltage));
                end
                
                if isRinse==false
                    r=Raws{K,J}';
                    
                    if (length(shortData)<length(r))
                        r=r(1:length(shortData));
                    end
                    
                    figure(4)
                    plot(X(10000:skips:end-10000),offset+r(10000:skips:end-10000),col);
                    hold all;
                    plot(X(10000:skips:end-10000),offset+shortData(10000:skips:end-10000),'g');
                    
                    if isRinse==false
                        
                        [nPlat, nSpikesTime,platTime]=Times(r,shortData,400,2);
                        platTimes=[platTimes platTime];
                        nPlats=[nPlats nPlat];
                        spikes=[spikes nSpikesTime];
                        
                        baselines =[baselines min(shortData)];
                        r=r-shortData;
                        
                        noise =[noise std( r)];
                        voltages=[voltages anaylteIndex];
                        skew=[skew skewness(r)];
                    end
                    figure(3);
                    hold all;
                    plot(X(10000:skips:end-10000),offset+r(10000:skips:end-10000),col);
                    
                    clear r;
                end
                
                drawnow;
            end
            
        end
    end
    
    figure(2);
    scatter(voltages,noise,col,'fill');
    hold all;
    
    figure(5);
    scatter(voltages,baselines,col,'fill');
    hold all;
    
    figure(6);
    scatter(voltages,skew,col,'fill');
    hold all;
    
    figure(7);
    scatter(voltages,platTimes/20000*1000,col,'fill');
    hold all;
    
    figure(8);
    scatter(voltages,spikes,col,'fill');
    hold all;
    
     figure(9);
    scatter(voltages,nPlats,col,'fill');
    hold all;
end

figure(1);
xlabel('minutes');
ylabel('pA');

figure(3);
xlabel('minutes');
ylabel('pA');

figure(2);
xlabel('Analyte(mV)');
ylabel('pA');

figure(4);
xlabel('minutes');
ylabel('pA');

figure(5);
xlabel('Analyte');
ylabel('Baseline pA');

figure(6);
xlabel('Analyte');
ylabel('Skew pA');

figure(7);
xlabel('Analyte(mV)');
ylabel('plats ms');

figure(8);
xlabel('Analyte(mV)');
ylabel('spikes (#)');

figure(9);
xlabel('Analyte(mV)');
ylabel('nPlats (#)');