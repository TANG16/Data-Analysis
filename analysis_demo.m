% The following script processes a file and plots average current vs.
% measured H2S concentration, then fits bulk and surface conduction models
% returns fit parameters and goodness of fit for each model.

prompt='> Completed. Press any key to continue.';

% remove infinities from file
disp(sprintf('Removing infinities from file...\n'))
removeInfinities('WKEBAILI_D01_2011-05-04-14h12m48s.txt','WKEBAILI_D01_2011-05-04-14h12m48s_no_infs.txt');
input(prompt)

% parse file, put into dataPoints variable
disp(sprintf('\nParsing file, placing all data into dataPoints...\n'))
dataPoints=getDataPoints('WKEBAILI_D01_2011-05-04-14h12m48s_no_infs.txt','dc') %include remove infinities? input?
input(prompt)

% create heatPulses variable
disp(sprintf('\nCreating heatPulses...\n'))
heatPulses=getHeatPulseDataSets(dataPoints,2.5,0,5,5)
input(prompt)

% plotting
disp(sprintf('\nPlotting with fit to bulk conduction model:  y=a*(x-b)^.666\n'))
[f_bulk,gof_bulk]=plotHeatPulseData(heatPulses,'cm','Bulk conduction fit','a',60,[0 0],[],[],[],2.8,'a*(x-b)^.666',[0 0],[10 10])
input(prompt)

disp(sprintf('\nPlotting with fit to surface conduction model:  a*(x-c)^.5+b*(x-c)'))
[f_surface,gof_surface]=plotHeatPulseData(heatPulses,'cm','Surface conduction fit','',60,[0 0],[],[],[],2.8,'a*(x-c)^.5+b*(x-c)',[1 0 2],[2 1 4])

disp(sprintf('\nNotice the degrees of freedom adjusted r squared is much better for surface conduction.'))