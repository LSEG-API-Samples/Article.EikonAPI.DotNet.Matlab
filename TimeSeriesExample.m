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
% rotobuf-net.dll
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
timeSeries = t.Services.TimeSeries;
if strcmp(t.Services.State,'Up')
    SendTimeSeriesRequest(timeSeries);
else
    addlistener(timeSeries,'ServiceInformationChanged',@OnTimeSeriesServiceInformationChanged);
end
    
function r = OnTimeSeriesServiceInformationChanged(timeSeries,eventArgs)
disp('TimeSeries ServiceInformationChanged event called');
disp(System.String.Concat('Timeseries service state is ',eventArgs.Information.State));
r = char(eventArgs.Information.State);
if strcmp(r,'Up')
    SendTimeSeriesRequest(timeSeries);
end
end
    
function SendTimeSeriesRequest(timeSeries)
disp('Sending timeseries request');
timeSeriesRequestSetup = timeSeries.SetupDataRequest('EUR=');
timeSeriesRequestSetup.WithView('BID');
timeSeriesRequestSetup.WithInterval(ThomsonReuters.Desktop.SDK.DataAccess.TimeSeries.CommonInterval.Intraday60Minutes);
timeSeriesRequestSetup.WithNumberOfPoints(10);
timeSeriesRequestSetup.OnDataReceived(@DataReceivedCallback);
timeSeriesRequestSetup.CreateAndSend();
end
    
function r = DataReceivedCallback(chunk)
% The data is returned in chunks. IsLast property of the chunk
% object indicates if data retrieval is complete or if more data is
% expected to be retrieved.
disp(System.String.Concat('RIC: ',chunk.Ric));
disp(System.String.Concat('Is this the last chunk: ',chunk.IsLast));
records = chunk.Records.GetEnumerator();
timeSeriesDataOutput = {};
k=1;
while records.MoveNext()
    bar = records.Current.ToBarRecord();
    ts = char(records.Current.Timestamp.ToString());
    timeSeriesDataOutput(k,1:5) = {ts,bar.Open.Value,...
        bar.High.Value,bar.Low.Value,bar.Close.Value};
    k=k+1;
end
disp(timeSeriesDataOutput);
end