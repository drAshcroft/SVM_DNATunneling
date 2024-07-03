figure(23);clf;
cc=1;
lNames = {};
coords =[];
ident = [];
for I=1:length(props)
    aprops=props{I};
    if isempty(aprops)==false && length(aprops.propAmp)>3
        if plotMode ==concentrationMode
            col=concentrationColors{mod(I,length(concentrationColors))+1};
        else
            col=colors{mod(I,length(colors)+1)};
        end
        
        t = horzcat(aprops.propAmp', log( aprops.propLife+.1)');
        t= horzcat(t, aprops.propJump');
        scatter3(aprops.propAmp,  aprops.propLife,aprops.propJump,4,col);
        hold all
         lNames{cc}=analyteNames{analyteMap(I)};
        cc=cc+1;
        
        
        coords=vertcat(coords,t);
        t = zeros([1 size(t,1)])+I;
        ident=vertcat(ident,t');
    end
end
xlabel('Absolute amplitude (pA)')
ylabel('Lifetime');
zlabel('Jump (pA)');
legend(lNames);


ratings=coords;
w = 1./var(ratings);
[wcoeff,score,latent,tsquared,explained] = pca(ratings,'VariableWeights',w);

figure(51);clf;
hold all;
for I=1:length(props)
    idx=find(ident==I);
    plot(score(idx,1),score(idx,2),'+')
end
hold off;
xlabel('1st Principal Component')
ylabel('2nd Principal Component')
legend(lNames);

figure(53);clf;
hold all;
for I=1:length(props)
   idx=find(ident==I);
    scatter3(score(idx,1),score(idx,2),score(idx,3))
end
hold off;
xlabel('1st Principal Component')
ylabel('2nd Principal Component')
zlabel('3nd Principal Component')
legend(lNames);





