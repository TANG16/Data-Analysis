function [] = removeCols( existingFileName, colsToKeep )
%REMOVECOLS Summary of this function goes here
%   Detailed explanation goes here

    colsToKeep=sort(colsToKeep);

    if(colsToKeep(1)~=0)
        colsToKeep = [0 colsToKeep];
    end
    
    existingFileID=fopen(existingFileName);
    
    [pathstr, name, ext] = fileparts(existingFileName);
    
    createdFileID=fopen(fullfile(pathstr,[name '_cols_removed' ext]),'w');
    
    while true
        lineOfExistingFile=fgetl(existingFileID);
        
        fprintf(createdFileID,[lineOfExistingFile,'\n']);
        
        if(strcmp(lineOfExistingFile,'#begin-data-header'))
            break;
        end
    end
    
    iCol=1;
    iColsKept=0;
    iColsRemoved=0;
    while true
        lineOfExistingFile=fgetl(existingFileID);
        lineOfExistingFile=regexprep(lineOfExistingFile,'%','%%');
        
        regExpTokens=regexpi(lineOfExistingFile,'#col(\d+)(.*)','tokens');
        
        if(isempty(regExpTokens) || length(regExpTokens{1})~=2)
            fprintf(createdFileID,[lineOfExistingFile,'\n']);
        else
            colNum=str2num(regExpTokens{1}{1});
            colName=regExpTokens{1}{2};
            
            numColsOrig=colNum;
           
            if iColsKept < length(colsToKeep) && colNum==colsToKeep(iColsKept+1)
                fprintf(createdFileID,['#col',num2str(colNum-iColsRemoved),colName,'\n']);
                iColsKept=iColsKept+1;
            else
                iColsRemoved=iColsRemoved+1;
            end
        end
    
        if(strcmp(lineOfExistingFile,'#end-data-header'))
            break;
        end
    end
    
    while true
        lineOfExistingFile=fgetl(existingFileID);
        
        fprintf(createdFileID,[lineOfExistingFile,'\n']);
        
        if(strcmp(lineOfExistingFile,'#begin-data'))
            break;
        end
    end

    pat=strcat(repmat('(\S+\t)',1,numColsOrig),'(\S+)');
    
    while true
        lineOfExistingFile=fgetl(existingFileID);
        
        if(strcmp(lineOfExistingFile,'#end-data'))
            break;
        end
        
        allColVals=regexp(lineOfExistingFile,pat,'tokens');
        
        fprintf(createdFileID,[cell2mat(allColVals{1}(colsToKeep+1)),'\n']);
    end
 
%     for iColToRemove=ColsToRemove
%         while true
%             lineOfExistingFile=fgetl(existingFileID);
%             
%             if(regexpi(lineOfExistingFile,['#col',num2str(iColToRemove),'.*']))
%                 break;
%             end
%             
%             fprintf(createdFileID,strcat(lineOfExistingFile,'\n'));
%         end
%         
%         while true
%             lineOfExistingFile=fgetl(existingFileID)
%             
%             regExpTokens=regexpi(lineOfExistingFile,'#col(\d+)(.*)','tokens');
%             if(isempty(regExpTokens))
%                 break;
%             end
%             
%             colNum=str2num(regExpTokens{1}{1});
%             colName=regExpTokens{1}{2};
%             
%             fprintf(createdFileID,['#col',num2str(colNum-1),colName,'\n'])
%         end
%     end
    
    
    fclose('all');
end

