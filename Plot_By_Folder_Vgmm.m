InitializeDLLs
clear pathnames;

masterPath ='S:\Research\BrianAnalysis\Stacked Junctions';
%
% for I=1:8
%     figure(I);clf;
% end


target=1;

% ampX=-3:.01:log(50);
% ampX=exp(ampX);
ampX=0:.05:4;

clear curFolder;

curFolder{1}='20140303_IBM_A_17_RIE_ACTG';
curFolder{2}='20140401_IBM_A_11_RIE_APGCmCAb';
curFolder{3}='20140402_IBM_A_11_RIE_AGCTmC';
curFolder{4}='20140414_IBM_A_13_RIE_AGC_1nM';
curFolder{5}='20140512_IBM_AA_02_RIE_AGC_10nM';
%curFolder{5}='20140225_IBM_A_27_RIE_ACTG';

names={'Control','dAMP','dCMP','dGMP','dTMP','mC','Abasic'};
colors={'k' 'r' 'g' 'b' 'k' 'm' 'c' 'k' 'c'  'm' 'r' 'c' 'r'};
allFolders ={};

for cFolder=1:length(curFolder)
    byFolder={};
    if cFolder~=6
        curFolder{cFolder}=lower(curFolder{cFolder});
        if cFolder ~=20
            for cNames =2:length(names)
                
                col=colors{cNames};
                if cFolder ==1
                    files= FindAllAnalytes('S:\Research\BrianAnalysis\Stacked Junctions',{'1um'},names{cNames},'p380mv','ref_n100mv');
                else
                    files= FindAllAnalytes('S:\Research\BrianAnalysis\Stacked Junctions',{'1nm','10nm','1um'},names{cNames},'p380mv','ref_n100mv');
                end
                cc=1;
                for J=1:length(files)
                    pathname=lower(files{J}.path);
                    fn=files{J}.name;
                    p=['c:\temp' pathname(3:end)];
                    file=[p '\'  fn '_Vgmm12.mat'];
                    cf=curFolder{cFolder};
                    if isempty(findstr(pathname,lower(cf)))==false
                        if exist(file,'file')
                            try
                                disp(curFolder{cFolder})
                                disp(pathname);
                                d=load(file);
                                byFolder{cNames,cc}= d;
                                cc=cc+1;
                            catch mex
                            end
                        end
                    end
                end
            end
            
        end
        allFolders{cFolder}=byFolder;
       
    end
end
 try
            Plot_By_Folder_Vgmm_plotting2
        catch mex
            disp(mex)
        end
