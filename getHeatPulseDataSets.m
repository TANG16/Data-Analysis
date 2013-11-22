function heatPulseDataSets = getHeatPulseDataSets(arg,pulse_v,v_btw_pulses,windowBefore,windowAfter)
% GETHEATPULSEDATASETS groups dataPoints into heatPulses
% 
% INPUTS
% arg: can be either the file to get heat pulses from (assumes file is 
%    dc-type) or the dataPoints
% 
% pulse_v: voltage of heat pulses
% 
% v_btw_pulses: voltage between heat pulses (defaults to 0)
% 
% windowBefore: milliseconds before heat pulse to put into heat pulse 
%   (defaults to 60000)
% 
% windowAfter: milliseconds after heat pulse to put into heat pulse
%   (if windowBefore is specified, defaults to windowBefore.  Otherwise, 
%   defaults to 60000)
% 
% OUTPUTS
% heatPulseDataSets: heatPulses
%
% NOTE: This function will be made deprecated by getDataSets once I get
% that working with plotHeatPulseData
%
% To Do: get rid of pulse_v and v_btw_pulses and know that it's the
% beginning and end of the heat pulse by the voltage changing.

EPS=0.003

if(ischar(arg))
    dataPoints=getDataPoints(arg,'dc');
else
    dataPoints=arg;
end

if(nargin==2)
    v_btw_pulses=0;
    windowBefore=60000;
    windowAfter=60000;
elseif(nargin==3)
    windowBefore=60000;
    windowAfter=60000;
elseif(nargin==4)    
    windowAfter=windowBefore;
end

%------------------------------------------------------------------------%
%-------------------------loop over data points--------------------------%
%------------------------------------------------------------------------%
firstTime=dataPoints(1).time;
lastTime=dataPoints(end).time;
numDataPoints=length(dataPoints);
heatPulseDataSets=[];
i=1;
while i<=numDataPoints
    %-------if heat pulse has begun (wiggle room of EPS)--------------%
    if((dataPoints(i).heater_voltage > pulse_v-EPS) && (dataPoints(i).heater_voltage < pulse_v+EPS))
        % find first data point after windowSize seconds before the start
        % of heat pulse
%         targetH2SConc=dataPoints(i).targetConc1_H2S;
        pulseStartingIndex=i;
        pulseStartingTime=dataPoints(i).time;
        if(pulseStartingTime-windowBefore>firstTime)
            initialTimeOfInterest=pulseStartingTime-windowBefore;
            for k=i-1:-1:1
                if(dataPoints(k).time<initialTimeOfInterest)
                    initialDataPointIndexOfInterest=k+1;
                    break;
                end
            end
        else
            initialDataPointIndexOfInterest=1;
        end
        % find last data point before windowSize seconds after end of heat
        % pulse
        for j=i:1:numDataPoints
            if((dataPoints(j).heater_voltage > v_btw_pulses-EPS) && (dataPoints(j).heater_voltage < v_btw_pulses+EPS))
                pulseEndedIndex=j;
                pulseEndedTime=dataPoints(j).time;
                if(pulseEndedTime+windowAfter<lastTime)
                    finalTimeOfInterest=pulseEndedTime+windowAfter;
                    for k=j+1:1:numDataPoints
                        if(dataPoints(k).time>finalTimeOfInterest)
                            finalDataPointIndexOfInterest=k-1;
                            break;
                        end
                    end
                else
                    pulseEndedIndex=numDataPoints+1;
                    finalDataPointIndexOfInterest=numDataPoints;
                end
                break;
            end
        end
        if(j==numDataPoints)
            pulseEndedIndex=numDataPoints+1;
            finalDataPointIndexOfInterest=numDataPoints;
        end
        
        % put data points before, during, and after exposure and lots of
        % other pertinent data into a struct and add it to the heatPulses 
        % array        
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

%         avgConductanceBeforeHeatPulse=mean(getVals(dataPoints,'conductance',initialDataPointIndexOfInterest,pulseStartingIndex-1));
%         avgSmoothedConductanceBeforeHeatPulse=mean(getVals(dataPoints,'smoothedConductance',initialDataPointIndexOfInterest,pulseStartingIndex-1));
        
