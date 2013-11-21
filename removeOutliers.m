function heatPulsesNoOutliers = removeOutliers(heatPulseDataSets)
% REMOVEOUTLIERS Returns heat pulses with no outliers
%   Output is input with outliers removed.  Outliers are any points after
%   2 minutes past the start of any exposure where the median median 
%   filtered conductance is less than half the mean of the previous ten 
%   heat pulses
%
%   To do: incorporate labeling of outliers into getHeatPulseDataSets and
%   parameterize the '2 minutes','half',and 'ten' and then get rid of this
%   function.

    heatPulsesNoOutliers=[];
    numHeatPulses=length(heatPulseDataSets);
    
    currTargetH2SConc=heatPulseDataSets(1).targetH2SConc;
    setStartingTime=heatPulseDataSets(1).pulseStartingTime;
    for i=1:numHeatPulses
        if(heatPulseDataSets(i).targetH2SConc ~= currTargetH2SConc)
            currTargetH2SConc = heatPulseDataSets(i).targetH2SConc;
            setStartingTime = heatPulseDataSets(i).pulseStartingTime;
        end
        if(heatPulseDataSets(i).pulseStartingTime > setStartingTime+120)
            lastTenHeatPulseConductances=getVals(heatPulseDataSets,'medMedFiltConductanceDuringHeatPulse',max([i-10 1]),i-1);
            if(heatPulseDataSets(i).medMedFiltConductanceDuringHeatPulse > .5*mean(lastTenHeatPulseConductances))
                heatPulsesNoOutliers=[heatPulsesNoOutliers; heatPulseDataSets(i)];
            end
        end
    end

end

