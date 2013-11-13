function heatPulsesNoOutliers = labelOutliers(heatPulseDataSets)

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

