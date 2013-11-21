function [f,gof]=plotHeatPulseData(arg,whatToPlot,theTitle,options,windowInS,outlierConditions,segmentsToRemove,pulsesToRemove,indicesOfSegmentsToPlotSeparately,H2SConcScaleFactor,fit_curve,fit_lower,fit_upper)
% arg: heat pulses or data points
%
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
%   'cm': median of median filtered conductance vs. measured H2S concentration (many options)
%
% theTitle: the title of plot
%
% options:
%   'label_RH': used in 'ct', labels the humidity
%   'segments_separately': used in 'cm', plots each segment separately
%
% windowInS: used in 'cm', how many seconds at beginning of segment to
% ignore
%
% outlierConditions: used in 'cm', a 2-element array [a1 a2] where points 
% are ignored if their value is less than a1*(mean of last a2 points)
%
% segmentsToRemove: used in 'cm', array of indices of segments to remove
% 
% pulsesToRemove: used in 'cm', array of indicies of pulses to remove
%
% indicesOfSegmentsToPlotSeparately: used in 'cm', array of indices of
% segemnts to plot on their own
% 
% H2SConcScaleFactor: used in 'cm', scale factor of H2S concentration
% 
% fit_curve: used in 'cm', a string with the equation of the curve to fit
% i.e. a*(x-b)^n
%
% fit_lower: used in 'cm', lower bounds of fitting parameters during
% fitting
%
% fit_upper: used in 'cm', upper bounds of fitting parameters during
% fitting
%
% all the following parameters are only used in cm mode

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

    case 'cm'
        figure('Position',[scrsz(3)/16 scrsz(4)/4 (7/8)*scrsz(3) scrsz(4)/2],'Name','Current Vs Measured H2S Concentration','NumberTitle','off');

        % remove pulses in pulsesToRemove
        heatPulseDataSets(pulsesToRemove)=[];
        
        numHeatPulses=length(heatPulseDataSets);
        
        % group data in segments
        segments=[];
        currTargetH2SConc=heatPulseDataSets(1).targetH2SConc;
        segmentStartingPulseIndex=1;
        segmentIndex=1;
        for i=1:numHeatPulses
            if(heatPulseDataSets(i).targetH2SConc ~= currTargetH2SConc)
                segments=[segments; struct('index',segmentIndex,...
                    'targetH2SConc',currTargetH2SConc,...
                    'heatPulses',heatPulseDataSets(segmentStartingPulseIndex:i-1))];
                segmentIndex=segmentIndex+1;
                currTargetH2SConc=heatPulseDataSets(i).targetH2SConc;
                segmentStartingPulseIndex=i;
            end
        end
        
        % remove segments in segmentsToRemove
        segments(segmentsToRemove)=[];
        
        % remove outlier points
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
        
        % remove heatpulses within windowInS of beginning of segment
        for i=1:numSegments
            iHeatPulses=segments(i).heatPulses;
            segmentStartingTime=iHeatPulses(1).pulseStartingTime;
            j=1;
            while iHeatPulses(j).pulseStartingTime < segmentStartingTime+windowInS*1000
                j=j+1;
            end
            segments(i).heatPulses(1:j-1)=[];
        end

        %------------------if options='segments_separately'--------------%
        %------------------plot all segments separately------------------%
        if(~isempty(strfind(options,'segments_separately')))
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
        %-----------------if options!='segments_separately'--------------%
        else
            % segments to plot separately are all segments which indices
            % given by indicesOfSegmentsToPlotSeparately
            segmentsToPlotSeparately=segments(indicesOfSegmentsToPlotSeparately);
            
            % determine segments to plot by concentration
            indicesOfSegmentsToPlotByConc=1:numSegments;
            indicesOfSegmentsToPlotByConc(indicesOfSegmentsToPlotSeparately)=[];
            segmentsToPlotByConc=segments(indicesOfSegmentsToPlotByConc);
            
            % make a map from target concentrations to heat pulses
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

           % make points to plot by concentration
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
                      
           % make points to plot by segment
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
           
           % plot points
           ploterr(H2SConcScaleFactor*getVals(plotPoints,'avgH2SConc'),...
               BIAS_VOLTAGE*10^9*getVals(plotPoints,'avgConductance'),...
               H2SConcScaleFactor*getVals(plotPoints,'stdH2SConc'),...
               BIAS_VOLTAGE*10^9*getVals(plotPoints,'stdConductance'),...
               '.','hhx',.3,'hhy',.3);
           hold all;
           
           % plot fit curve
           fo=fitoptions('Method','NonlinearLeastSquares','Lower',fit_lower,'Upper',fit_upper);
           ft=fittype(fit_curve,'options',fo);
           [f,gof]=fit(H2SConcScaleFactor*getVals(plotPoints,'avgH2SConc'),BIAS_VOLTAGE*10^9*getVals(plotPoints,'avgConductance'),ft);
           plot(f);
        end
        
        % figure options
        grid on;
        xlabel('measured H2S concentration (ppm)');
        ylabel('current (nA)');
        
        %-----------------------------------------------------------------%
        %---------------------------OTHER---------------------------------%
        %-----------------------------------------------------------------%
    otherwise
        error('Need to specify whatToPlot parameter. Aborting.');
end
   title(theTitle);
end