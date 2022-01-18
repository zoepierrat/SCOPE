clear all
close all

%% User Input 
station_name = 'Old Black Spruce Summary Dataset'; % put station name (as wildcard)
prefix = 'OBS_' ;% variable names will use this prefix
ts_name = '05.*'; % what type of TS? Wildcard ok (refer to Wiski TS types)

% what date range is data required for?
from ='2018-09-08 00:00:00';
to='2022-1-1 00:00:00';

%% Part 1: Find out what parameters are available, and allow user to select which ones should be extracted

% Data selection parameters
wiskiex = 'http://giws.usask.ca:8080/KiWIS/KiWIS';
service='kisters';
type='queryServices';
request='getTimeseriesList';
datasource='0';
format='ascii';
returnfields='station_name,ts_id,ts_name,stationparameter_name';

% format the data selection parameters into a string
parameter_list = sprintf('%s=%s&','service',service,'type',type,'request',request,'datasource',datasource,'format',...
    format,'station_name',station_name,'ts_name',ts_name,'returnfields',returnfields);

url_spec = sprintf('%s?%s',wiskiex,parameter_list);

% Fetch the list of available parameters from the Wiski server
web_fetch = urlread(url_spec);

% parse the ascii string returned from the web fetch command (this must be
% adjusted if the data parameters are modified)
C=textscan(web_fetch,'%s %f %s %s','Delimiter','\t','Headerlines',1);
% create independent variable from the cell array
ts = C{2};
parameters = C{4}; 

% open a selection dialogue box so that the paramaters can be selected
[Selection,ok] = listdlg('ListString',parameters,'ListSize',[300 300]);

timeseries_id = ts(Selection); 
variable_names = parameters(Selection);
% make sure that the variable names don't have a decimal in them... replae
% with d if one is found
variable_names = strrep(variable_names, '.', 'd');
variable_names = strcat(prefix,variable_names);


%% Part II Extract the selected parameters for the desired data range, and format 

% data extraction parameters
wiskiex = 'http://giws.usask.ca:8080/KiWIS/KiWIS';
service='kisters';
type='queryServices';
request='getTimeseriesValues';
datasource='0';
format='ascii';
dateformat='yyyy-MM-dd%20HH:mm:ss';

returnfields='Timestamp,Value,Quality Code';

% in the event that all parameters do not have complete records between the
% desired data ranges:
% Create a new timestamp for the expected values
% start_date = datevec(from);
% end_date = datevec(to);
% time_interval = [0 0 0 0 30 0];

% serial_matrix = datenum(start_date):datenum(time_interval):datenum(end_date);
% super_date_matrix = datevec(serial_matrix);


% For each Wiski parameter required, grab the data, assign variable names, and match all timestamps

for i=1:length(timeseries_id)
ts_id=num2str(timeseries_id(i));

parameter_list = sprintf('%s=%s&','service',service,'type',type,'request',request,'datasource',datasource,'format',...
    format,'dateformat',dateformat,'ts_id',ts_id,'returnfields',returnfields,'from',from,'to',to);

url_spec = sprintf('%s?%s',wiskiex,parameter_list);
web_fetch = urlread(url_spec);

D(i,:)=textscan(web_fetch,'%q %f %f','Delimiter','\t','Headerlines',3,'TreatAsEmpty',{'no value'});

end

for j = 1:length(variable_names) 
   v = variable_names{j}; % assign each cell to its corresponding variable name
   T = table(datetime(D{j,1}),D{j,2},D{j,3},'VariableNames',{'Timestamp','Value','QualityCode'});
   assignin('base',v,T);
   results_size(j,1) = length(D{j,2}); % see how many values were returned
end


% clear all unnecessary variables
clearvars -except -regexp OBS

% open dialogue box to save
uisave