function CreateDataTable2(conn,analyteList, control_analyte_Index)

sql = 'select Distinct Analyte_Index from experiment_data;';
cur =exec(conn,sql);

if isempty(cur.Message)==false
    missing = analyteList;
    indexs=[];
else
    ret=fetch(cur)
    indexs=unique(ret.Data.Analyte_Index);
    %    missing = analyteList;
    missing=[];
    for I=1:length(analyteList)
        idx =find(indexs==analyteList(I));
        if isempty(idx)==false
            indexs(idx)=[];
        else
            missing=[missing analyteList(I)]; %#ok<AGROW>
        end
    end
end

if isempty(indexs)==false
    for I=1:length(indexs)
        sql = ['delete from experiment_data where Analyte_Index=' num2str(indexs(I)) ';'];
        cur=exec(conn,sql);
        disp(cur.Message);
    end
end

if isempty(missing)==false
    
    for I=1:length(indexs)
        sql = ['delete from experiment_data where Peak_Index>0;'];
        cur=exec(conn,sql);
        disp(cur.Message);
    end
    
    for I=1:length(analyteList)
        sql =['insert into experiment_data ' ...
            'select peaks.Analyte_Index,peaks.Peak_Index,clusters.Cluster_Index, peaks.P_maxAmplitude,  peaks.P_averageAmplitude , peaks.P_topAverage , peaks.P_peakWidth , peaks.P_roughness , peaks.P_totalPower , peaks.P_iFFTLow , peaks.P_iFFTMedium , peaks.P_iFFTHigh , peaks.P_frequency , peaks.P_peakFFT1 , peaks.P_peakFFT2 , peaks.P_peakFFT3 , peaks.P_peakFFT4 , peaks.P_peakFFT5 , peaks.P_peakFFT6 , peaks.P_peakFFT7 , peaks.P_peakFFT8 , peaks.P_peakFFT9 , peaks.P_peakFFT10 , peaks.P_highLow_Ratio , peaks.P_Odd_FFT , peaks.P_Even_FFT , peaks.P_OddEvenRatio ,clusters.C_peaksInCluster  ,clusters.C_averageAmplitude  , clusters.C_topAverage  , clusters.C_clusterWidth  , clusters.C_roughness  , clusters.C_maxAmplitude  , clusters.C_totalPower  , clusters.C_iFFTLow  , clusters.C_iFFTMedium  , clusters.C_iFFTHigh  , clusters.C_clusterFFT1  , clusters.C_clusterFFT2  , clusters.C_clusterFFT3  , clusters.C_clusterFFT4  , clusters.C_clusterFFT5  , clusters.C_clusterFFT6  , clusters.C_clusterFFT7  , clusters.C_clusterFFT8  , clusters.C_clusterFFT9  , clusters.C_clusterFFT10  , clusters.C_clusterFFT11  , clusters.C_clusterFFT12  , clusters.C_clusterFFT13  , clusters.C_clusterFFT14  , clusters.C_clusterFFT15  , clusters.C_clusterFFT16  , clusters.C_clusterFFT17  , clusters.C_clusterFFT18  , clusters.C_clusterFFT19  , clusters.C_clusterFFT20  , clusters.C_clusterFFT21  , clusters.C_clusterFFT22  , clusters.C_clusterFFT23  , clusters.C_clusterFFT24  , clusters.C_clusterFFT25  , clusters.C_clusterFFT26  , clusters.C_clusterFFT27  , clusters.C_clusterFFT28  , clusters.C_clusterFFT29  , clusters.C_clusterFFT30  , clusters.C_clusterFFT31  , clusters.C_clusterFFT32  , clusters.C_clusterFFT33  , clusters.C_clusterFFT34  , clusters.C_clusterFFT35  , clusters.C_clusterFFT36  , clusters.C_clusterFFT37  , clusters.C_clusterFFT38  , clusters.C_clusterFFT39  , clusters.C_clusterFFT40  , clusters.C_clusterFFT41  , clusters.C_clusterFFT42  , clusters.C_clusterFFT43  , clusters.C_clusterFFT44  , clusters.C_clusterFFT45  , clusters.C_clusterFFT46  , clusters.C_clusterFFT47  , clusters.C_clusterFFT48  , clusters.C_clusterFFT49  , clusters.C_clusterFFT50  , clusters.C_clusterFFT51  , clusters.C_clusterFFT52  , clusters.C_clusterFFT53  , clusters.C_clusterFFT54  , clusters.C_clusterFFT55  , clusters.C_clusterFFT56  , clusters.C_clusterFFT57  , clusters.C_clusterFFT58  , clusters.C_clusterFFT59  , clusters.C_clusterFFT60  , clusters.C_clusterFFT61  , clusters.C_highLow  , clusters.C_freq_Maximum_Peaks1  , clusters.C_freq_Maximum_Peaks2  , clusters.C_freq_Maximum_Peaks3  , clusters.C_freq_Maximum_Peaks4  , clusters.C_clusterCepstrum1  , clusters.C_clusterCepstrum2  , clusters.C_clusterCepstrum3  , clusters.C_clusterCepstrum4  , clusters.C_clusterCepstrum5  , clusters.C_clusterCepstrum6  , clusters.C_clusterCepstrum7  , clusters.C_clusterCepstrum8  , clusters.C_clusterCepstrum9  , clusters.C_clusterCepstrum10  , clusters.C_clusterCepstrum11  , clusters.C_clusterCepstrum12  , clusters.C_clusterCepstrum13  , clusters.C_clusterCepstrum14  , clusters.C_clusterCepstrum15  , clusters.C_clusterCepstrum16  , clusters.C_clusterCepstrum17  , clusters.C_clusterCepstrum18  , clusters.C_clusterCepstrum19  , clusters.C_clusterCepstrum20  , clusters.C_clusterCepstrum21  , clusters.C_clusterCepstrum22  , clusters.C_clusterCepstrum23  , clusters.C_clusterCepstrum24  , clusters.C_clusterCepstrum25  , clusters.C_clusterCepstrum26  , clusters.C_clusterCepstrum27  , clusters.C_clusterCepstrum28  , clusters.C_clusterCepstrum29  , clusters.C_clusterCepstrum30  , clusters.C_clusterCepstrum31  , clusters.C_clusterCepstrum32  , clusters.C_clusterCepstrum33  , clusters.C_clusterCepstrum34  , clusters.C_clusterCepstrum35  , clusters.C_clusterCepstrum36  , clusters.C_clusterCepstrum37  , clusters.C_clusterCepstrum38  , clusters.C_clusterCepstrum39  , clusters.C_clusterCepstrum40  , clusters.C_clusterCepstrum41  , clusters.C_clusterCepstrum42  , clusters.C_clusterCepstrum43  , clusters.C_clusterCepstrum44  , clusters.C_clusterCepstrum45  , clusters.C_clusterCepstrum46  , clusters.C_clusterCepstrum47  , clusters.C_clusterCepstrum48  , clusters.C_clusterCepstrum49  , clusters.C_clusterCepstrum50  , clusters.C_clusterCepstrum51  , clusters.C_clusterCepstrum52  , clusters.C_clusterCepstrum53  , clusters.C_clusterCepstrum54  , clusters.C_clusterCepstrum55  , clusters.C_clusterCepstrum56  , clusters.C_clusterCepstrum57  , clusters.C_clusterCepstrum58  , clusters.C_clusterCepstrum59  , clusters.C_clusterCepstrum60  , clusters.C_clusterCepstrum61 , clusters.C_frequency '...
            'from peaks ' ...
            'inner join clusters on peaks.cluster_index =clusters.cluster_index ' ...
            'where peaks.analyte_index=' num2str(analyteList(I)) ';'];
        cur=exec(conn,sql) %#ok<NOPRT>
        
        disp(cur.Message);
    end
    
    sql = 'select * from experiment_data limit 1;';
    ret  =fetch(exec(conn,sql));
    ret = ret.Data;
    names = fieldnames(ret);
    
    sql =['select AVG(' names{4} ') as A_' names{4} ', std(' names{4} ') as S_' names{4} ];
    for I=5:length(names)
        sql =[sql ',AVG(' names{I} ') as A_' names{I} ', std(' names{I} ') as S_' names{I} ];
    end
    sql =[sql ' from experiment_data;'];
    
    ret=fetch(exec(conn,sql));
    
    
    sql = ['update experiment_data set ' names{4} '=(' names{4} '-(' num2str(ret.Data.(['A_' names{4}]))  '))/' num2str(ret.Data.(['S_' names{4}])) ];
    for I=5:length(names)
        sValue =ret.Data.(['S_' names{I}]);
        if isempty(sValue) ==false  && sValue~=0 && isnan(sValue)==false
            sql =[sql ', ' names{I} '=(' names{I} '-(' num2str(ret.Data.(['A_' names{I}]))  '))/' num2str(ret.Data.(['S_' names{I}])) ];
        end
    end
    sql =[sql ';']
    
    exec(conn,sql)
    
    disp(ret);
end



