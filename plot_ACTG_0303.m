
voltColors{260}='k';
voltColors{280}='r';
voltColors{300}='b';
voltColors{320}='g';
voltColors{330}='y';
voltColors{350}='m';
voltColors{380}='c';
voltColors{400}='k';



concentrationColors = {'k' 'c' 'y' 'r' 'g' 'm' 'c' 'k'};
colors={'b' 'k' 'k' 'k' 'k' 'k' 'k' 'c' 'y'  'r' 'k' 'c' 'y' 'r'};
col='b';
foundVoltagesX=cell([1 500]);
skips=1;

analyteMode=1;
voltageMode=2;
concentrationMode =3;

plotMode =analyteMode;


figure(1);clf;
figure(2);clf;
figure(3);clf;
figure(4);clf;
figure(5);clf;
figure(6);clf;
figure(7);clf;
figure(8);clf;
figure(9);clf;


ampHistX=1:5:800;
ampHist=cell([1  length(pathnames)]);

x=1;
for K=1:min([ size(FileDatas,1) length(pathnames)])
    foundVoltages=zeros([1 500]);
    cCol=1;
    concentration='';
    concColor='b';
    pathname=pathnames{K};
    files = dir([pathname '\\*.abf']);
    dts={};
    for J=1:length(files)
        dts{J}=files(J).date;
    end
    
    [dts idx]=sort(dts);
    
    files=files(idx);
    
    
    noise=[];
    analyteIndexs=[];
    baselines=[];
    skew=[];
    platTimes=[];
    nPlats =[];
    spikes=[];
    for J=1:length(files)
        voltage=400;
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
           if isempty(findstr(fn,'p380mv'))==false || (plotMode==voltageMode)
               
               
               if isempty(findstr(fn,'1um'))==false
                   doPlot=true;
                   concentration = '1um';
                   concColor=concentrationColors{3};
               end
               
               if plotMode==concentrationMode
                   
                   if isempty(findstr(fn,'10nm'))==false
                       doPlot=true;
                       concentration = '10nm';
                       concColor=concentrationColors{1};
                   end
                   
                   if isempty(findstr(fn,'10um'))==false
                       doPlot=true;
                       concentration = '10um';
                       concColor=concentrationColors{2};
                   end
                   if isempty(findstr(fn,'100um'))==false
                       doPlot=true;
                       concentration = '100um';
                       concColor=concentrationColors{4};
                   end
                   
                   if isempty(findstr(fn,'1mm'))==false
                       doPlot=true;
                       concentration = '1mm';
                       concColor=concentrationColors{5};
                   end
               end
               
               if doPlot
                    voltage = str2num( fn(12:14));
               end
               
                
                
                
%                 if isempty(findstr(fn,'p300mv'))==false
%                     doPlot=false;
%                 end
%                 if isempty(findstr(fn,'p380mv'))==false
%                     doPlot=false;
%                 end

                %                 if isempty(findstr(fn,'1mm'))==false
                %                     doPlot=true;
                %                 end
                if isempty(findstr(fn,'rinse'))==false
                    doPlot=true;
                    isRinse=true;
                else
                    
                end
            end
        end
        if isempty(findstr(fn,'rinse'))==false
                    doPlot=true;
                    isRinse=true;
         end
         
         if K==1
             isRinse=true;
             doPlot=true;
         end
        
        if doPlot==true
            fprintf([fn '\n\n']);
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
              %   shortData=shortData(1:300000);
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
                if plotMode==analyteMode
                    col=colors{mod(K,length(colors)+1)};
                else
                    if plotMode==voltageMode
                        col=voltColors{voltage};
                    else
                        if plotMode==concentrationMode
                            col=concColor;
                        end
                    end
                end
                
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
                Y=mean(shortData)+200+offset;
                
               
                if isRinse==true
                    text(X(1),Y, [ num2str(voltage) ' ' concentration ' Rinse']);%num2str(voltage));
                else
                    if plotMode==analyteMode
                        text(X(1),Y,  analyteName);%
                    else
                        if plotMode==voltageMode
                            text(X(1),Y, [ num2str(voltage) ]);%
                        else
                            if plotMode==concentrationMode
                                text(X(1),Y, [  concentration ]);%
                            end
                        end
                    end
                    %text(X(1),Y, [ num2str(voltage) ' ' concentration ' ' analyteName]);%
                end
                
                if isRinse==false
                    r=Raws{K,J}';
                    
                    if size(r)~=size(shortData)
                        shortData=shortData';
                    end
                    
                    if (length(shortData)<length(r))
                        r=r(1:length(shortData));
                    end
                    if length(shortData)~=length(r)
                        disp('what');
                    end
                    
                    if isempty(ampHist{K})
                        ampHist{K}=hist(shortData,ampHistX);
                    else
                        ampHist{K}=ampHist{K}+hist(shortData,ampHistX);
                    end
%                     figure(4)
%                     plot(X(10000:skips:end-10000),offset+r(10000:skips:end-10000),col);
%                     hold all;
%                     plot(X(10000:skips:end-10000),offset+shortData(10000:skips:end-10000),'g');
%                     
                    if isRinse==false
                        
                        [nPlat, nSpikesTime,platTime]=Times(r,shortData,400,2);
                        platTimes=[platTimes platTime];
                        nPlats=[nPlats nPlat];
                        spikes=[spikes nSpikesTime];
                        
                        baselines =[baselines min(shortData)];
                        r=r-shortData;
                        
                        noise =[noise std( r)];
                        analyteIndexs=[analyteIndexs anaylteIndex];
                        skew=[skew skewness(r)];
                    end
%                     figure(3);
%                     hold all;
%                     plot(X(10000:skips:end-10000),offset+r(10000:skips:end-10000),col);
%                     
                    clear r;
                end
                
                drawnow;
            end
            
        end
    end
    
    figure(2);
    scatter(analyteIndexs,noise,col,'fill');
    hold all;
    
    figure(5);
    scatter(analyteIndexs,baselines,col,'fill');
    hold all;
    
    figure(6);
    scatter(analyteIndexs,skew,col,'fill');
    hold all;
    
    figure(7);
    scatter(analyteIndexs,platTimes/20000*1000,col,'fill');
    hold all;
    
    figure(8);
    scatter(analyteIndexs,spikes,col,'fill');
    hold all;
    
     figure(9);
    scatter(analyteIndexs,nPlats,col,'fill');
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

figure(10);clf
for I=1:length(ampHist)
    I
    b=ampHist{I};
    if isempty(ampHist{I})==false
        col=colors{mod(I,length(colors)+1)};
       % b=b/sum(b);
        semilogy(ampHistX,b,col);
        hold all;
    end
end