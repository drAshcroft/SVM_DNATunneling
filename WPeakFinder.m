function  [allStarts, allEnds] = WPeakFinder(trace,runParams ,dname,k )

test = smooth(trace,35);


noise = std(test)*.75;

thresh = (max(test)+mean(test))/2;
m= mean( test(test<thresh) );
mX = mean( test(test>thresh) );
thresh = (mX  +m)/2 ;  %reweight so if there is more baseline, it does not pull down
%refine the threshold
m= mean( test(test<thresh) );
mX = mean( test(test>thresh) );
thresh = (mX  +m)/2 ;  %reweight so if there is more baseline, it does not pull down
%refine the threshold
m= mean( test(test<thresh) );
mX = mean( test(test>thresh) );
ult_baseline = (mX  +m)/2 ;

bottom_baseline = mean(trace(trace<ult_baseline));

thresh=(ult_baseline-m)*.7;

ult_baseline=.75;
position = test>ult_baseline;
idx=find(position==1);
didx= idx(2:end)-idx(1:end-1);

ts = find(didx~=1);

allStarts = idx(ts+1);
allEnds = idx(ts);


if (allEnds(1)<allStarts(1))
    allEnds(1)=[];
    disp('problem WPeakFinder');
end


% 
% dup=trace(4:end)-trace(1:end-3);
% allStarts = find(dup>thresh);
% 
% allStarts(length(allStarts))=[];
% 
% d=allStarts(2:end)-allStarts(1:end-1);
% idx=find(d==1)+1;
% allStarts(idx)=[];
% 
% dup=abs(dup);
% thresh2 = thresh*2;
% 
% allEnds=zeros(size(allStarts));
% I=1;
% while (I<length(allStarts))
%     try
%         baseline = (4*mean(trace(allStarts(I)-8:allStarts(I))) + mean(trace(allStarts(I):allStarts(I)+10)) )/5;
%         if (baseline>ult_baseline || baseline<bottom_baseline)
%             baseline = ult_baseline;
%         end
%         for J=allStarts(I)+5:length(dup)
%             if J>length(dup)
%                 J=length(trace)-4;
%                 break
%             end
%             
%             if dup(J)>thresh2 || trace(J)<baseline
%                 if mean(trace(J+1:J+8))<baseline
%                     t=trace(allStarts(I):J+5);
%                     l=find(t>ult_baseline);
%                     if isempty(l)
%                         J=J+5;
%                     else
%                         J=allStarts(I)-2+l(end);
%                         allStarts(I)=allStarts(I)+l(1);
%                     end
%                     break;
%                 end
%             end
%         end
%         
%         m=min([length(allStarts) I+1]);
%         M=min([length(allStarts) I+150]);
%         idx=find(allStarts(m:M)<(J))+ m-1;
%         allStarts(idx)=[];
%         allEnds(I)=J ;
%         
%        
%     catch mex
%         disp(mex.message);
%     end
%      I=I+1;
% end
% 
% allEnds=allEnds(1:length(allStarts));
% 
% allEnds(allEnds>length(trace))=length(trace);

% lCheck = allEnds-allStarts;
% idx=find(lCheck<10);
% allEnds(idx)=[];
% allStarts(idx)=[];
% lCheck(idx)=[];

allStarts=allStarts-5;
allEnds=allEnds+5;

if (length(allEnds)~=length(allStarts))
    
   allStarts=allStarts(1:length(allEnds)); 
    
end

t=trace(:);
X=1:length(t);
plot(X,t);
hold all;
for I=1:length(allStarts)
    try
        if (allEnds(I)<length(t))
            X(allStarts(I):allEnds(I))=-1000;
            t(allStarts(I):allEnds(I))=-1000;
        end
    catch mex
        dispError(mex);
    end
end
X(X==-1000)=[];
t(t==-1000)=[];
plot(X,t);
hold off;

end