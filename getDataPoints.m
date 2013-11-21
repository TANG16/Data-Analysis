function dataPoints = getDataPoints(filename, filetype)
% The data points are represented by a struct array.  Of the built-in
% classes, the data in a struct array is accessable in a way which is
% closest to the way it needs to be.  The total necessary memory for
% a struct array can be allocated once, as opposed to the case of an array
% of instances of user-defined classes, which dramatically speeds up 
% instantiation time.  The downside to representing the data points as a 
% struct array is that no functions can be "associated" with the data 
% points in the same way that a class is associated with its methods.  
% 
% The only other options are (a) creating a datapoint class which is a 
% sub-class of struct, which is not possible, because struct is Sealed (I 
% tried) or (b) creating a dataPointArray class with its only property a
% struct array datapoints representing the datapoints.  This way, I could
% associate the dataPointArray class with functions dealing with
% data points. Accessing the data points' fields' values directly would be 
% awkward (i.e. if the dataPointArray obj were called data, the third data 
% point's time would be returned by data.datapoints(3).time) so it would be 
% better to access the data points' fields' values through a get command.  
% This would not significantly increase runtime as long as I "got" all 
% needed fields' values before a loop over data points.  The only downside 
% is that accessing an individual data point's field's value is less 
% straightforward than for a struct array.
%
% filename: file to read from
% filetype:
%   'dc': dc file
%   'iVg2dc': dc file converted from iVg
%   'iVg': iVg file


if(strcmpi(filetype,'dc') || strcmpi(filetype,'iVg2dc'))
    [importeddata,~,~] = importdata(filename);
    if isfield(importeddata,'textdata') && ~strcmp(lastwarn,'MATLAB:importdata:FormatMismatch')
        header = importeddata.textdata;
        rawdata = importeddata.data;
        
        i=1;
        while(~strcmpi(header{i},'#begin-data-header'))
            i=i+1;
        end
        i=i+1;
        
        ColNumVarAndUnits=cell(0);
        while(~strcmpi(header{i},'#end-data-header'))
            if(~strcmp(header{i},''))
                ColNumVarAndUnits=[ColNumVarAndUnits; regexpi(header{i},'#col(\d+)\s*=\s*([^\[\s]*)(?:\s*\[U\s*=\s*)?(\w+)?','tokens')];
            end
            i=i+1;
        end
        
        numVars=length(ColNumVarAndUnits);
        for i=1:numVars
            if(strcmp(filetype,'dc'))
                if(strcmpi(ColNumVarAndUnits{i}{3},'Siemens'))
                    if(~isempty(strfind(ColNumVarAndUnits{i}{2},'e1')))
                        ColNumVarAndUnits{i}{2} ='conductance';
                    else
                        ColNumVarAndUnits{i}{2} ='heater_conductance';
                    end
                end
            end
            
            if(strcmp(ColNumVarAndUnits{i}{2},'targetConc1_h2s'))
                ColNumVarAndUnits{i}{2}='targetConc1_H2S';
            end
            
            varNameCell=regexpi(ColNumVarAndUnits{i}{2},'.*10k-cap.1-10k-cap.2_(.*)','tokens');
            if(~isempty(varNameCell))
                ColNumVarAndUnits{i}{2}=varNameCell{1};
            end
            
            % the next two are quick fixes
            if(strcmp(ColNumVarAndUnits{i}{2},'Vg-0.4?G-upsweep'))
                ColNumVarAndUnits{i}{2}='Vg_minus_point4deltaG_upsweep';
            end
            
            if(strcmp(ColNumVarAndUnits{i}{2},'Vg-0.4?G-downsweep'))
                ColNumVarAndUnits{i}{2}='conductance';
            end
            
            if(~isempty(strfind(ColNumVarAndUnits{i}{2},'Vsd')))
                if(~isempty(strfind(ColNumVarAndUnits{i}{2},'e1')))
                    ColNumVarAndUnits{i}{2}='sensor_voltage';
                else
                    ColNumVarAndUnits{i}{2}='heater_voltage';
                end
            else
                
            end
            
            ColNumVarAndUnits{i}{2}=strrep(ColNumVarAndUnits{i}{2},'-','_');
            ColNumVarAndUnits{i}{2}=strrep(ColNumVarAndUnits{i}{2},'.','_');   %AS 7/13/12 140PM
        end
        
        sortedVars=cell(0);
        for i=0:numVars-1
            j=0;
            while(str2double(ColNumVarAndUnits{mod(j+i,numVars)+1}{1})~=i)
                j=j+1;
            end
            sortedVars = [sortedVars ColNumVarAndUnits{mod(j+i,numVars)+1}{2}];
        end
        
        dataPoints=cell2struct(num2cell([rawdata zeros(length(rawdata),2)]),[sortedVars 'smoothedConductance' 'medFiltConductance'],2);
        
        numDataPoints=length(dataPoints);
        
        % conductances=cell(size(dataPoints));
        % [conductances{:}]=dataPoints(:).conductance;
        % conductancesMat=cell2mat(conductances);
        
        conductances=getVals(dataPoints,'conductance');
        
        conductancesMedFilt=medfilt1(conductances);
        conductancesMedFiltRunningAvg=filter(ones(1,5)/5,1,conductancesMedFilt);
        
        for i=1:numDataPoints
            dataPoints(i).medFiltConductance=conductancesMedFilt(i);
        end
        
        for i=3:numDataPoints-2
            dataPoints(i).smoothedConductance=conductancesMedFiltRunningAvg(i+2);
        end
        
        dataPoints(1).smoothedConductance=conductancesMedFiltRunningAvg(5);
        dataPoints(2).smoothedConductance=conductancesMedFiltRunningAvg(5);
        dataPoints(end-1).smoothedConductance=conductancesMedFiltRunningAvg(end);
        dataPoints(end).smoothedConductance=conductancesMedFiltRunningAvg(end);
    else
        if(strcmp(lastwarn,'MATLAB:importdata:FormatMismatch'))
            errorStr=['I think MATLAB has run out of memory.\n\n' ...
                'Try running ''clear'' and running this again.\n\n' ...
                'If that doesn''t work try decreasing file size or increasing' ...
                ' MATLAB memory size'];                                     %Added AS 7/16/12
        else
            errorStr = ['ERROR: Most likely filename''s header is too long. ' ...
                'At the cmd prompt, run\n\n' ...
                'grep -n ''#end-file-header'' filename\n\n' ...
                'This returns\n\n' ...
                'X:#end-file-header\n\n' ...
                'Here X is the line number of the string ''#end-file-header''. ' ...
                'Now run\n\n' ...
                'tail -n+X filename > filename_no_file_header\n\n' ...
                'Which creates a new file called filename_no_file_header ' ...
                'with no file header.  Rerun getDataPoints on that file.']; %Added AS 7/16/12
        end
        error(errorStr,'');                                                 %Added AS 7/16/12
    end
else
    tic;
    fid=fopen(filename);
    
    % skip header
    while 1
        currLine=fgetl(fid);
        if(strcmpi(currLine,'#IVG'))
            break;
        end    
    end
    
    % save position
    beginningOfFirstIVgBlock=ftell(fid);
    
    % find names of fields in iVg header
    numHeaderFields=0;
    while 1
        currLine=fgetl(fid);
        currFieldNameAndVal=regexpi(currLine,'#(\S*): (.*)','tokens');
        if(isempty(currFieldNameAndVal))
            break;
        end
        currFieldName=currFieldNameAndVal{1}{1};
        numHeaderFields=numHeaderFields+1;
        
        % numElecMeasPerGateSweep = number of electrical measurements per gate sweep
        if(strcmpi(currFieldName,'npoints'))
            numElecMeasPerGateSweep = str2double(currFieldNameAndVal{1}{2});
        end
        
        % Structures field names can't have a -, , , or % so if they are in
        % the field name, replaced them
        currFieldName=strrep(currFieldName,'-','_');
        currFieldName=strrep(currFieldName,',','_');        
        currFieldName=strrep(currFieldName,'%','percent');
        
        fieldNames{numHeaderFields}=currFieldName;
    end
    
    % add more field names
    fieldNames=[fieldNames 'electrical_measurements' 'max_transconductance' 'Vg_at_max_transconductance' 'min_transconductance' 'Vg_at_min_transconductance'];
    
    % go back to the beginning of the first iVg block
    fseek(fid,beginningOfFirstIVgBlock,'bof');
    
    % preallocate space for 100000 iVg, which corresponds to around 200 MB
    % (so far the biggest iv file is about 150 MB)
    dataPointsCell=cell(100000,numHeaderFields+5);
    
    % parse data into a cell array
    numIVgs=0;
    %tt=0;
    while ~feof(fid)
        numIVgs=numIVgs+1;
        
        fieldVals=textscan(fid,'%*s %[^\n]',numHeaderFields);
%         for i=1:numFields-1
%             fieldVals{1}{i}=str2double(fieldVals{1}{i});
%         end
        dataPointsCell(numIVgs,1:numHeaderFields)=fieldVals{1};
        
        elecMeasurements=textscan(fid,'%f %f %f %f',numElecMeasPerGateSweep);
        onesArray=ones(numElecMeasPerGateSweep,1);
%         dataPointsCell{numIVgs,numFields}=struct('a',mat2cell(elecMeasurements{1},onesArray,1),...
%             'b',mat2cell(elecMeasurements{2},onesArray,1),...
%             'c',mat2cell(elecMeasurements{3},onesArray,1),...
%             'd',mat2cell(elecMeasurements{4},onesArray,1));
        Vsd=single(elecMeasurements{1});
        Vg=single(elecMeasurements{2});
        Is=single(elecMeasurements{3});
        Ig=single(elecMeasurements{4});
        dataPointsCell{numIVgs,numHeaderFields+1}=struct('Vsd',mat2cell(Vsd,onesArray,1),...
            'Vg',mat2cell(Vg,onesArray,1),...
            'Is',mat2cell(Is,onesArray,1),...
            'Ig',mat2cell(Ig,onesArray,1));
        
        %tic;
        dIsdVg=diff(Is)./diff(Vg);

        [dataPointsCell{numIVgs,numHeaderFields+1},maxdIsdVgIndex]=max(dIsdVg);
        maxdIsdVgIndex=maxdIsdVgIndex(1);
        dataPointsCell{numIVgs,numHeaderFields+2}=(Vg(maxdIsdVgIndex)+Vg(maxdIsdVgIndex+1))/2;

        [dataPointsCell{numIVgs,numHeaderFields+3},mindIsdVgIndex]=min(dIsdVg);
        mindIsdVgIndex=mindIsdVgIndex(1);
        dataPointsCell{numIVgs,numHeaderFields+4}=(Vg(mindIsdVgIndex)+Vg(mindIsdVgIndex+1))/2;
        %t=toc;
        %tt=tt+t;
%         if numIVgs==50
%             plot(Vg,Is);    
%             hold all;
%             plot(Vg(1:end-1)+diff(Vg)/2,diff(Is)./diff(Vg));
%             
%             dIsdVg=diff(Is)./diff(Vg);
%             
%             [maxdIsdVg,maxdIsdVgIndex]=max(dIsdVg)
%             maxdIsdVgIndex=maxdIsdVgIndex(1);
%             VgAtMaxdIsdVg=(Vg(maxdIsdVgIndex)+Vg(maxdIsdVgIndex+1))/2
%             
%             [mindIsdVg,mindIsdVgIndex]=min(dIsdVg)
%             mindIsdVgIndex=mindIsdVgIndex(1);
%             VgAtMindIsdVg=(Vg(mindIsdVgIndex)+Vg(mindIsdVgIndex+1))/2
% 
%         end
        
        fgetl(fid);
        fgetl(fid);
    end
    %tt
    
    % convert cell array to dataPoints stucture
    dataPoints=cell2struct(dataPointsCell(1:numIVgs,:),fieldNames,2);

    fclose(fid);
    toc
end
end