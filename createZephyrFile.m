function createZephyrFile(fileName,dataPoints,overwriteFlag,comments)
% CREATEZEPHYRFILE creates a zephyr file from data points
%
% INPUTS
%   fileName: file to write to
%   dataPoints: datapoints to write
%   overwriteFlag: Is it OK to overwrite fileName if it exists?
%   comments: comments to add to file

    % if file exists and overwriteFlag is false, throw error.  Otherwise,
    % open for writing.
    if(exist(fileName,'file') && overwriteFlag==0)
        error('file %s already exists and overwriteFlag is set to 0 so function has aborted',fileName)
    end
    fileID=fopen(fileName,'w');
 
    % write comments to file in necessary syntax
    fprintf(fileID,'#begin-file-header \n');
    if(nargin==4)
        fprintf(fileID,'#comments=%s \n',comments);
    end  
    fprintf(fileID,'#end-file-header \n');
    fprintf(fileID,'\n');
    fprintf(fileID,'#begin-data-header \n');

    % write dataPoints' variable names into header.  If variables are time
    % or conductance, add units so zeptoscope will open it.
    fields=fieldnames(dataPoints);
    numFields=length(fields);
    for i=1:numFields
        iField=fields{i};
        if strcmp(iField,'time')
            units='[U=ms]';
        elseif ~isempty(strfind(iField,'conductance'))
            units='[U=Siemens]';
        else
            units='';
        end
        fprintf(fileID,'#col%d =%s %s \n',i-1,fields{i},units);   
    end
    
    % write more necessary syntax to file
    fprintf(fileID,'#end-data-header \n');
    fprintf(fileID,'\n');
    fprintf(fileID,'#begin-data \n');
    fclose('all');
    
    % the following line was much faster (~2s for ~15000 datapoints) than
    % code which writes the datapoints to the file using low-level IO,
    % which took ~23s and which follows and is commented out, and code
    % which does something similar to the commented out code but writes
    % each line to a string before writing it to a file, which took ~30s.
    % This disadvantage of the following line of code is that it may run
    % into a memory issue when there are a lot of dataPoints, in which case
    % there should be a series of dlmwrite's, each one writing a certain
    % easy-to-handle portion of the dataPoints.
    dlmwrite(fileName,cell2mat(struct2cell(dataPoints))','-append','delimiter','\t');

    % write necessary syntax and close file
    fileID=fopen(fileName,'a');
    fprintf(fileID,'#end-data \n');
    fclose('all');
%     tic
%     numDataPoints=length(dataPoints);
%     for i=1:numDataPoints
%         for j=1:numFields
%             fprintf(fileID,'%d\t',dataPoints(i).(fields{j}));
%         end
%         fprintf(fileID,'\n');
%     end
%     toc
%     
%     fprintf(fileID,'#end-data \n');
% 
%     fclose('all');
    

end