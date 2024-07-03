saveFile =[runParams.outputPath '\All_stats.csv'];
%fid=fopen(saveFile,'w');
fprintf('%s,',fields{:});
 fprintf('\n');
for I=1:size(data2.SVM_R_parameters,1)
    for J=1:length(fields)
       vs=data2.(fields{J});
       
       v=vs(I);
       
       if iscell(v) ==1
           v2=v{1};
          
           fprintf('%s,',v2);
       else
           fprintf('%s,',num2str(v));
       end
 %      fprintf(fid, '%s,',v);
    end
    fprintf('\n');
end