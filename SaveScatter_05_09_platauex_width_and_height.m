for I=1:4
    flat=[];
    shift(4,7,3)=0;
    cc=1;
    %s=squeeze(scatters(I,:,:));
    figure(1);clf;hold all;
    for cNames =1:7
        for  J=1:2:1
            t=squeeze(scatters{I,cNames,J});
            if isempty(t)==false
                flat(length(t.diff),7*12+5+1)=0;
                col=colors{cNames};
                x=(t.diff-shift(I,cNames,J));
                y=t.width;
                
                scatter(x(1:50:end),y(1:50:end),3,col);
                set(gca, 'YScale', 'log')
                
                flat(1:length(t.diff),cc)=x;
                flat(1:length(t.diff),cc+1)=y;
                
                cc=cc+2;
            end
        end
        cc=cc+1;
    end
    flat(:,cc:end)=[];
    filename = ['c:\temp\offchembaseline_' curFolder{I} '.csv'];
    csvwrite(filename,flat);
end