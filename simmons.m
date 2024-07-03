
clear x;
fire_openAir =['C:\Data\diagonalJunction053014\open.csv'];  %leave blank if you do not want to try to remove the parasitic resistance.
file= ['C:\Data\diagonalJunction053014\diagonalJunction_5_30_14.csv'];

gapSize=1; %nm
potentialGap=4; %eV
junctionArea=.1e-3*1e-9;% 100^2;%( (.1e-3)*(1e-3));
junctionAirArea=1;% ((.25)*(.25))/(100^2);%m^2
E=9.1;

opts = statset('nlinfit');
opts.RobustWgtFun = 'bisquare';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if isempty(fire_openAir) ==true
    pAir=[0 0];
else
    fid = fopen(fire_openAir,'r');
    InputText=textscan(fid,'%s',7,'delimiter','\n');
    C_data0 = textscan(fid,'%f, %f, %f, %f, %f, %f,');
    fclose(fid);
    V =C_data0{6};
    I = C_data0{3} ;
    I=I-mean(I);
    
    voltageLimit =.9*max(V);
    
    
    idx=find(abs(V)<voltageLimit);
    V=V(idx);
    I=I(idx);
    
    p=polyfit(V,I,4);
    
    upper=[];
    lower=[];
    
    for J=1:length(I)
        
        i=polyval(p,V(J));
        if I(J)>i
            upper=[upper J];
        else
            lower =[lower J];
        end
    end
    
    Vu=V(upper);
    Vl=V(lower);
    
    Iu=I(upper);
    Iu=Iu-mean(Iu);
    Il=I(lower);
    Il=Il-mean(Il);
    
    figure(1);
    I=(vertcat(Il,Iu));
    V=vertcat(Vl,Vu);
    
    Iair=I(:);
    Vair=V(:);
    
    
    I=I/junctionAirArea;
    scatter(V,I);
    
    hold all;
    
    pAir=polyfit(V,I,1);
    pAir(2)=0;
    I=polyval(pAir,V);
    scatter(V,I);
    hold off;
    title('air fitting');
    
    
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fid = fopen(file,'r');
  InputText=textscan(fid,'%s',7,'delimiter','\n');
    C_data0 = textscan(fid,'%f, %f, %f, %f, %f, %f,');
    fclose(fid);
    V =C_data0{6};
    I = C_data0{3} ;
    I=I-mean(I);
    
    figure(2);
plot(V,I*10e9);
xlabel('Voltage (V)');
ylabel('Current (pA)');
voltageLimit =.9*max(V);

idx=find(abs(V)<voltageLimit);
V=V(idx);
I=I(idx);

p=polyfit(V,I,4);

upper=[];
lower=[];

for J=1:length(I)

    i=polyval(p,V(J));
    if I(J)>i
        upper=[upper J];
    else
        lower =[lower J];
    end
end

Vu=V(upper);
Vl=V(lower);

Iu=I(upper);
Iu=Iu-mean(Iu);
Il=I(lower);
Il=Il-mean(Il);
   
  
    I=(vertcat(Il,Iu));
    V=vertcat(Vl,Vu);
% 

% Ia=abs(I);
% idx=find(Ia<.15);
% Ia=Ia(idx);
% Va=V(idx);
% 
% idx=find(Ia>.08);
% Ia=Ia(idx);
% Va=Va(idx);
% negV=mean( Va(Va<0));
% posV=mean(Va(Va>0));
% center = (negV+posV)/2;
% 
% V=V-center;
% p=polyfit(V,I,8);
% I=I-polyval(p,0);

figure(2);
plot(V,I);

%  idx=find(abs(V)<.0001);
%  I=I-I(119);% floor(mean(idx)));
% V=vertcat(Vl,Vu);
Ic=(I./junctionArea);

if exist('Vair','var')==true
    figure(4);
    clf;
    scatter(V,I);
    hold all;
    scatter(Vair,Iair);
    hold off;
    title('Data vs Air');
    
    
    figure(2);
    I=I-polyval(pAir,V);
    scatter(V,I);
    title('Data after removal of air resistance');
    
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%fitting to simmons

x(1)=gapSize;
x(2)=potentialGap;
x(3)=10;
x(4)=1;
x(5)=1;
% x(6)=0;


x0=x(:);

lb(1)=1;
lb(2)=1;
lb(3)=8;
lb(4)=.8;
lb(5)=.8;
% lb(6)=-.01;


ub(1)=6;
ub(2)=6;
ub(3)=11;
ub(4)=1.1;
ub(5)=1.1;
% lb(6)=.01;



Vu=V(floor(length(V)*.55-4):floor(length(V)*.85+2));
Icu=(Ic(floor(length(Ic)*.55-4):floor(length(Ic)*.85+2)));

fits={};
cFits=1;
for J=1:5
    
    
    figure(3);
    clf;
    
    semilogy(V,abs(Ic));
    hold all;
    
    I2=simmonsFormula(x,V);
    semilogy(V,abs(I2));
    
    % for I=1:24
    x=nlinfit(Vu,Icu,@simmonsFormula,x,opts);
    x=abs(x);
    x = lsqcurvefit(@simmonsFormula,x,Vu,Icu,lb,ub);
    % end
    
    I3=(simmonsFormula(x,Vu));
    semilogy(Vu,abs(I3));
    
    hold off;
    
    title('Fit to simmon''s formula');
    drawnow;
    
    fprintf(' gap is %s (nm)\n potential is %s (eV)\n permittivity is %d \n alpha is %s \n beta is %s \n',x);
    
    fits{cFits}=x;
    cFits=cFits+1;
    
    
    figure(6);
    clf;
    scatter(V,Ic);
    hold all;
    It = simmonsFormula(x,V);
    plot(V,It,'r','linewidth',3);

end

% figure(6);
% clf;
% scatter(V,Ic);
% hold all;
% t2=Ic./1e4;
% t=simmonsFormula(x,V)'./1e4;
% plot(V',simmonsFormula(x,V)','r','linewidth',3);
%
% for I=1:length(fits)
%     x=fits{I};
%     fprintf(' gap is %s (nm)\n potential is %s (eV)\n alpha is %s \n beta is %s \n\n\n\n\n',x);
% end


