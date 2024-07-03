
I=1;
c1=traces{I};
c2=traces{I+5};

for I=2:5
    sample1=traces{I};
    sample2=traces{I+5};
    
    sample1=sample1(1:floor(end/2));
    sample2=sample2(1:floor(end/2));
    
%     sample1=WienerScalart96(vertcat(c1', sample1'),50000,length(c1)/(length(sample1) + length(c1) ));
%     sample1 =sample1(length(c1):end);
 %   sample1 = smooth(sample1,331, 'moving');
   % sample1 = sample1(1:301:end);
    
%         sample2=WienerScalart96(vertcat(c2', sample2'),50000,length(c2)/(length(sample2) + length(c2) ));
%         sample2 =sample2(length(c2):end);
  %  sample2 = smooth(sample2,531, 'moving');
   % sample2 = sample2(1:301:end);
   
    figure(I);
    plot(sample2);
    hold all;
    plot(sample1);
    hold off;
    
    smoothed{I}=sample1;
    smoothed{I+5}=sample2;
end


for I=2:5
    sample1=smoothed{I}(1:floor(end/2));
    sample2=smoothed{I+5}(1:floor(end/2));
    sample1=(sample1-mean(sample1))/std(sample1);
    sample2=(sample2-mean(sample2))/std(sample2);
    
    figure(30+I);
    plot(sample1);
    hold all;
    plot(sample2);
    hold off;
end


figure(10);clf;
figure(12);clf;
for I=2:5
    sample1=traces{I}(1:floor(end/2));
    sample2=traces{I+5}(1:floor(end/2));
 
    sample1=(sample1-mean(sample1))/std(sample1);
    sample2=(sample2-mean(sample2))/std(sample2);
    
    figure(I);
    clf;
    vonkoch=sample1;
   
    cw1 = cwt(vonkoch,1:64,'sym2');
    hist1= sum( cw1,2);
    hist1=hist1/sum(hist1);
    plot(hist1);
    hold all;
  
    figure(10)
    plot(hist1);
    hold all;
    
    figure(I);
    vonkoch=sample2;
  
    cw1 = cwt(vonkoch,1:64,'sym2');
    
    hist1= sum( cw1,2);
    hist1=hist1/sum(hist1);
    plot(hist1);
    hold off;
  
    figure(12)
    plot(hist1);
    hold all;
end

