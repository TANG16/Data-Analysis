function dataSets = getDataSets(arg,mode,windowSize,mode_arg1,mode_arg2)
% GETDATASETS get data sets from data points satisfying certain conditions.
%   This code works, but CURRENTLY DOESN'T WORK WITH PLOTHEATPULSEDATA.
% 
% INPUTS
% arg: data points structure or zephyr data file (assumes is dc file)
% windowSize: each data set in dataSets contains data points from
%   windowSize seconds "before" and "after" data set
% mode:
%   heat pulses:
%       dataSets is all heat pulses
%       default windowSize is 1 second
%       mode_arg1 and mode_arg2 are not used
%   gas concentration:
%       whenever the gas concentration of gas mode_arg1 on stream mode_arg2
%       changes or stream_select changes, that's a new data set
%       default windowSize is 60 seconds
%   first data points:
%       dataSets is one data set, which is all data points in first
%       mode_arg1 minutes
%       default windowSize is 0
%   last data points:
%       dataSets is one data set, which is all data points after first
%       mode_arg1 minutes
%       default windowSize is 0
%   humidity:
%       new data set is created whenever target humidity changes
%       default windowSize is 60 seconds
% mode_arg1, mode_arg2: see "mode" explanation
% 
% OUTPUT
% dataSets: data sets
% 
%
% NOTE: THIS CODE CURRENTLY DOESN'T WORK WITH PLOTHEATPULSEDATA or 
% PLOTEXPOSUREDATA

if(ischar(arg))
    dataPoints=getDataPoints(arg,'dc');
else
    dataPoints=arg;
end

% depending on mode (see explanation in function description), choose 
% windowSize (if not specified), condition_i, and condition_j, which are
% used when parsing out data sets later
switch mode
    case 'heat pulses'
        EPS = .003;
        
        if(nargin<=4)
            windowSize=1;
        end
        
        condition_i=strcat('(i ~= 1) && (dataPoints(i).heater_voltage > dataPoints(i-1).heater_voltage + ',num2str(EPS),')');
        condition_j=strcat('(i ~= 1) && (dataPoints(j).heater_voltage < dataPoints(j-1).heater_voltage - ',num2str(EPS),')');
    case 'gas concentration'
        if(nargin==4)
            windowSize=60;
        end
        
        analyte=mode_arg1;
        stream=num2str(mode_arg2);
        
        condition_i=strcat('(i == 1) || (dataPoints(i).targetConc',stream,'_',analyte,' ~= dataPoints(i-1).targetConc',stream,'_',analyte,') || ',...
            '(dataPoints(i).streamSelect ~= dataPoints(i-1).streamSelect)');
        condition_j=strcat('(dataPoints(j).targetConc',stream,'_',analyte,' ~= dataPoints(j-1).targetConc',stream,'_',analyte,') || ',...
            '(dataPoints(j).streamSelect ~= dataPoints(j-1).streamSelect)');        
    case 'last data points'
        if(nargin<=4)
            windowSize=0;
        end
        
        nMinutesToIgnore=mode_arg1;
        
        condition_i=strcat('dataPoints(i).time >= dataPoints(1).time + ',num2str(nMinutesToIgnore*60000));
        condition_j=strcat('false');
    case 'first data points'
        if(nargin<=4)
            windowSize=0;
        end
        
        nMinutesToIgnore=mode_arg1;
        
        condition_i='i==1';
        condition_j=strcat('dataPoints(j).time > dataPoints(1).time + ',num2str(nMinutesToIgnore*60000));
    case 'humidity'
        if(nargin<=4)
            windowSize=60;
        end
        
        condition_i='(i==1) || (dataPoints(i).targetRH ~= dataPoints(i-1).targetRH)';
        condition_j='(dataPoints(j).targetRH ~= dataPoints(j-1).targetRH)';
%         field1name='targetRH';
%         field1='dataPoints(fieldChangingIndex).targetRH';
end

% run getDataSetsHelper to get data sets
dataSets = getDataSetsHelper(dataPoints,condition_i,condition_j,windowSize*1000,field1name,field1);

end

function dataSets = getDataSetsHelper(dataPoints,condition_i,condition_j,windowSize,field1name,field1)
firstTime=dataPoints(1).time;
lastTime=dataPoints(end).time;

numDataPoints=length(dataPoints);
dataSets=[];
i=1;

