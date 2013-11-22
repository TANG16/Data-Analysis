function tmp=plotHeatPulseData(arg,whatToPlot,theTitle,options,windowInS,outlierConditions,segmentsToRemove,pulsesToRemove,indicesOfSegmentsToPlotSeparately,H2SConcScaleFactor)
% IMPORTANT
% The input heat pulses must have the fields necessary to plot
% them according to the 'whatToPlot' parameter.  See the code for the
% desired 'whatToPlot' parameter to see what fields are necessary, then
% comment in/out the appropriate code in getHeatPulses to output the
% heat pulses with the appropriate fields
%
% arg: heat pulses or data points
% whatToPlot:
%   'bm': data points at beginning of pulse vs. measured H2S concentration
%   'pm': change in conductance at beginning, conductance at beginning, 
%         conductance at end, change in conductance at end, conductance 
%         after vs. measured H2S concentration
%   'pt': change in conductance at beginning, conductance at beginning, 
%         conductance at end, change in conductance at end, conductance 
%         after vs. target H2S concentration
%   'ct': median of median filtered conductance vs. target H2S
%         concentration
%   'cm2':median of median filtered conductance vs. measured H2S concentration (many options)
% theTitle: the title of plot
% options:
%   'label_RH': used in 'ct', labels the humidity
%   'a': used in 'cm2'
% all the following parameters are only used in cm2 mode

if(ischar(arg))
    heatPulseDataSets=getHeatPulseDataSets(arg);
else
    heatPulseDataSets=arg;
end

BIAS_VOLTAGE=.1;

scrsz = get(0,'ScreenSize');

