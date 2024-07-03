
 
      
      
% pathname = 'S:\Research\Brian\2013-12-19 angled Junction\1048 dgmp';
fn = '19Dec2013_006.tdms';
files = dir([pathname '\\*.tdms']);

longData =[];
for I=1:length(files)
    
    fn=files(I).name;
    [shortData] = readTDMS2([pathname '\\'], fn);%-.3707 ;%+ .3290;
    plot(shortData);
    longData=[longData shortData];%(1:100:end)];
    
end
%%controlData = longData(floor(end*3/4):end);

outsmooth=smooth(longData,631, 'moving')';
h=plot(outsmooth);
name = ['S:\Research\Brian\angledJunctionData\Trace_' fname '.jpg'];
saveas(h,name) 

d = diff(outsmooth);
d=smooth(d,631,'moving');

idx=find(d<2e-6);
mid = mean(outsmooth(idx));
outsmoothM = outsmooth - mid;

flats = outsmoothM(idx);

idxP=find(flats<0);
idxN=find(flats>0);

c = min([length(idxP) length(idxN)])-1;

idxP=idxP(1:c);
idxN=idxN(1:c);

idx2=[idx(idxP)' idx(idxN)'];
mid =mean( outsmooth(idx2));

sL=longData-mid;
plot(sL);

clear d;
clear outsmooth;
clear outsmoothM;
clear flats;
clear idx2;
clear idxN;
clear idxP;
clear ID;
clear lD;
clear ld;
clear output;
clear shortData;

fo = fitoptions('Method','NonlinearLeastSquares',...
               'Lower',     [0 , -40,   -1,  0,  -40],...
               'Upper',     [30,   0,    5, 30,    0],...
               'StartPoint',[1   -.1   0.5   0     0]);
ft = fittype('a*exp(b*x)+ c + d*exp(e*x)','options',fo);

offset =[];
rate =[];
flattened ={};
ccF=1;
s=sign(sL(1));
ccL=1;
for I=1:length(sL)
    if (sign(sL(I))~=s || I==length(sL))
       seg=abs(sL(ccL+800:I-1000));       
       [m idx]=max(seg);
       seg=seg(idx+25:end);
       idx = idx+25+ccL+800;
       if isempty(seg)==false
           if (length(seg)>125)
               
               r=max(seg)-min(seg);
               if (abs(r)<2)
                 
                   segF=(seg-mean(seg))';
                   f=mean(seg)*ones(size(seg));
               else
                   x=1/50000*(1:length(seg))';
                    
                   fo = fitoptions('Method','NonlinearLeastSquares',...
                       'Lower',     [0 ,                     -40,       -1,   -2,  -2,  -2, -.5, -.5],...
                       'Upper',     [30,                       0,        5,    2,   2,   2,  .5,  .5],...
                       'StartPoint',[max(seg)-seg(end)       -34    seg(end)  -1   .3    0   0   0]);
                   ft = fittype('a*exp(b*x)+ c + d*x + e*x^2 + f*x^3 + g*x^4 + h*x^5','options',fo);
                   if (length(seg)>17925519)
                       myFit=fit(x(1:1000:end),seg(1:1000:end)',ft);
                   else
                       myFit=fit(x,seg',ft);
                   end
                   
                   f=myFit.a*exp(myFit.b*x)+ myFit.c + myFit.d*x + myFit.e*x.^2 + myFit.f*x.^3 + myFit.g*x.^4+ myFit.h*x.^5;
                   
                   offset=[offset myFit.c];
                   rate=[rate myFit.b];
                   segF=seg'-f;
               end
               
               segF=segF(2000:end-100);
               plot(seg);
               hold all;
               plot(f);
               
               plot(segF);
               hold off;
               drawnow;
               
               flattened{ccF} = segF';
               ccF=ccF+1;
               j=1;
               clear f;
               clear x;
               clear seg;
               clear segF;
           end
       end
       ccL=I;
       s=sign(sL(I));
    end
end
% output=WienerScalart96(vertcat(controlData', flattened'),50000,length(controlData)/(length(flattened)+length(controlData) ));
% 
% output =output(length(controlData):end);
try
    clf;
    for I=1:length(flattened)-1
        seg=flattened{I};
        if length(seg)<length(controlData)
            cD = controlData(1:length(seg));
        else
            cD=controlData;
        end
        
        try
            output=WienerScalart96(vertcat(cD', seg'),50000,length(cD)/(length(seg)+length(cD) ));
            output =output(length(cD):end);
        catch mex
            output = seg;
        end
        
        plot(output(1:250:end));
        sFlattened{I}=output;
        hold all;
    end
    hold off;
catch mex
end



