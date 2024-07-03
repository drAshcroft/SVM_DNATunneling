
libraryPath = mfilename('fullpath');
[pathstr,name,ext] = fileparts(libraryPath) ;

addpath(genpath(pathstr));

NET.addAssembly([pathstr '\cSharpDLL2\mySQLAdapter.dll']);

switch computer
    case 'PCWIN'
        dlldir = fullfile(pwd,'dlls','bin','32-bit','nilibddc.dll');
        headerdir = fullfile(pwd,'dlls','include','32-bit','nilibddc_m.h');
    case 'PCWIN64'
        dlldir = fullfile(pwd,'dlls','bin','64-bit','nilibddc.dll');
        headerdir = fullfile(pwd,'dlls','include','64-bit','nilibddc_m.h');
end

disp(dlldir)
disp(headerdir)

if ~libisloaded('nilibddc')
    try
        % loadlibrary(dlldir,headerdir);
        loadlibrary(dlldir, @nilibddc, 'alias', 'nilibddc')
    catch %#ok<CTCH>
        warndlg({'Cannot load libraries to read TDMS files!',...
            'You can continue to use the program but it won''t read TDMS files,',...
            'you probably need to install a compiler in MATLAB.',...
            'Google "MATLAB Selecting a Compiler on Windows Platforms"',...
            'Or Talk to Brett Gyarfas!'},'Error!','modal')
    end
end