switch whatToPlot
    %---------------------------------------------------------------------%
    %-----------data points at beginning of pulse vs.---------------------%
    %-----------------measured H2S concentration--------------------------%
    %---------------------------------------------------------------------%
    case 'bm'
         conductanceAtBeginningOfHeatPulse=getVals(heatPulseDataSets,'conductanceAtBeginningOfHeatPulse');
         avgConductanceAtBeginningOfHeatPulse=getVals(heatPulseDataSets,'avgConductanceAtBeginningOfHeatPulse');
         avgConductanceAtBeginningOfHeatPulse2=getVals(heatPulseDataSets,'avgConductanceAtBeginningOfHeatPulse2');
         avgConductanceAtBeginningOfHeatPulse3=getVals(heatPulseDataSets,'avgConductanceAtBeginningOfHeatPulse3');
         secondConductanceOfHeatPulse=getVals(heatPulseDataSets,'secondConductanceOfHeatPulse');
         thirdConductanceOfHeatPulse=getVals(heatPulseDataSets,'thirdConductanceOfHeatPulse');
         fourthConductanceOfHeatPulse=getVals(heatPulseDataSets,'fourthConductanceOfHeatPulse');
         medMedFiltConductanceDuringHeatPulse=getVals(heatPulseDataSets,'medMedFiltConductanceDuringHeatPulse');

        
       avgH2SConc=getVals(heatPulseDataSets,'avgH2SConc');

       figure('Position',[scrsz(3)/16 scrsz(4)/4 (7/8)*scrsz(3) scrsz(4)/2],'Name','Initial Conductance Vs Concentration','NumberTitle','off');

       plot(avgH2SConc(320:419),medMedFiltConductanceDuringHeatPulse(318:417)*10^9,'.',...
       avgH2SConc(466:565),conductanceAtBeginningOfHeatPulse(466:565)*10^9,'.');

       legend('without H2O','with H2O');
    
       figure('Position',[scrsz(3)/16 scrsz(4)/4 (7/8)*scrsz(3) scrsz(4)/2],'Name','Mean conductance of first two data points vs concentration','NumberTitle','off');

       plot(avgH2SConc(320:419),medMedFiltConductanceDuringHeatPulse(318:417)*10^9,'.',...
       avgH2SConc(466:565),avgConductanceAtBeginningOfHeatPulse(466:565)*10^9,'.');

       legend('without H2O','with H2O');

       figure('Position',[scrsz(3)/16 scrsz(4)/4 (7/8)*scrsz(3) scrsz(4)/2],'Name','Mean conductance of first three data points vs concentration','NumberTitle','off');

       plot(avgH2SConc(320:419),medMedFiltConductanceDuringHeatPulse(318:417)*10^9,'.',...
       avgH2SConc(466:565),avgConductanceAtBeginningOfHeatPulse2(466:565)*10^9,'.');

       legend('without H2O','with H2O');

       figure('Position',[scrsz(3)/16 scrsz(4)/4 (7/8)*scrsz(3) scrsz(4)/2],'Name','Mean conductance of first four data points vs concentration','NumberTitle','off');

       plot(avgH2SConc(320:419),medMedFiltConductanceDuringHeatPulse(318:417)*10^9,'.',...
       avgH2SConc(466:565),avgConductanceAtBeginningOfHeatPulse3(466:565)*10^9,'.');

       legend('without H2O','with H2O');

       figure('Position',[scrsz(3)/16 scrsz(4)/4 (7/8)*scrsz(3) scrsz(4)/2],'Name','Conductance of second data points vs concentration','NumberTitle','off');

       plot(avgH2SConc(320:419),medMedFiltConductanceDuringHeatPulse(318:417)*10^9,'.',...
       avgH2SConc(466:565),secondConductanceOfHeatPulse(466:565)*10^9,'.');

       legend('without H2O','with H2O');

        figure('Position',[scrsz(3)/16 scrsz(4)/4 (7/8)*scrsz(3) scrsz(4)/2],'Name','Conductance of third data points vs concentration','NumberTitle','off');

       plot(avgH2SConc(320:419),medMedFiltConductanceDuringHeatPulse(318:417)*10^9,'.',...
       avgH2SConc(466:565),thirdConductanceOfHeatPulse(466:565)*10^9,'.');

       legend('without H2O','with H2O');

       figure('Position',[scrsz(3)/16 scrsz(4)/4 (7/8)*scrsz(3) scrsz(4)/2],'Name','Conductance of fourth data points vs concentration','NumberTitle','off');

       plot(avgH2SConc(320:419),medMedFiltConductanceDuringHeatPulse(318:417)*10^9,'.',...
       avgH2SConc(466:565),fourthConductanceOfHeatPulse(466:565)*10^9,'.');

       legend('without H2O','with H2O');
       
       %------------------------------------------------------------------%
       %--change in conductance at beginning, conductance at beginning,---%
       %--conductance at end, change in conductance at end, conductance---%
       %-------------after vs. measured H2S concentration-----------------%
       %------------------------------------------------------------------%
    case 'pm'
        figure('Position',[scrsz(3)/16 scrsz(4)/4 (7/8)*scrsz(3) scrsz(4)/2],'Name','Params Vs Concentration','NumberTitle','off');

        avgConductanceBeforeHeatPulse=getVals(heatPulseDataSets,'avgConductanceBeforeHeatPulse');
        avgConductanceAtBeginningOfHeatPulse=getVals(heatPulseDataSets,'avgConductanceAtBeginningOfHeatPulse');
        avgConductanceAtEndOfHeatPulse=getVals(heatPulseDataSets,'avgConductanceAtEndOfHeatPulse');
        avgConductanceAfterHeatPulse=getVals(heatPulseDataSets,'avgConductanceAfterHeatPulse');
        avgH2SConc=getVals(heatPulseDataSets,'avgH2SConc');

        plot(avgH2SConc,(avgConductanceAtBeginningOfHeatPulse-avgConductanceBeforeHeatPulse)*10^9,'.',...
            avgH2SConc,avgConductanceAtBeginningOfHeatPulse*10^9,'.',...
            avgH2SConc,avgConductanceAtEndOfHeatPulse*10^9,'.',...
            avgH2SConc,(avgConductanceAtEndOfHeatPulse-avgConductanceAfterHeatPulse)*10^9,'.',...
            avgH2SConc,avgConductanceAfterHeatPulse*10^9,'.');       
       
        figure('Position',[scrsz(3)/16 scrsz(4)/4 (7/8)*scrsz(3) scrsz(4)/2],'Name','Params Vs Concentration','NumberTitle','off');
     
        legend('change in conductance at beginning',...
            'conductance at beginning',...
            'conductance at end',...
            'change in conductance at end',...
            'conductance after',...
            'Location','NorthEastOutside');

        xlabel('average measured H2S concentration (ppm)');
        ylabel('conductance (nS)');

        %-----------------------------------------------------------------%
        %--change in conductance at beginning, conductance at beginning,--%
        %--conductance at end, change in conductance at end, conductance--%
        %--------------after vs. target H2S concentration-----------------%
        %-----------------------------------------------------------------%

    case 'pt'
        figure('Position',[scrsz(3)/16 scrsz(4)/4 (7/8)*scrsz(3) scrsz(4)/2],'Name','Params Vs Time','NumberTitle','off');

        avgConductanceBeforeHeatPulse=getVals(heatPulseDataSets,'avgConductanceBeforeHeatPulse');
        avgConductanceAtBeginningOfHeatPulse=getVals(heatPulseDataSets,'avgConductanceAtBeginningOfHeatPulse');
        avgConductanceAtEndOfHeatPulse=getVals(heatPulseDataSets,'avgConductanceAtEndOfHeatPulse');
        avgConductanceAfterHeatPulse=getVals(heatPulseDataSets,'avgConductanceAfterHeatPulse');
        avgH2SConc=getVals(heatPulseDataSets,'avgH2SConc');
        pulseStartingTimes=getVals(heatPulseDataSets,'pulseStartingTime');

        pulseStartingTimesInMin=pulseStartingTimes/60000;
        plot(pulseStartingTimesInMin,(avgConductanceAtBeginningOfHeatPulse-avgConductanceBeforeHeatPulse)*10^9,'.',...
            pulseStartingTimesInMin,avgConductanceAtBeginningOfHeatPulse*10^9,'.',...
            pulseStartingTimesInMin,avgConductanceAtEndOfHeatPulse*10^9,'.',...
            pulseStartingTimesInMin,(avgConductanceAtEndOfHeatPulse-avgConductanceAfterHeatPulse)*10^9,'.',...
            pulseStartingTimesInMin,avgConductanceAfterHeatPulse*10^9,'.',...
            pulseStartingTimesInMin,avgH2SConc/2,'.');

        legend('change in conductance at beginning (nS)',...
            'conductance at beginning (nS)',...
            'conductance at end (nS)',...
            'change in conductance at end (nS)',...
            'conductance after (nS)',...
            'average measured H2S concentration/2 (ppm)',...
            'Location','NorthEastOutside');

        xlabel('pulse starting time (min)');
