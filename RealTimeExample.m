% Before running this sample download Eikon 4 Desktop Data APIs package
% from NuGet. Note that the bitness of the package must match the bitness
% of your Matlab. I.e. if you use 64-bit Matlab you need to download from
% NuGet Eikon 4 Desktop Data APIs (x64) package. Then create a folder for
% Eikon .NET SDK and copy the following libraries from downloaded package
% into this folder:
% Common.Logging.dll
% EikonPipeDll.dll
% i18nresource.dll
% Newtonsoft.Json.dll
% protobuf-net.dll
% ThomsonReuters.Desktop.SDK.DataAccess.dll
% ThomsonReuters.Udap.BusTools.dll
% ThomsonReuters.Udap.Ipc.Managed.Common.dll
% ThomsonReuters.Udap.ManagedPS.dll
% Where multiple versions of the same library exist in the package pick the
% version targeted for .NET 4.0 framework. This version is located in
% lib\net40 folder. If you don't already have version 12 Microsoft C runtime
% libraries in the PATH you may also need to copy msvcp120.dll and
% msvcr120.dll into the same folder with all the other libraries. In this
% example the folder used to store the libraries is C:\Temp\EikonNetSDK\
%
global t
t=treikonnet('C:\Temp\EikonNetSDK\');
% The Initialize method below requires application ID string. The value can be any
% string.
t.Services.Initialize('MyMatlabEikonTestApp');
realTimeService = t.Services.Realtime;
if strcmp(t.Services.State,'Up')
    StartRealTimeSubscriptions(realTimeService);
else
    addlistener(realTimeService,'ServiceInformationChanged',@OnRealTimeServiceInformationChanged);
end
    
function r = OnRealTimeServiceInformationChanged(realTimeService,eventArgs)
disp('RealTime ServiceInformationChanged event called');
disp(System.String.Concat('RealTime service state is ',eventArgs.Information.State));
r = char(eventArgs.Information.State);
if strcmp(r,'Up')
    StartRealTimeSubscriptions(realTimeService);
end
end

function StartRealTimeSubscriptions(realTimeService)
disp('Starting real-time subscriptions');
ricList = NET.createGeneric('System.Collections.Generic.List',{'System.String'});
ricList.Add('EUR=');
ricList.Add('GBP=');
realTimeSubSetup = realTimeService.SetupDataSubscription(ricList);
fieldList = NET.createGeneric('System.Collections.Generic.List',{'System.String'});
fieldList.Add('BID');
fieldList.Add('ASK');
realTimeSubSetup.WithFields(fieldList);
realTimeSubSetup.OnDataUpdated(@RealTimeDataUpdatedCallback);
persistent realTimeSub
realTimeSub = realTimeSubSetup.CreateAndStart();
end
    
function r = RealTimeDataUpdatedCallback(realtimeUpdateDictionary)
disp('Data Updated event called');
records = realtimeUpdateDictionary.GetEnumerator();
while records.MoveNext()
    currentRecord = records.Current;
    val = currentRecord.Value;
    ric = val.Ric;
    fieldUpdate =val.FieldUpdates.GetEnumerator();
    while fieldUpdate.MoveNext()
        currentField = fieldUpdate.Current;
        fld = currentField.Field;
        rval = currentField.Value.RawValue;
        fieldID = currentField.Descriptor.Id;
        fieldType =  currentField.Descriptor.Type;
        disp({char(ric),char(fld),rval,fieldID,fieldType});
    end
end
end