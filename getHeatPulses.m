function heatPulses = getHeatPulses(arg,pulse_v,v_btw_pulses,tg,sequence,fullfilename,equiv_RHs,windowBeforeInS,windowAfterInS)
%-----------------------------INPUTS--------------------------------------%
% arg: dataPoints or the file to get the dataPoints from
% 
% v_pulse: heater volrage during pulses in V.
%
% v_btw_pulses: heater voltage between pulses in V.
%
% tg: testgroup dataPoints are from.  Must be a number.
% 
% sequence: sequence dataPoints are from.  Must be a number.
% 
% fullfilename: name of file dataPoints are from.
% 
% equiv_RHs: an array of the target RHs that produce
% the same measured RH.  i.e.
%   [15 4 14]
%   [20 7 19]
%   [10 3 7]
% means that a target RH of 15% on stream A produces the same
% measured RH as a target RH of 4% on stream B and a target RH of 7% on
% purge, and a target RH of 20% on stream A produces the same measured RH 
% as a target RH of 7% on stream B and a target RH of 19% on purge, etc.  
% All target RHs encountered in this test must be in this array.  If
% equiv_RHs is not provided, it is set to [0 0 0].
% 
% windowBeforeInS: time window (in s) before heat pulse from which to get
%   dataPointsBefore, and over which to average.  If not provided, set to 1
% 
% windowAfterInS: time window (in s) after heat pulse from which to get
%   dataPointsAfter, and over which to average.  If neither windowBeforeInS
%   nor windowAfterInS are provided, windowAfterInS is set to 1.  If
%   windowBeforeInS is provided and windowAfterInS is not, windowAfterInS
%   is set to windowBeforeInS.
% 
%-----------------------------OUTPUT--------------------------------------%
% heatPulses: cell array of heat pulses in dataPoints. A cell array
% is used instead of a structure array, as a cell array can accomodate 
% different kinds of structures in the same array.  I.e. some heat pulses
% will have more fields than others (e.g. targetConc1,
% tSincelastChangeRH,...)  Actually the output of getHeatPulses right now
% is an array of heat pulses, where all have the same fields so you might
% argue that a cell array is not necessary, but (a) this may not always be
% true, and (b) if you wanted to combine the outputs of multiple runs of 
% getHeatPulses, those might have different fields and the combination would have to be a
% cell array and it seems bad for that combination of getHeatPulses outputs 
% to be a cell array while a single output is a structure array, because
% they'd have to be accessed differently when are both essentially the same
% thing, arrays of heat pulses.  Run time does not appear to depend on
% whether or not cell arrays or structure arrays are used.  Array size is
% ~50% larger for cell arrays than for struct arrays, but that is a small
% price to pay, in my opinion.  Heat Pulses have the following fields:
%   - all the fields in the first dataPoint of the heatPulse, except 
%       conductance (which I renamed FirstCond), smoothedConductance,
%       medFiltConductance.  (smoothedConductance is not useful for 
%       heatPulses because it smoothes out the pulse edges, 
%       medFiltConductance of the first data point isn't meaningful right 
%       now because the first data point has a huge spike.
%
%   - tg: test group that dataPoints is from
%
%   - sequence: sequence that dataPoints is from
%
%   - zephyrOutputFileName: file that dataPoints is from
%
%   - index: index of heat pulse in heatPulses array
%
%   - firstDataPointIndex: index in dataPoints array of first data point in 
%       heat pulse
%
%   - condsBefore: if conductance is a field of the data points, array of 
%       conductances of data points before the heat
%       pulse and after windowBeforeInS seconds before the heat pulse
%       starts.  If conductance is not a field of the data points, this is not a field of the heat pulse.
%
%   - condsDuring: if conductance is a field of the data points, array of 
%       conductances of data points in the heat pulse. If conductance is 
%       not a field of the data points, this is not a field of the heat pulse.
%
%   - condsAfter: if conductance is a field of the data points, array of 
%       conductances of data points after the heat pulse
%       and before WindowAfterInS seconds after the heat pulse ends. If 
%       conductance is not a field of the data points, this is not a field of the heat pulse.
%
%   - meanCondBefore: if conductance is a field of the data points: if 
%       condsBefore is more than one data point, mean of
%       conds before, except the last data point.  If condsBefore is one
%       data point, the data point, If condsBefore is empty, NaN.  If 
%       conductance is not a field of the data points, this is not a field of the heat pulse.
%
%   - firstCond: if conductance is a field of the data points, conductance 
%       of first data point in heat pulse. If conductance is not a field of 
%       the data points, this is not a field of the heat pulse.
%
%   - initChangeCond: if conductance is a field of the data points: if 
%       condsBefore is not empty, finalCond-last
%       conductance in condsBefore. If it is empty, NaN.  If conductance is 
%       not a field of the data points, this is not a field of the heat pulse.
%
%   - meanCond: if conductance is a field of the data points, mean of 
%       conductances during heat pulse. If conductance is not a field of 
%       the data points, this is not a field of the heat pulse.
%
%   - lastCond: if conductance is a field of the data points, last 
%       conductance in heat pulse. If conductance is not a field of the 
%       data points, this is not a field of the heat pulse.
%
%   - meanLast3Cond: if conductance is a field of the data points: if 
%       condsDuring has more than 3 data points, mean over
%       the last 3.  If it has 3 or less, the mean of all the conductances.
%       If conductance is not a field of the data points, this is not a field of the heat pulse.
%
%   - meanLast5Cond: if conductance is a field of the data points: if 
%       condsDuring has more than 5 data points, mean over
%       the last 5.  If it has 5 or less, the mean of all the conductances.
%       If conductance is not a field of the data points, this is not a field of the heat pulse.
%
%   - meanCondAfter: if conductance is a field of the data points: if 
%       condsAfter has more than 1 data point, mean over
%       the all the conductances except the last.  If it has 1, the
%       conductance of that data point.  If it is empty, NaN.
%       If conductance is not a field of the data points, this is not a field of the heat pulse.
%
%   - finalChangeCond: if conductance is a field of the data points, if 
%       condsAfter is not empty, lastCond-conductance of
%       first data point after heat pulse.  If it is empty, NaN.
%       If conductance is not a field of the data points, this is not a field of the heat pulse.
%
%   - finalChangeCondMean: if conductance is a field of the data points, if 
%       condsAfter is not empty, lastCond-
%       meanCondAfter.  If it is empty, NaN. If conductance is not a field 
%       of the data points, this is not a field of the heat pulse.
% 
%   - timesBefore: array of times of data points before the heat
%       pulse and after windowBeforeInS seconds before the heat pulse
%       starts.
% 
%   - timesDuring: array of times of data points in the heat pulse.
%
%   - timesAfter: array of times of data points after the heat pulse
%       and before WindowAfterInS seconds after the heat pulse ends.
% 
%   - tSinceLastChange1: if targetConc1 is a field of dataPoints, time
%       since the last change in the target concentration of gas 1.  If
%       targetConc1 is not a field of dataPoints, this is not a field of the heat pulse.
%
%   - tSinceLastChange2: if targetConc2 is a field of dataPoints, time
%       since the last change in the target concentration of gas 2.  If
%       targetConc2 is not a field of dataPoints, this is not a field of the heat pulse.
%
%   - tSinceLastChange3: if targetConc3 is a field of dataPoints, time
%       since the last change in the target concentration of gas 3.  If
%       targetConc3 is not a field of dataPoints, this is not a field of the heat pulse.
%
%   - tSinceLastChange4: if targetConc4 is a field of dataPoints, time
%       since the last change in the target concentration of gas 4.  If
%       targetConc4 is not a field of dataPoints, this is not a field of the heat pulse.
%
%   - corresTargetRH: If multiple or no streams are flowing, or the current target
%       relative humidity on stream B or purge are not 0 or 
%       in equiv_RHs, corresTargetRH is NaN.  Otherwise, corresTargetRH
%       is the target relative humidity on stream A that would produce
%       the same measured relative humidity as the current target
%       relative humidity on the current stream.  If currently, only
%       stream A is flowing, corresTargetRH is the current target
%       relative humidity.  If a different stream is flowing,
%       corresTargetRH is given by equiv_RHs.
%
%   - tSinceLastChangeRH: if targetRH is a field of dataPoints, time
%       since the last change in the corresponding target relative 
%       humidity.  If targetRH is not a field of dataPoints, this is not a field of the heat pulse.
% 
%-----------------------------EXAMPLE------------------------------------%
%   heatPulses=getHeatPulses(dataPoints,113,22,'WKeb...',[50 60 50; 24 35 24],1,1)
% 
% 

EOM = .003;
N_HP_PREALLOC=10000;
FILESUBSCRIPT='_heatPulses';

[~, filename, ~]=fileparts(fullfilename);
maxFilenameLength = namelengthmax-length(FILESUBSCRIPT);
if(length(filename) > maxFilenameLength)
    error('MATLAB:VarNameTooLong',...
        'Filename too long.  Must less than %d characters without extension.',...
        maxFilenameLength+1);
% elseif ~isempty(regexp(filename,'[^a-z_1-9]','ONCE'))
%     error('MATLAB:VarNameContainsInvalidCharacters',...
%         'Filename (besides extension) must contain only alphanumeric characters and underscore.');
end

heatPulses_varname_1=[filename FILESUBSCRIPT];
% characters that are not alphanumeric or underscores cannot be variable
% names so replace them with underscores
heatPulses_varname=regexprep(heatPulses_varname_1,'[^a-zA-Z_0-9]','_');
if heatPulses_varname(1)=='_'
    error('MATLAB:InvalidVarName',...
        'Filename must start with alphanumeric character.');
end

heatPulses_file=[heatPulses_varname '.mat'];
heatPulses_fid=fopen(heatPulses_file);
if(heatPulses_fid~=-1)
    fclose(heatPulses_fid);
    error('MATLAB:FileAlreadyExists',...
        'The file %s already exists.',...
        heatPulses_file);
end


if(~isnumeric(tg))
    error('ERROR: tg should be a number, not a string.')
end
if(~isnumeric(sequence))
    error('ERROR: sequence should be a number, not a string.')
end

if(nargin==6)
    equiv_RHs=[0 0 0];
    windowBeforeInS=1;
    windowAfterInS=1;
elseif(nargin==7)
    windowBeforeInS=1;
    windowAfterInS=1;
elseif(nargin==8)    
    windowAfterInS=windowBeforeInS;
end

if(ischar(arg))
    dataPoints=getDataPoints(arg,'dc');
else
    dataPoints=arg;
end

windowBeforeInMs=windowBeforeInS*1000;
windowAfterInMs=windowAfterInS*1000;
firstTime=dataPoints(1).time;
lastTime=dataPoints(end).time;
% assume between pulses initially
numDataPoints=length(dataPoints);

%---------------------SET INITIAL VALUES OF VARIABLES---------------------%
if(isfield(dataPoints(1),'targetConc1'))
    currTargetConc1=dataPoints(1).targetConc1;
    tLastChange1=dataPoints(1).time;
end
if(isfield(dataPoints(1),'targetConc2'))
    currTargetConc2=dataPoints(1).targetConc2;
    tLastChange2=dataPoints(1).time;
end
if(isfield(dataPoints(1),'targetConc3'))
    currTargetConc3=dataPoints(1).targetConc3;
    tLastChange3=dataPoints(1).time;
end
if(isfield(dataPoints(1),'targetConc4'))
    currTargetConc4=dataPoints(1).targetConc4;
    tLastChange4=dataPoints(1).time;
end
if(isfield(dataPoints(1),'streamSelect') || isfield(dataPoints(1),'targetRH'))
    switch dataPoints(1).streamSelect
        case {0, 3, 5, 6, 7}
            currCorresTargetRH=NaN;
        case 1
            currCorresTargetRH=dataPoints(1).targetRH;
        case {2, 4}
            numRHs=size(equiv_RHs,1);
            switch dataPoints(1).streamSelect
                case 2
                    stream=2;
                case 4
                    stream=3;
            end
            
            for k=1:numRHs
                if equiv_RHs(k,stream)==dataPoints(1).targetRH
                    currCorresTargetRH=equiv_RHs(k,1);
                    break;
                elseif k==numRHs
                    currCorresTargetRH=NaN;
                end
            end
    end
    
    tLastChangeRH=dataPoints(1).time;
end

pulseIndex=0;
i=1;

%-------------------------------------------------------------------------%
%-----------------------LOOP OVER DATAPOINTS------------------------------%
%-------------------------------------------------------------------------%
while i<=numDataPoints
    %----------if this data point is the start of a heat pulse---------------%
    if((dataPoints(i).heater_voltage > pulse_v-EOM) && (dataPoints(i).heater_voltage < pulse_v+EOM))
        pulseIndex=pulseIndex+1;
        % find initialDataPointIndexOfInterest, index of first data point
        % after windowBeforeInS seconds before start of heat pulse
        pulseStartingIndex=i;
        pulseStartingTime=dataPoints(i).time;
        if(pulseStartingTime-windowBeforeInMs>firstTime)
            initialTimeOfInterest=pulseStartingTime-windowBeforeInMs;
            for k=i-1:-1:1
                if(dataPoints(k).time<initialTimeOfInterest)
                    initialDataPointIndexOfInterest=k+1;
                    break;
                end
            end
        else
            initialDataPointIndexOfInterest=1;
        end
        % find pulseEndedIndex and finalDataPointIndexOfInterest
        for j=i:1:numDataPoints
            if((dataPoints(j).heater_voltage > v_btw_pulses-EOM) && (dataPoints(j).heater_voltage < v_btw_pulses+EOM))
                pulseEndedIndex=j;
                pulseEndedTime=dataPoints(j).time;
                if(pulseEndedTime+windowAfterInMs<lastTime)
                    finalTimeOfInterest=pulseEndedTime+windowAfterInMs;
                    for k=j+1:1:numDataPoints
                        if(dataPoints(k).time>finalTimeOfInterest)
                            finalDataPointIndexOfInterest=k-1;
                            break;
                        end
                    end
                else
                    pulseEndedIndex=numDataPoints+1; %?
                    finalDataPointIndexOfInterest=numDataPoints;
                end
                break;
            end
        end
        if(j==numDataPoints)
            pulseEndedIndex=numDataPoints+1;
            finalDataPointIndexOfInterest=numDataPoints;
        end
        
        % set this heat pulse to have all the fields and values of the
        % first data point of the heat pulse, minus unnecessary fields.
        % See comments at top for reason fields were removed.
        iHeatPulse=dataPoints(pulseStartingIndex);
        if(isfield(iHeatPulse,'conductance'))
            iHeatPulse=rmfield(iHeatPulse,'conductance');
        end
        if(isfield(iHeatPulse,'smoothedConductance'))
            iHeatPulse=rmfield(iHeatPulse,'smoothedConductance');
        end
        if(isfield(iHeatPulse,'medFiltConductance'))
            iHeatPulse=rmfield(iHeatPulse,'medFiltConductance');
        end

        % set various field values
        iHeatPulse.testGroup=tg;
        iHeatPulse.sequence=sequence;
        iHeatPulse.zephyrOutputFileName=fullfilename;
        iHeatPulse.index=pulseIndex;
        iHeatPulse.firstDataPointIndex=pulseStartingIndex;
        
        dataPointsBefore=dataPoints(initialDataPointIndexOfInterest:pulseStartingIndex-1);
        dataPointsDuring=dataPoints(pulseStartingIndex:pulseEndedIndex-1);
        dataPointsAfter=dataPoints(pulseEndedIndex:finalDataPointIndexOfInterest);

        if(isfield(dataPoints(pulseStartingIndex),'conductance'))
            iHeatPulse.condsBefore=getVals(dataPointsBefore,'conductance');
            iHeatPulse.condsDuring=getVals(dataPointsDuring,'conductance');
            iHeatPulse.condsAfter=getVals(dataPointsAfter,'conductance');
            
            iHeatPulse.firstCond=iHeatPulse.condsDuring(1);
            
            if(~isempty(iHeatPulse.condsBefore))
                iHeatPulse.meanCondBefore=mean(iHeatPulse.condsBefore(1:max(1,end-1)));
                iHeatPulse.initChangeCond=iHeatPulse.firstCond-iHeatPulse.condsBefore(end);
            else
                iHeatPulse.meanCondBefore=NaN;
                iHeatPulse.initChangeCond=NaN;
            end
            
            iHeatPulse.initChangeCondMean=iHeatPulse.firstCond-iHeatPulse.meanCondBefore;
            iHeatPulse.meanCond=mean(iHeatPulse.condsDuring);
            iHeatPulse.lastCond=iHeatPulse.condsDuring(end);
            iHeatPulse.meanLast3Cond=mean(iHeatPulse.condsDuring(max(end-2,1):end));
            iHeatPulse.meanLast5Cond=mean(iHeatPulse.condsDuring(max(end-4,1):end));
            if ~isempty(iHeatPulse.condsAfter)
                iHeatPulse.meanCondAfter=mean(iHeatPulse.condsAfter(min(2,end):end));
                iHeatPulse.finalChangeCondMean=iHeatPulse.lastCond-iHeatPulse.meanCondAfter;
                iHeatPulse.finalChangeCond=iHeatPulse.lastCond-iHeatPulse.condsAfter(1);
            else
                iHeatPulse.meanCondAfter=NaN;
                iHeatPulse.finalChangeCondMean=NaN;
                iHeatPulse.finalChangeCond=NaN;
            end
        end
       
        iHeatPulse.timesBefore=getVals(dataPointsBefore,'time');
        iHeatPulse.timesDuring=getVals(dataPointsDuring,'time');
        iHeatPulse.timesAfter=getVals(dataPointsAfter,'time');
        
        if(isfield(iHeatPulse,'targetConc1'))
            if(iHeatPulse.targetConc1~=currTargetConc1)
                currTargetConc1=iHeatPulse.targetConc1;
                tLastChange1=iHeatPulse.time;
            end
            iHeatPulse.tSinceLastChange1=iHeatPulse.time-tLastChange1;
        end
        if(isfield(iHeatPulse,'targetConc2'))
            if(iHeatPulse.targetConc2~=currTargetConc2)
                currTargetConc2=iHeatPulse.targetConc2;
                tLastChange2=iHeatPulse.time;
            end
            iHeatPulse.tSinceLastChange2=iHeatPulse.time-tLastChange2;
        end
        if(isfield(iHeatPulse,'targetConc3'))
            if(iHeatPulse.targetConc3~=currTargetConc3)
                currTargetConc3=iHeatPulse.targetConc3;
                tLastChange3=iHeatPulse.time;
            end
            iHeatPulse.tSinceLastChange3=iHeatPulse.time-tLastChange3;
        end
        if(isfield(iHeatPulse,'targetConc4'))
            if(iHeatPulse.targetConc4~=currTargetConc4)
                currTargetConc4=iHeatPulse.targetConc4;
                tLastChange4=iHeatPulse.time;
            end
            iHeatPulse.tSinceLastChange4=iHeatPulse.time-tLastChange4;
        end
        
        if(isfield(iHeatPulse,'streamSelect') || isfield(iHeatPulse,'targetRH'))
            equiv_RHs_w_0=[0 0 0; equiv_RHs];
            
            % set corresTargetRH.
            % If multiple or no streams are flowing, or the current target 
            % relative humidity on stream B or purge are not 0 or
            % in equiv_RHs, corresTargetRH is NaN.  Otherwise, corresTargetRH
            % is the target relative humidity on stream A that would produce 
            % the same measured relative humidity as the current target
            % relative humidity on the current stream.  If currently, only
            % stream A is flowing, corresTargetRH is the current target
            % relative humidity.  If a different stream is flowing,
            % corresTargetRH is given by equiv_RHs.
            switch iHeatPulse.streamSelect
                case {0, 3, 5, 6, 7}
                    iHeatPulse.corresTargetRH=NaN;
                case 1
                    iHeatPulse.corresTargetRH=iHeatPulse.targetRH;
                case {2, 4}
                    numRHs=size(equiv_RHs_w_0,1);
                    switch iHeatPulse.streamSelect
                        case 2
                            stream=2;
                        case 4
                            stream=3;
                    end
                    
                    for k=1:numRHs
                        if equiv_RHs_w_0(k,stream)==iHeatPulse.targetRH
                            iHeatPulse.corresTargetRH=equiv_RHs_w_0(k,1);
                            break;
                        elseif k==numRHs
                            iHeatPulse.corresTargetRH=NaN;
                        end
                    end
            end
            
            % Set tSinceLastChangeRH, the time since the last change in 
            % corresTargetRH.  If currCorresTargetRH is NaN,
            % tSinceLastChangeRH is also NaN.
            if(iHeatPulse.corresTargetRH~=currCorresTargetRH)
                currCorresTargetRH=iHeatPulse.corresTargetRH;
                tLastChangeRH=iHeatPulse.time;
            end
            if ~isnan(currCorresTargetRH)
                iHeatPulse.tSinceLastChangeRH=iHeatPulse.time-tLastChangeRH;
            else
                iHeatPulse.tSinceLastChangeRH=NaN;
            end
        end
        

        % preallocation for speed (~10% faster for 5MB file)
        if(pulseIndex==1)
            heatPulses=cell(N_HP_PREALLOC,1);
        end
        heatPulses{pulseIndex,1}=iHeatPulse;

        %uncomment following and comment out previous block to output
        %heatPulses as an array instead of a cell
%         if(pulseIndex==1)
%             heatPulses=repmat(struct(iHeatPulse),N_HP_PREALLOC,1);
%         end
%         heatPulses(1)=iHeatPulse;

        
        i = pulseEndedIndex;
    end
    i=i+1;
end
% remove preallocated cell array elements that were not used
heatPulses(pulseIndex:N_HP_PREALLOC)=[];

% Save heatPulses to a file.
eval([heatPulses_varname ' = heatPulses;']);
save(heatPulses_file,heatPulses_varname);

end