%     case 'cm'
%         figure('Position',[scrsz(3)/16 scrsz(4)/4 (7/8)*scrsz(3) scrsz(4)/2],'Name','Conductance Vs Average H2S Concentration','NumberTitle','off');
%         
%         avgH2SConc=getVals(heatPulseDataSets,'avgH2SConc');
%         medMedFiltConductanceDuringHeatPulse=getVals(heatPulseDataSets,'medMedFiltConductanceDuringHeatPulse');
%         
%         plot(avgH2SConc,medMedFiltConductanceDuringHeatPulse*10^9,'.');
%         
%         xlabel('average measured H2S concentration (ppm)');
%         ylabel('median of median filtered conductance (nS)');

        %-----------------------------------------------------------------%
        %---------median of median filtered conductance-------------------%
        %-------------vs. target H2S concentration------------------------%
        %-----------------------------------------------------------------%
    case 'ct'
        figure('Position',[scrsz(3)/16 scrsz(4)/4 (7/8)*scrsz(3) scrsz(4)/2],'Name','Conductance Vs Target H2S Concentration','NumberTitle','off');
        
        if(~isempty(strfind(options,'label_RH')))
            numHeatPulses=length(heatPulseDataSets);
            
            segments=[];
            currTargetRH=heatPulseDataSets(1).targetRH;
            segmentStartingPulseIndex=1;
            segmentIndex=1;
            for i=1:numHeatPulses
                if(heatPulseDataSets(i).targetRH ~= currTargetRH)
                    segments=[segments; struct('index',segmentIndex,...
                        'targetRH',currTargetRH,...
                        'heatPulses',heatPulseDataSets(segmentStartingPulseIndex:i-1))];
                    segmentIndex=segmentIndex+1;
                    currTargetRH=heatPulseDataSets(i).targetRH;
                    segmentStartingPulseIndex=i;
                end
            end
            segments=[segments; struct('index',segmentIndex,...
                'targetRH',currTargetRH,...
                'heatPulses',heatPulseDataSets(segmentStartingPulseIndex:numHeatPulses))];
            
            numSegments=length(segments);
            markerType={'+' 'o' '*' '.' 'x' 's' 'd' '^' 'v' '>' '<' 'p' 'h'};
            for i=1:numSegments
                currPulses=segments(i).heatPulses;
                avgConductance=getVals(currPulses,'medMedFiltConductanceDuringHeatPulse'); %added AS 7/12/12
                plot(getVals(currPulses,'targetH2SConc'),...
                    avgConductance*BIAS_VOLTAGE*10^9,...
                    markerType{floor((i-1)/7)+1});
                hold all;
            end
            
            legend(strcat('index: ',num2str(getVals(segments,'index')),...
                ' targetRH: ',num2str(getVals(segments,'targetRH'))),...
                'Location','NorthEastOutside');
            
       else
            targetH2SConc=getVals(heatPulseDataSets,'targetH2SConc');
            medMedFiltConductanceDuringHeatPulse=getVals(heatPulseDataSets,'medMedFiltConductanceDuringHeatPulse');
        
            plot(targetH2SConc,medMedFiltConductanceDuringHeatPulse*10^9,'.');
        end
        xlabel('target H2S concentration (ppm)');
        ylabel('median of median filtered conductance (nS)');

        %-----------------------------------------------------------------%
        %----------median of median filtered conductance------------------%
        %--------------vs. measured H2S concentration---------------------%
        %-----------------------------------------------------------------%

    case 'cm2'
        figure('Position',[scrsz(3)/16 scrsz(4)/4 (7/8)*scrsz(3) scrsz(4)/2],'Name','Current Vs Measured H2S Concentration','NumberTitle','off');
        