%         timesDuringHeatPulse=getVals(dataPoints,'time',pulseStartingIndex,pulseEndingIndex-1);
%         smoothedConductancesDuringHeatPulse=getVals(dataPoints,'smoothedConductance',pulseStartingIndex,pulseEndingIndex-1);
%         
% %         timesDuringExposureZeroed=timesDuringExposureMat-timesDuringExposureMat(1);
% %         smoothedConductancesDuringExposureZeroed=smoothedConductancesDuringExposureMat-smoothedConductancesDuringExposureMat(1);
%         timesDuringHeatPulseZeroed=timesDuringHeatPulse-timesDuringHeatPulse(1);
% %         smoothedConductancesDuringExposureZeroed=smoothedConductancesDuringExposure-smoothedConductancesDuringExposure(1);
%         smoothedConductancesDuringHeatPulseZeroed=smoothedConductancesDuringHeatPulse-avgSmoothedConductanceBeforeHeatPulse;
% 
% 
%         [p,~,mu] = polyfit(timesDuringHeatPulseZeroed,smoothedConductancesDuringHeatPulseZeroed,2);
%         heatPulseDataSets=[heatPulseDataSets struct('dataPointsBeforeHeatPulse',dataPoints(initialDataPointIndexOfInterest:pulseStartingIndex-1),...
%             'dataPointsDuringHeatPulse',dataPoints(pulseStartingIndex:pulseEndingIndex-1),...
%             'dataPointsAfterHeatPulse',dataPoints(pulseEndingIndex:finalDataPointIndexOfInterest),...
%             'targetH2SConcentration',targetH2SConc,'avgConductanceBeforeHeatPulse',avgConductanceBeforeHeatPulse,...
%             'avgSmoothedConductanceBeforeHeatPulse',avgSmoothedConductanceBeforeHeatPulse,'p',p,'mu',mu)];
        

%         avgConductanceBeforeHeatPulse=mean(getVals(dataPoints,'conductance',max(1,pulseStartingIndex-16),pulseStartingIndex-1));
%         conductanceAtBeginningOfHeatPulse=mean(getVals(dataPoints,'conductance',pulseStartingIndex,pulseStartingIndex));
%         secondConductanceOfHeatPulse=mean(getVals(dataPoints,'conductance',pulseStartingIndex+1,pulseStartingIndex+1));
%         thirdConductanceOfHeatPulse=mean(getVals(dataPoints,'conductance',pulseStartingIndex+2,pulseStartingIndex+2));
%         fourthConductanceOfHeatPulse=mean(getVals(dataPoints,'conductance',pulseStartingIndex+3,pulseStartingIndex+3));
%         avgConductanceAtBeginningOfHeatPulse=mean(getVals(dataPoints,'conductance',pulseStartingIndex,pulseStartingIndex+1));
%         avgConductanceAtBeginningOfHeatPulse2=mean(getVals(dataPoints,'conductance',pulseStartingIndex,pulseStartingIndex+2));
%         avgConductanceAtBeginningOfHeatPulse3=mean(getVals(dataPoints,'conductance',pulseStartingIndex,pulseStartingIndex+3));
%         avgConductanceAtEndOfHeatPulse=mean(getVals(dataPoints,'conductance',max(1,pulseEndedIndex-16),pulseEndedIndex-1));
%         if(pulseEndedIndex+5<numDataPoints)
%             indexToAverageTo=pulseEndedIndex+5;
%         else
%             indexToAverageTo=numDataPoints;
%         end
%         avgConductanceAfterHeatPulse=mean(getVals(dataPoints,'conductance',pulseEndedIndex,indexToAverageTo));
        
        avgMedFiltConductanceDuringHeatPulse=mean(getVals(dataPoints,'medFiltConductance',pulseStartingIndex,pulseEndedIndex-1));
        medMedFiltConductanceDuringHeatPulse=median(getVals(dataPoints,'medFiltConductance',pulseStartingIndex,pulseEndedIndex-1));
        targetH2SConc=dataPoints(pulseStartingIndex).targetConc1_H2S;
        targetRH=dataPoints(pulseStartingIndex).targetRH;
        if(isfield(dataPoints,'H2S'))
            avgH2SConc=mean(getVals(dataPoints,'H2S',pulseStartingIndex,pulseEndedIndex-1));
            stddevH2SConc=std(getVals(dataPoints,'H2S',pulseStartingIndex,pulseEndedIndex-1));
        
            heatPulseDataSets=[heatPulseDataSets; struct('dataPointsBeforeHeatPulse',dataPoints(initialDataPointIndexOfInterest:pulseStartingIndex-1),...
                'dataPointsDuringHeatPulse',dataPoints(pulseStartingIndex:pulseEndedIndex-1),...
                'dataPointsAfterHeatPulse',dataPoints(pulseEndedIndex:finalDataPointIndexOfInterest),...
                'medMedFiltConductanceDuringHeatPulse',medMedFiltConductanceDuringHeatPulse,...
                'targetH2SConc', targetH2SConc,...
                'targetRH', targetRH,...
                'avgH2SConc', avgH2SConc,...
                'pulseStartingTime',pulseStartingTime)];

