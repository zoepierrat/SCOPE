load("SOBS_2018-2021.mat")

y = year(OBS_AirTemp_Cnpy6m.Timestamp);
DOY = day(OBS_AirTemp_Cnpy6m.Timestamp,"dayofyear");
doy = DOY + (minute(OBS_AirTemp_Cnpy6m.Timestamp)/60+hour(OBS_AirTemp_Cnpy6m.Timestamp))/24;

T = table(y,doy,OBS_IncomingShortwaveRad_AbvCnpy.Value,OBS_IncomingLongwaveRad_AbvCnpy.Value,OBS_BarometricPressure.Value*10,OBS_AirTemp_AbvCnpy25m.Value,OBS_WindSpeed_AbvCnpy26m.Value,OBS_VapourPressure_AbvCnpy25m.Value*10); %added conversions 

T.Properties.VariableNames = {'y','t','Rin','Rli','p','Ta','u','ea'};

writetable(T,'SOBS_SCOPE_INPUT.csv')