%         sets=container.Map();
%         
%         currTargetH2SConc=heatPulseDataSets(1).targetH2SConc;
%         setStartingPulseIndex=1;
%         setIndex=1;
%         numHeatPulses=length(heatPulseDataSets);
%         for i=1:numHeatPulses
%             if(heatPulseDataSets(i).targetH2SConc ~= currTargetH2SConc)
%                 sets(setIndex)=heatPulseDataSets(setStartingPulseIndex:i-1);
%                 currTargetH2SConc = heatPulseDataSets(i).targetH2SConc;
%                 setStartingPulseIndex=i;
%                 setIndex=setIndex+1;
%             end
%         end
%         
%         remove(sets,setsToRemove);
%         
%         numSets=length(sets);
%         for i=1:numSets
%             
%         end

        heatPulseDataSets(pulsesToRemove)=[];
        
        numHeatPulses=length(heatPulseDataSets);
        
        segments=[];
        currTargetH2SConc=heatPulseDataSets(1).targetH2SConc;
%         currTargetH2SConc=heatPulseDataSets(1).dataPointsDuring(1).targetConc1_H2S; %added 7/12/12
        segmentStartingPulseIndex=1;
        segmentIndex=1;
        for i=1:numHeatPulses
            if(heatPulseDataSets(i).targetH2SConc ~= currTargetH2SConc)
%                 if(heatPulseDataSets(i).dataPointsDuring(1).targetConc1_H2S ~= currTargetH2SConc) %added 7/12/12
                segments=[segments; struct('index',segmentIndex,...
                    'targetH2SConc',currTargetH2SConc,...
                    'heatPulses',heatPulseDataSets(segmentStartingPulseIndex:i-1))];
                segmentIndex=segmentIndex+1;
                currTargetH2SConc=heatPulseDataSets(i).targetH2SConc;
%                 currTargetH2SConc=heatPulseDataSets(i).dataPointsDuring(1).targetConc1_H2S; %added 7/12/12
                segmentStartingPulseIndex=i;
            end
        end
        segments(segmentsToRemove)=[];
        
        avgConductance=getVals(heatPulseDataSets,'medMedFiltConductanceDuringHeatPulse'); %added AS 7/12/12
        numSegments=length(segments);
        for i=1:numSegments
             iOutlierIndices=[];
             iHeatPulses=segments(i).heatPulses;
             numIHeatPulses=length(iHeatPulses);
             for j=11:numIHeatPulses
                 if(avgConductance(j) < ...
                         outlierConditions(1)*mean(avgConductance(j-outlierConditions(2):j-1)))
                     iOutlierIndices=[iOutlierIndices j];
                 end
             end
             segments(i).heatPulses(iOutlierIndices)=[];
        end
        
        
        for i=1:numSegments
            iHeatPulses=segments(i).heatPulses;
            segmentStartingTime=iHeatPulses(1).pulseStartingTime;
            j=1;
            while iHeatPulses(j).pulseStartingTime < segmentStartingTime+windowInS*1000
                j=j+1;
            end
            segments(i).heatPulses(1:j-1)=[];
        end

        if(~isempty(strfind(options,'a')))