%------------------------------------------------------------------------%
%-------------------------loop over data points--------------------------%
%------------------------------------------------------------------------%
while i<=numDataPoints
    %---------------------if data set has begun--------------------------%
    if(eval(condition_i))
        % find first data point after windowSize seconds before the start
        % of data set
        fieldChangingIndex=i;
        fieldChangingTime=dataPoints(i).time;
        if(fieldChangingTime-windowSize>firstTime)
            initialTimeOfInterest=fieldChangingTime-windowSize;
            for k=i-1:-1:1
                if(dataPoints(k).time<initialTimeOfInterest)
                    initialDataPointIndexOfInterest=k+1;
                    break;
                end
            end
        else
            initialDataPointIndexOfInterest=1;
        end
        
        % find last data point before windowSize seconds after end of data
        % set
        for j=i+1:1:numDataPoints
%             if(getfield(dataPoints(j),field) ~= ithDataPointsFieldVal)
            if(eval(condition_j))
                fieldAgainChangingIndex=j;
                fieldAgainChangingTime=dataPoints(j).time;
                if(fieldAgainChangingTime+windowSize<lastTime)
                    finalTimeOfInterest=fieldAgainChangingTime+windowSize;
                    for k=j+1:1:numDataPoints
                        if(dataPoints(k).time>finalTimeOfInterest)
                            finalDataPointIndexOfInterest=k-1;
                            break;
                        end
                    end
                else
                    fieldAgainChangingIndex=numDataPoints+1;
                    finalDataPointIndexOfInterest=numDataPoints;
                end
                break;
            end
        end
        if(isequal(j,numDataPoints) || isempty(j))
            fieldAgainChangingIndex=numDataPoints+1;
            finalDataPointIndexOfInterest=numDataPoints;
        end

        % put data points before, during, and after exposure, and exposure 
        % starting time into struct arry, then add it to the dataSets array
        tmp = struct('dataPointsBefore',dataPoints(initialDataPointIndexOfInterest:fieldChangingIndex-1),...
            'dataPointsDuring',dataPoints(fieldChangingIndex:fieldAgainChangingIndex-1),...
            'dataPointsAfter',dataPoints(fieldAgainChangingIndex:finalDataPointIndexOfInterest));
        tmp.startingTime=dataPoints(fieldChangingIndex).time;
%         if(exist('field1name'))
%             tmp.(field1name)=eval(field1);
%         end
        dataSets=[dataSets tmp];

        % continue loop at end of data set
        i = fieldAgainChangingIndex-1;
    end
    i=i+1;
end
end

% function dataSets = getDataSets(arg,windowSize,condition1)
% arg: data points structure or zephyr data file
% windowSize: each data set in dataSets contains data points from
%   windowSize seconds "before" and "after" data set
% condition1,2,3... can currently have the following syntax:
%   heater voltage just increased/decreased
%   stream just changed to 1/2/3
%   target <gas (e.g. H2S)> concentration on stream 1/2 just change
%   relative humidity is zero

% if(ischar(arg))
%     dataPoints=getDataPoints(arg);
% else
%     dataPoints=arg;
% end
% 
% switch condition1(1)
%     case 'heater'
%         EPS = .003;
%         
%         condition_i_increases =  strcat('dataPoints(i).heater_voltage > dataPoints(i-1).heater_voltage + ',num2str(EPS));
%         condition_i_decreases =  strcat('dataPoints(i).heater_voltage < dataPoints(i-1).heater_voltage - ',num2str(EPS));
%         condition_j =  strcat('(dataPoints(j).heater_voltage < dataPoints(j-1).heater_voltage - ',num2str(EPS),') || (dataPoints(j).heater_voltage > dataPoints(j-1).heater_voltage + ',num2str(EPS,')');
%  
%         switch condition1(4)
%             case 'increased'
%                 condition_i =  condition_i_increases;
%             case 'decreased'
%                 condition_i =  condition_i_decreases;
%         end
%     case 'stream'
%         desired_stream=condition1(5);
%         condition_i = strcat('dataPoints(i).stream_select == ',num2str(desired_stream));
%         condition_j = strcat('dataPoints(j).stream_select ~= ',num2str(desired_stream));
%     case 'relative'
%         condition_i = 
%         
%     otherwise
%         condition_i = strcat('dataPoints(i).targetConc',num2str(condition1(4)),'_',num2str(condition1(1)),' ~= dataPoints(i-1).targetConc',num2str(condition1(4)),'_',num2str(condition1(1)));
%         condition_j = strcat('dataPoints(j).targetConc',num2str(condition1(4)),'_',num2str(condition1(1)),' ~= dataPoints(j-1).targetConc',num2str(condition1(4)),'_',num2str(condition1(1)));

