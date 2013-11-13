function plotExposureResponses(arg,datatype,exposureIndices,options,figureOptions)
plotNormalResponse=~isempty(strfind(options,'n'));
plotSmoothedResponse=~isempty(strfind(options,'s'));
plotFit=~isempty(strfind(options,'f'));
debugMode=~isempty(strfind(options,'d'));

if(strcmp(figureOptions,'new_figure'))
    figure;
else
    clf;
end



if(ischar(arg))
    exposureDataSets=getExposureDataSets(arg);
else
    exposureDataSets=arg;
end

colors={'red' 'green' 'blue' 'cyan' 'magenta' 'yellow' 'black'};
PPMsSeenSoFar=[];
responseCurveHandles=[];
responseCurveConcentrations=cell(0);
for i2=exposureIndices
    i=exposureDataSets(i2);
    dataBeforeExposure=i.dataPointsBeforeExposure;
    dataDuringExposure=i.dataPointsDuringExposure;
    dataAfterExposure=i.dataPointsAfterExposure;
    
    ithExposuresData=[dataBeforeExposure; dataDuringExposure; dataAfterExposure];
    
    streamOpeningIndex=length(dataBeforeExposure)+1;
    streamClosingIndex=length(dataBeforeExposure)+length(dataDuringExposure);
    
%     ithExposuresTimes=cell(size(ithExposuresData));
% %     ithExposuresConductances=cell(size(ithExposuresData));
%     ithExposuresSmoothedConductances=cell(size(ithExposuresData));
%     [ithExposuresTimes{:}]=ithExposuresData(:).time;
% %     [ithExposuresConductances{:}]=ithExposuresData(:).conductance;
%     [ithExposuresSmoothedConductances{:}]=ithExposuresData(:).smoothedConductance;
%     ithExposuresTimesMat=cell2mat(ithExposuresTimes);
% %     ithExposuresConductancesMat=cell2mat(ithExposuresConductances);
%     ithExposuresSmoothedConductancesMat=cell2mat(ithExposuresSmoothedConductances);
%     ithExposuresTimesZeroed=ithExposuresTimesMat-ithExposuresTimesMat(streamOpeningIndex);
% %     ithExposuresConductancesZeroed=ithExposuresConductancesMat-ithExposuresConductancesMat(streamOpeningIndex);
%     ithExposuresSmoothedConductancesZeroed=ithExposuresSmoothedConductancesMat-ithExposuresSmoothedConductancesMat(streamOpeningIndex);

    ithExposuresTimes=getVals(ithExposuresData,'time');
    
    ithExposuresSmoothedConductances=getVals(ithExposuresData,'smoothedConductance');
    % ithExposuresSmoothedConductancesZeroed=ithExposuresSmoothedConductances-ithExposuresSmoothedConductances(streamOpeningIndex);
    ithExposuresSmoothedConductancesZeroed=ithExposuresSmoothedConductances-i.avgSmoothedConductanceBeforeExposure;
    
    ithExposuresConductances=getVals(ithExposuresData,'conductance');
    % ithExposuresSmoothedConductancesZeroed=ithExposuresSmoothedConductances-ithExposuresSmoothedConductances(streamOpeningIndex);
    ithExposuresConductancesZeroed=ithExposuresConductances-i.avgConductanceBeforeExposure;
    
    ithExposuresTimesZeroed=ithExposuresTimes-ithExposuresTimes(streamOpeningIndex);
    ithExposuresTimesZeroedInSeconds=ithExposuresTimesZeroed/1000;
    
    ithExposuresConcentration=i.targetH2SConcentration;
    numPPMsSeen=length(PPMsSeenSoFar);
    PPMSeenBefore=false;
    for j=1:numPPMsSeen
        if(ithExposuresConcentration==PPMsSeenSoFar(j))
            % ithColor=.5*[floor((j-1)/9) floor(mod((j-1),9)/3) mod((j-1),3)];
            ithColor=colors{j};
            PPMSeenBefore=true;
            break;
        end
    end
    if(PPMSeenBefore==false)
        PPMsSeenSoFar = cat(1,PPMsSeenSoFar,ithExposuresConcentration);
        % ithColor=.5*[floor(numPPMsSeen/9) floor(mod(numPPMsSeen,9)/3) mod(numPPMsSeen,3)];
        ithColor=colors{numPPMsSeen+1};
    end
    
    if(strcmp(datatype,'conductance'))
        scalingFactor=6;
    else
        scalingFactor=3;
    end
    
    if(plotNormalResponse)
        ithCurvesHandle=plot(ithExposuresTimesZeroedInSeconds,ithExposuresConductancesZeroed*10^scalingFactor,'-+','Color',ithColor);
        hold all;
    end
    if(plotSmoothedResponse)
        ithCurvesHandle=plot(ithExposuresTimesZeroedInSeconds,ithExposuresSmoothedConductancesZeroed*10^scalingFactor,'-+','Color',ithColor);
        hold all;
    end
    if(plotFit)
        ithCurvesHandle=plot(ithExposuresTimesZeroedInSeconds,(polyval(i.p,(ithExposuresSmoothedConductancesZeroed(:,1)-i.mu(1))/i.mu(2))),'Color',ithColor); %this needs to be fixed
        hold all;
    end

    if(debugMode)
        responseCurveHandles = [responseCurveHandles ithCurvesHandle];
        responseCurveConcentrations = [responseCurveConcentrations [num2str(ithExposuresConcentration) ' ppm, ' num2str(i2)]];
    else
        if(PPMSeenBefore==false)
            responseCurveHandles = [responseCurveHandles ithCurvesHandle];
            responseCurveConcentrations = [responseCurveConcentrations [num2str(ithExposuresConcentration) ' ppm']];
        end
    end
end
legend(responseCurveHandles,responseCurveConcentrations,'Location','SouthWest');

xlabel('time since start of exposure (s)');
if(strcmp(datatype,'conductance'))
%    ylabel('change in conductance since start of exposure (nS)');
    ylabel('change in conductance since start of exposure (\muS)');
else
    ylabel('Gate Voltage Shift (mV)');
end

figureTitle='graphene functionalized with Au nanoparticles';
if(debugMode)
    if(plotNormalResponse)
        figureTitle = [figureTitle ', unsmoothed response'];
    end
    if(plotSmoothedResponse)
        figureTitle = [figureTitle ', smoothed response'];
    end
    if(plotFit)
        figureTitle = [figureTitle ', fit'];
    end
end
title(figureTitle);
end