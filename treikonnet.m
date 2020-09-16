classdef treikonnet < handle
%
%   T = TREIKONNET(eikonsdkpath) loads Eikon .NET SDK assemblies
%   from the location specified in eikonsdkpath parameter
%   and makes connection to Thomson Reuters Eikon application.
%   If Eikon is not already running it will be launched.
%

properties
    Assembly
    Services
end
  
methods (Access = 'public')
    
    function t = treikonnet(eikonsdkpath)
        
        if exist([eikonsdkpath 'ThomsonReuters.Desktop.SDK.DataAccess.dll'],'file') ~= 2
            error(['Thomson Reuters Eikon .NET SDK not found in the specified folder: ' eikonsdkpath]);
        end
        
        %Load Eikon .NET SDK assemblies
        
        t.Assembly{1} = NET.addAssembly([eikonsdkpath 'ThomsonReuters.Desktop.SDK.DataAccess.dll']);
        t.Assembly{2} = NET.addAssembly([eikonsdkpath 'ThomsonReuters.Udap.BusTools.dll']);
        t.Assembly{3} = NET.addAssembly([eikonsdkpath 'ThomsonReuters.Udap.Ipc.Managed.Common.dll']);
        t.Assembly{4} = NET.addAssembly([eikonsdkpath 'ThomsonReuters.Udap.ManagedPS.dll']);
        t.Assembly{5} = NET.addAssembly([eikonsdkpath 'protobuf-net.dll']);
        t.Assembly{6} = NET.addAssembly([eikonsdkpath 'Newtonsoft.Json.dll']);
        t.Services = ThomsonReuters.Desktop.SDK.DataAccess.DataServices.Instance;
        
    end
    
end

end