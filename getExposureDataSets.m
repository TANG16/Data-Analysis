function exposureDataSets = getExposureDataSets(arg,windowBefore,windowAfter)
% GETEXPOSUREDATASETS get all gas exposures in a set of data points
% 
% INPUTS
%   arg: data points or zephyr data file (assumes is dc)
%   windowBefore: how many milliseconds before each exposure to get
%   (defaults to 60000)
%   windowAtter: how many milliseconds before each exposure to get
%   (defaults to 60000)
% 
% OUTPUTS
%   exposureDataSets: exposures
%
% NOTE: This function will be made deprecated by getDataSets once I get
% that working with plotExposureData

if(ischar(arg))
    dataPoints=getDataPoints(arg,'dc');
else
    dataPoints=arg;
end

if(nargin==1)
    windowBefore=60000;
    windowAfter=60000;
elseif(nargin==2)
    windowAfter=windowBefore;
end
        
CLOSED_STREAM_SELECT_VAL = 2;
OPEN_STREAM_SELECT_VAL = 1;

%------------------------------------------------------------------------%
%-------------------------loop over data points--------------------------%
%------------------------------------------------------------------------%
firstTime=dataPoints(1).time;
lastTime=dataPoints(end).time;
numDataPoints=length(dataPoints);
exposureDataSets=[];
i=1;
while i<=numDataPoints
    %---------------------if exposure has begun--------------------------%
    if(dataPoints(i).streamSelect == OPEN_STREAM_SELECT_VAL)
        % find first data point after windowSize seconds before the start
        % of exposure
        targetH2SConc=dataPoints(i).targetConc1_H2S;
        streamOpeningIndex=i;
        streamOpeningTime=dataPoints(i).time;
        if(streamOpeningTime-windowBefore>firstTime)
            initialTimeOfInterest=streamOpeningTime-windowBefore;
            for k=i-1:-1:1
                if(dataPoints(k).time<initialTimeOfInterest)
                    initialDataPointIndexOfInterest=k+1;
                    break;
                end
            end
        else
            initialDataPointIndexOfInterest=1;
        end
        % find last data point before windowSize seconds after end of
        % exposure
        for j=i:1:numDataPoints
            if(dataPoints(j).streamSelect == CLOSED_STREAM_SELECT_VAL)
                streamClosingIndex=j;
                streamClosingTime=dataPoints(j).time;
                if(streamClosingTime+windowAfter<lastTime)
                    finalTimeOfInterest=streamClosingTime+windowAfter;
                    for k=j+1:1:numDataPoints
                        if(dataPoints(k).time>finalTimeOfInterest)
                            finalDataPointIndexOfInterest=k-1;
                            break;
                        end
                    end
                else
                    streamClosingIndex=numDataPoints+1;
                    finalDataPointIndexOfInterest=numDataPoints;
                end
                break;
            end
        end
        if(j==numDataPoints)
            streamClosingIndex=numDataPoints+1;
            finalDataPointIndexOfInterest=numDataPoints;
        end
        % put data points before, during, and after exposure and lots of
        % other pertinent data into a struct and add it to
        % exposureDataSets
%         exposuresData=dataPoints(initialDataPointIndexOfInterest:finalDataPointIndexofInterest);
%         
%         exposuresTimes=cell(size(exposuresData));
%         exposuresSmoothedConductances=cell(size(exposuresData));
%         [exposuresTimes{:}]=exposuresData(:).time;
%         [exposuresSmoothedConductances{:}]=exposuresData(:).smoothedConductance;
%         exposuresTimesMat=cell2mat(exposuresTimes);
%         exposuresSmoothedConductancesMat=cell2mat(exposuresSmoothedConductances);
%         
%         exposuresTimesZeroed=exposuresTimesMat-exposuresTimesMat(streamOpeningIndex);
%         exposuresSmoothedConductancesZeroed=exposuresSmoothedConductancesMat-exposuresSmoothedConductancesMat(streamOpeningIndex);

%         dataPointsDuringExposure=dataPoints(streamOpeningIndex:streamClosingIndex-1);
        
%         timesDuringExposure=cell(size(dataPointsDuringExposure));
%         smoothedConductancesDuringExposure=cell(size(dataPointsDuringExposure));
%         [timesDuringExposure{:}]=dataPointsDuringExposure(:).time;
%         [smoothedConductancesDuringExposure{:}]=dataPointsDuringExposure(:).smoothedConductance;
%         timesDuringExposureMat=cell2mat(timesDuringExposure);
%         smoothedConductancesDuringExposureMat=cell2mat(smoothedConductancesDuringExposure);

        avgConductanceBeforeExposure=mean(getVals(dataPoints,'conductance',initialDataPointIndexOfInterest,streamOpeningIndex-1));
        avgSmoothedConductanceBeforeExposure=mean(getVals(dataPoints,'smoothedConductance',initialDataPointIndexOfInterest,streamOpeningIndex-1));
        
        timesDuringExposure=getVals(dataPoints,'time',streamOpeningIndex,streamClosingIndex-1);
        smoothedConductancesDuringExposure=getVals(dataPoints,'smoothedConductance',streamOpeningIndex,streamClosingIndex-1);
        
%         timesDuringExposureZeroed=timesDuringExposureMat-timesDuringExposureMat(1);
%         smoothedConductancesDuringExposureZeroed=smoothedConductancesDuringExposureMat-smoothedConductancesDuringExposureMat(1);
        timesDuringExposureZeroed=timesDuringExposure-timesDuringExposure(1);
%         smoothedConductancesDuringExposureZeroed=smoothedConductancesDuringExposure-smoothedConductancesDuringExposure(1);
        smoothedConductancesDuringExposureZeroed=smoothedConductancesDuringExposure-avgSmoothedConductanceBeforeExposure;


        [p,~,mu] = polyfit(timesDuringExposureZeroed,smoothedConductancesDuringExposureZeroed,2);
        exposureDataSets=[exposureDataSets struct('dataPointsBeforeExposure',dataPoints(initialDataPointIndexOfInterest:streamOpeningIndex-1),...
            'dataPointsDuringExposure',dataPoints(streamOpeningIndex:streamClosingIndex-1),...
            'dataPointsAfterExposure',dataPoints(streamClosingIndex:finalDataPointIndexOfInterest),...
            'targetH2SConcentration',targetH2SConc,'avgConductanceBeforeExposure',avgConductanceBeforeExposure,...
            'avgSmoothedConductanceBeforeExposure',avgSmoothedConductanceBeforeExposure,'p',p,'mu',mu)];
        i = streamClosingIndex;
    end
    i=i+1;
end
end