%             keptHeatPulses=[];
%             for i=1:numSegments
%                 keptHeatPulses=[keptHeatPulses; segments(i).heatPulses];
%             end
% 
%             plot(getVals(keptHeatPulses,'avgH2SConc'),getVals(keptHeatPulses,'medMedFiltConductanceDuringHeatPulse')*10^9,'.');

            markerType={'+' 'o' '*' '.' 'x' 's' 'd' '^' 'v' '>' '<' 'p' 'h'};
            for i=1:numSegments
                currPulses=segments(i).heatPulses;
                plot(getVals(currPulses,'avgH2SConc'),...
                    avgConductance*BIAS_VOLTAGE*10^9,...
                    markerType{floor((i-1)/7)+1});
                hold all;
            end
            
            legend(strcat('index: ',num2str(getVals(segments,'index')),...
                ' targetH2SConc: ',num2str(getVals(segments,'targetH2SConc'))),...
                'Location','NorthEastOutside');
        else
%             plotPoints=[];
%             for i=1:numSegmentsToPlotSeparately
%                 currSegmentIndex=segmentsToPlotSeparately(i);
%                 currSegment=segment(currSegmentIndex);
%                 plotPoints=[plotPoints; struct('pointIdentifier',strcat('set_',num2str(currSegmentIndex)),...
%                     'heatPulses',currSegment.heatPulses)];
%             end
%             
%             for i=1:numSegments
%                 currTargetH2SConc=segments(i).targetH2SConc;
%                 
%                 numPlotPoints=length(plotPoints);
%                 newTargetH2SConcFlag=true;
%                 for i=1:numPlotPoints
%                     if(strcmp(plotPoints(i).pointIdentifier,strcat('conc_',num2str(currTargetH2SConc))))
%                         newTargetH2SConcFlag=false;
%                     end
%                 end
%                 
%                 for j=i:numSegments
%                     if(segments(j).targetH2SConc==currTargetH2SConc)
%                     end
%                 end
%             end

            segmentsToPlotSeparately=segments(indicesOfSegmentsToPlotSeparately);
            
            indicesOfSegmentsToPlotByConc=1:numSegments;
            indicesOfSegmentsToPlotByConc(indicesOfSegmentsToPlotSeparately)=[];
            segmentsToPlotByConc=segments(indicesOfSegmentsToPlotByConc);
            
            numSegmentsToPlotByConc=length(segmentsToPlotByConc);
            targetConcToPulsesMap=containers.Map();
            for i=1:numSegmentsToPlotByConc
                iSegment=segmentsToPlotByConc(i);
                iTargetH2SConc=iSegment.targetH2SConc;
                iKey=num2str(iTargetH2SConc);
                if(~isKey(targetConcToPulsesMap,iKey))
                    targetConcToPulsesMap(iKey)=iSegment.heatPulses;
                    for j=i+1:numSegmentsToPlotByConc
                        jSegment=segments(j);
                        if(jSegment.targetH2SConc==iTargetH2SConc)
                            targetConcToPulsesMap(iKey)=[targetConcToPulsesMap(iKey); jSegment.heatPulses];
                        end
                    end
                end
            end

           plotPoints=[];
           numTargetConcsToPlot=length(targetConcToPulsesMap);
           targetConcsToPlot=keys(targetConcToPulsesMap);
           for i=1:numTargetConcsToPlot
               iHeatPulses=targetConcToPulsesMap(targetConcsToPlot{i});
               iAvgH2SConcs=getVals(iHeatPulses,'avgH2SConc');
               iConductances=getVals(iHeatPulses,'medMedFiltConductanceDuringHeatPulse');
               plotPoints=[plotPoints; struct('avgH2SConc',mean(iAvgH2SConcs),...
                   'avgConductance',mean(iConductances),...
                   'stdH2SConc',std(iAvgH2SConcs),...
                   'stdConductance',std(iConductances))];
           end
                      
           numSegmentsToPlotSeparately=length(segmentsToPlotSeparately);
           for i=1:numSegmentsToPlotSeparately
               iHeatPulses=segmentsToPlotSeparately(i).heatPulses;
               iAvgH2SConcs=getVals(iHeatPulses,'avgH2SConc');
               iConductances=getVals(iHeatPulses,'medMedFiltConductanceDuringHeatPulse');
               plotPoints=[plotPointsStruct; struct('avgH2SConc',mean(iAvgH2SConcs),...
                   'avgConductance',mean(iConductances),...
                   'stdH2SConc',std(iAvgH2SConcs),...
                   'stdConductance',std(iConductances))];               
           end
           
           ploterr(H2SConcScaleFactor*getVals(plotPoints,'avgH2SConc'),...
               BIAS_VOLTAGE*10^9*getVals(plotPoints,'avgConductance'),...
               H2SConcScaleFactor*getVals(plotPoints,'stdH2SConc'),...
               BIAS_VOLTAGE*10^9*getVals(plotPoints,'stdConductance'),...
               '.','hhx',.3,'hhy',.3);