%                 'avgConductanceBeforeHeatPulse',avgConductanceBeforeHeatPulse,...
%                 'conductanceAtBeginningOfHeatPulse',conductanceAtBeginningOfHeatPulse,...
%                 'avgConductanceAtBeginningOfHeatPulse', avgConductanceAtBeginningOfHeatPulse,...
%                 'avgConductanceAtBeginningOfHeatPulse2',avgConductanceAtBeginningOfHeatPulse2,...
%                 'avgConductanceAtBeginningOfHeatPulse3',avgConductanceAtBeginningOfHeatPulse3,...
%                 'secondConductanceOfHeatPulse',secondConductanceOfHeatPulse,...
%                 'thirdConductanceOfHeatPulse',thirdConductanceOfHeatPulse,...
%                 'fourthConductanceOfHeatPulse',fourthConductanceOfHeatPulse,...
%                 'avgConductanceAtEndOfHeatPulse', avgConductanceAtEndOfHeatPulse,...
%                 'avgConductanceAfterHeatPulse', avgConductanceAfterHeatPulse,...
%                 'stddevH2SConc', stddevH2SConc,...

        else
            heatPulseDataSets=[heatPulseDataSets; struct('dataPointsBeforeHeatPulse',dataPoints(initialDataPointIndexOfInterest:pulseStartingIndex-1),...
                'dataPointsDuringHeatPulse',dataPoints(pulseStartingIndex:pulseEndedIndex-1),...
                'dataPointsAfterHeatPulse',dataPoints(pulseEndedIndex:finalDataPointIndexOfInterest),...
                'medMedFiltConductanceDuringHeatPulse',medMedFiltConductanceDuringHeatPulse,...
                'targetH2SConc', targetH2SConc,...
                'targetRH', targetRH,...
                'pulseStartingTime',pulseStartingTime)];            
%                 'avgConductanceBeforeHeatPulse',avgConductanceBeforeHeatPulse,...
%                 'conductanceAtBeginningOfHeatPulse',conductanceAtBeginningOfHeatPulse,...
%                 'avgConductanceAtBeginningOfHeatPulse', avgConductanceAtBeginningOfHeatPulse,...
%                 'avgConductanceAtBeginningOfHeatPulse2',avgConductanceAtBeginningOfHeatPulse2,...
%                 'avgConductanceAtBeginningOfHeatPulse3',avgConductanceAtBeginningOfHeatPulse3,...
%                 'secondConductanceOfHeatPulse',secondConductanceOfHeatPulse,...
%                 'thirdConductanceOfHeatPulse',thirdConductanceOfHeatPulse,...
%                 'fourthConductanceOfHeatPulse',fourthConductanceOfHeatPulse,...
%                 'avgConductanceAtEndOfHeatPulse', avgConductanceAtEndOfHeatPulse,...
%                 'avgConductanceAfterHeatPulse', avgConductanceAfterHeatPulse,...
        end
        
        % continue loop at end of pulse
        i = pulseEndedIndex;
        
        

    end
    i=i+1;
end
end