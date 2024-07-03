t = cputime
%shortData=shorts{7};
sD=shortData(1:30000);
covar=6*std(sD);
dst = restore_image2(sD',covar ,60,100, 1, 20);
e=cputime

% mn= min(shortData);
% mx=max(shortData);
% shortData =255*( shortData - mn)/(mx-mn);
% dst2 = restore_image(shortData', 80, 200, .1, 5);
% shortData2 = dst2*(mx-mn)/255+mn;
% f=cputime
% figure(2);
% plot(shortData2);
% hold all;
figure(2);
plot(smooth(dst,50));

% disp(e-t)
% disp(f-e)

