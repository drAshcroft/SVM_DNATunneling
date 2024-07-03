function J=simmonsFormula(p,V)

e=1.60217657e-19; % C  
h=6.62607e-34; % J*s   4.135667516(91)×10?15 eV*s
me=9.10938e-31; 
alpha=p(4);
beta=p(5);

dS=p(1)*1e-9;
phi0=p(2)*e;
E=abs(p(3));%10;%abs(p(3));


% 
diE=8.8541878176e-12; %F/m

lambda = e^2*log(2)/(8*pi*E*diE*dS);
s1=1.2*lambda*dS/phi0;
s2=(dS*( 1-9.2*lambda/(3*phi0+4*lambda-2*e*abs(V)))+s1)';
p1=e*abs(V).*(s1+s2)/dS/2;
p2=1.15.*lambda.*dS./(s2-s1);
if dS-s2==0
    s2(:)=s1;
end
p3=abs(s2.*(dS-s1)./( s1.*(dS-s2)));
p3=log(p3);
phi0=phi0-p1-p2.*p3;
%phi0=p(2)*e;

J0=-1*e/(2*pi*h*(beta*dS)^2);
A=(4*pi*beta*dS*(2*me)^.5/h);

J=((J0*(phi0.*exp( -1*A*alpha*phi0.^.5)- ...
    (phi0+V*e).*exp( -1*A*alpha*phi0.^.5+V*e))));

if isnan(sum(J))==true
   disp('nan'); 
end

end