%           set(gca,'XTick',0:25:250)
        end
        grid on;
        xlabel('measured H2S concentration (ppm)');
        ylabel('current (nA)');
        
        %-----------------------------------------------------------------%
        %---------------------------OTHER---------------------------------%
        %-----------------------------------------------------------------%
    otherwise
        numHeatPulses=length(heatPulseDataSets);
        for iHeatPulse=1:numHeatPulses
            ithHeatPulse=heatPulseDataSets(iHeatPulse);
            heatPulseDataSets(iHeatPulse).targetH2SConc=ithHeatPulse.dataPointsDuring(1).targetConc1_H2S;
            
            
            dataPoints=[ithHeatPulse.dataPointsBefore; ithHeatPulse.dataPointsDuring; ithHeatPulse.dataPointsAfter];
            conductances=getVals(dataPoints,'conductance');
            medFiltConductances=medfilt1(conductances);
            numDataPointsBefore=length(ithHeatPulse.dataPointsBefore);
            numDataPointsDuring=length(ithHeatPulse.dataPointsDuring);
            medFiltConductancesDuringPulse=medFiltConductances(numDataPointsBefore+1:numDataPointsBefore+numDataPointsDuring);
            heatPulseDataSets(iHeatPulse).medMedFiltConductanceDuringHeatPulse=median(medFiltConductancesDuringPulse);
        end
        
        figure('Position',[scrsz(3)/16 scrsz(4)/4 (7/8)*scrsz(3) scrsz(4)/2],'Name','Current Vs Measured H2S Concentration','NumberTitle','off');
        
        heatPulseDataSets(pulsesToRemove)=[];
        
        numHeatPulses=length(heatPulseDataSets);
        
        segments=[];
        currTargetH2SConc=heatPulseDataSets(1).targetH2SConc;
        segmentStartingPulseIndex=1;
        segmentIndex=1;
        for i=1:numHeatPulses
            if(heatPulseDataSets(i).targetH2SConc ~= currTargetH2SConc || i==numHeatPulses)
                segments=[segments; struct('index',segmentIndex,...
                    'targetH2SConc',currTargetH2SConc,...
                    'heatPulses',heatPulseDataSets(segmentStartingPulseIndex:i-1))];
                segmentIndex=segmentIndex+1;
                currTargetH2SConc=heatPulseDataSets(i).targetH2SConc;
                segmentStartingPulseIndex=i;
            end
        end
        
        segments(segmentsToRemove)=[];
        
        numSegments=length(segments);
