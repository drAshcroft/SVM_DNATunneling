 InitializeDLLs
 dirName='S:\Research\Brian\2013-12-19 angled Junction';
  listing = dir(dirName)

  ccDir=1;
  for dirI=2:length(listing)
      
      name = listing(dirI).name;
      fname=name;
      if (length(name)>7)
          pathname =[dirName '\' name];
          loadAxonTrace
          
          try
              name = ['S:\Research\Brian\angledJunctionData\D_rate_' num2str(ccDir) '.mat'];
              save(name,'rate');
          catch mex
          end
          try
              name = ['S:\Research\Brian\angledJunctionData\D_flat_' num2str(ccDir) '.mat'];
              save(name,'flattened');
          catch mex
          end
          try
              name = ['S:\Research\Brian\angledJunctionData\D_offset_' num2str(ccDir) '.mat'];
              save(name,'offset');
          catch mex
          end
          try
              name = ['S:\Research\Brian\angledJunctionData\D_sFlattened_' num2str(ccDir) '.mat'];
              save(name,'sFlattened');
          catch mex
          end
          
       
          ccDir=ccDir+1;
      end
  end