%         for i=1:numSegments
%              iOutlierIndices=[];
%              iHeatPulses=segments(i).heatPulses;
%              numIHeatPulses=length(iHeatPulses);
%              for j=11:numIHeatPulses
%                  if(iHeatPulses(j).medMedFiltConductanceDuringHeatPulse < ...
%                          outlierConditions(1)*mean(getVals(iHeatPulses,...
%                          'medMedFiltConductanceDuringHeatPulse',j-outlierConditions(2),j-1)))
%                      iOutlierIndices=[iOutlierIndices j];
%                  end
%              end
%              segments(i).heatPulses(iOutlierIndices)=[];
%         end
        
        
%         for i=1:numSegments
%             iHeatPulses=segments(i).heatPulses;
%             segmentStartingTime=iHeatPulses(1).pulseStartingTime;
%             j=1;
%             while iHeatPulses(j).pulseStartingTime < segmentStartingTime+windowInS*1000
%                 j=j+1;
%             end
%             segments(i).heatPulses(1:j-1)=[];
%         end

        if(~isempty(strfind(options,'a')))
            markerType={'+' 'o' '*' '.' 'x' 's' 'd' '^' 'v' '>' '<' 'p' 'h'};
            for i=1:numSegments
                currPulses=segments(i).heatPulses;
                plot(getVals(currPulses,'avgH2SConc'),...
                    getVals(currPulses,'medMedFiltConductanceDuringHeatPulse')*BIAS_VOLTAGE*10^9,...
                    markerType{floor((i-1)/7)+1});
                hold all;
            end
            
            legend(strcat('index: ',num2str(getVals(segments,'index')),...
                ' targetH2SConc: ',num2str(getVals(segments,'targetH2SConc'))),...
                'Location','NorthEastOutside');
        else
            segmentsToPlotSeparately=segments(indicesOfSegmentsToPlotSeparately);
            
            indicesOfSegmentsToPlotByConc=1:numSegments;
            indicesOfSegmentsToPlotByConc(indicesOfSegmentsToPlotSeparately)=[];
            segmentsToPlotByConc=segments(indicesOfSegmentsToPlotByConc);
            
            numSegmentsToPlotByConc=length(segmentsToPlotByConc);
            targetConcToPulsesMap=containers.Map();
            for i=1:numSegmentsToPlotByConc
                iSegment=segmentsToPlotByConc(i);
                iTargetH2SConc=iSegment.targetH2SConc;
                iKey=num2str(iTargetH2SConc);
                if(~isKey(targetConcToPulsesMap,iKey))
                    targetConcToPulsesMap(iKey)=iSegment.heatPulses;
                    for j=i+1:numSegmentsToPlotByConc
                        jSegment=segments(j);
                        if(jSegment.targetH2SConc==iTargetH2SConc)
                            targetConcToPulsesMap(iKey)=[targetConcToPulsesMap(iKey); jSegment.heatPulses];
                        end
                    end
                end
            end
            

           plotPoints=[];
           numTargetConcsToPlot=length(targetConcToPulsesMap);
           targetConcsToPlot=keys(targetConcToPulsesMap);
           for i=1:numTargetConcsToPlot
               iHeatPulses=targetConcToPulsesMap(targetConcsToPlot{i});
               iTargetH2SConcs=getVals(iHeatPulses','targetH2SConc');
               iConductances=getVals(iHeatPulses','medMedFiltConductanceDuringHeatPulse');
               plotPoints=[plotPoints; struct('targetH2SConc',mean(iTargetH2SConcs),...
                   'avgConductance',mean(iConductances),...
                   'stdH2SConc',std(iTargetH2SConcs),...
                   'stdConductance',std(iConductances))];
           end
                      
           numSegmentsToPlotSeparately=length(segmentsToPlotSeparately);
           for i=1:numSegmentsToPlotSeparately
               iHeatPulses=segmentsToPlotSeparately(i).heatPulses;
               iTargetH2SConcs=getVals(iHeatPulses,'targetH2SConc');
               iConductances=getVals(iHeatPulses,'medMedFiltConductanceDuringHeatPulse');
               plotPoints=[plotPointsStruct; struct('targetH2SConc',mean(iTargetH2SConcs),...
                   'avgConductance',mean(iConductances),...
                   'stdH2SConc',std(iTargetH2SConcs),...
                   'stdConductance',std(iConductances))];               
           end
           
           ploterr(H2SConcScaleFactor*getVals(plotPoints,'targetH2SConc'),...
               BIAS_VOLTAGE*10^9*getVals(plotPoints,'avgConductance'),...
               H2SConcScaleFactor*getVals(plotPoints,'stdH2SConc'),...
               BIAS_VOLTAGE*10^9*getVals(plotPoints,'stdConductance'),...
               '.','hhx',.3,'hhy',.3);
%           set(gca,'XTick',0:25:250)
        end
           grid on;
           xlabel('measured H2S concentration (ppm)');
           ylabel('current (nA)');
       
        

%         heatPulsesSomeRemoved=[];
%         targetH2SConcs=[];
%         numHeatPulses=length(heatPulseDataSets);
%         
%         currTargetH2SConc=heatPulseDataSets(1).targetH2SConc;
%         setStartingTime=heatPulseDataSets(1).pulseStartingTime;
%         setIndex=1;
%         for i=1:numHeatPulses
%             if(heatPulseDataSets(i).targetH2SConc ~= currTargetH2SConc)
%                 currTargetH2SConc = heatPulseDataSets(i).targetH2SConc;
%                 setStartingTime = heatPulseDataSets(i).pulseStartingTime;
% %                 if(sum(targetH2SConcs==currTargetH2SConc)==0)
% %                     targetH2SConcs=[targetH2SConcs currTargetH2SConc];
% %                 end
%                 setIndex=setIndex+1;
%             end
%             if(heatPulseDataSets(i).pulseStartingTime > setStartingTime+90000 && ...
%                     sum(setsToRemove==setIndex)==0 && ...
%                     sum(pulsesToRemove==i)==0)
%                 lastTenHeatPulseConductances=getVals(heatPulseDataSets,'medMedFiltConductanceDuringHeatPulse',max([i-10 1]),i-1);
%                 if(heatPulseDataSets(i).medMedFiltConductanceDuringHeatPulse > .5*mean(lastTenHeatPulseConductances))
%                     heatPulsesSomeRemoved=[heatPulsesSomeRemoved heatPulseDataSets(i)];
%                 end
%             end
%         end
%         
%         if(~isempty(strfind(options,'a')))
%             plot(getVals(heatPulsesSomeRemoved,'avgH2SConc'),getVals(heatPulsesSomeRemoved,'medMedFiltConductanceDuringHeatPulse')*10^9,'.');
%         else
%             plotPointsMap=containers.Map();
%             
%             numHeatPulses=length(heatPulseDataSets);
%             
%             setIndex=1;
%             for i=1:numHeatPulses
%                 if(sum(setIndex==setsToPlotSeparately)>0)
%                     plotPointsMap
%                 end
%                 if(isKey(plotPointsMap(heatPulseDataSets(i).targetH2SConc)))
%                     currTargetH2SConc = heatPulseDataSets(i).targetH2SConc;
%                     setStartingTime = heatPulseDataSets(i).pulseStartingTime;
%                     if(sum(targetH2SConcs==currTargetH2SConc)==0)
%                         targetH2SConcs=[targetH2SConcs currTargetH2SConc];
%                     end
%                     setIndex=setIndex+1;
%                 end
%                 if(heatPulseDataSets(i).pulseStartingTime > setStartingTime+90000 && ...
%                         sum(setsToRemove==setIndex)==0 && ...
%                         sum(pulsesToRemove==i)==0)
%                     lastTenHeatPulseConductances=getVals(heatPulseDataSets,'medMedFiltConductanceDuringHeatPulse',max([i-10 1]),i-1);
%                     if(heatPulseDataSets(i).medMedFiltConductanceDuringHeatPulse > .5*mean(lastTenHeatPulseConductances))
%                         heatPulsesSomeRemoved=[heatPulsesSomeRemoved heatPulseDataSets(i)];
%                     end
%                 end
%             end
%             targetH2SConcs=sort(targetH2SConcs);
% 
%             
%             pointsToPlot=[];
%             for i=targetH2SConcs
%                 iHeatPulses=[];
%                 for j=heatPulsesNoOutliers
%                     if(i==j.targetH2SConc)
%                         iHeatPulses=[iHeatPulses; j];
%                     end
%                 end
%                 iConductances=getVals(iHeatPulses,'medMedFiltConductanceDuringHeatPulse');
%                 iMeasuredH2SConcs=getVals(iHeatPulses,'avgH2SConc');
%                 pointsToPlot=[pointsToPlot; mean(iMeasuredH2SConcs) mean(iConductances) std(iMeasuredH2SConcs) std(iConductances)];
%             end
%             ploterr(H2SCONCSCALEFACTOR*pointsToPlot(:,1),pointsToPlot(:,2), H2SCONCSCALEFACTOR*pointsToPlot(:,3), pointsToPlot(:,4),'hhx',.2,'hhy',.2);
% 
%             xlabel('measured H2S concentration (ppm)');
%             ylabel('conductance (nS)');
% 
%         end
end
   title(theTitle);
end