function keepEveryNthLine(fileToReadFrom,fileToWriteTo,n)
% KEEPEVERYNTHLINE Creates a new file with only every nth line of the
% original file
% 
% FileToWriteTo has the same header as fileToReadFrom, but only every nth
% line of tha data.
%
%
    % open files
    freadid = fopen(fileToReadFrom);
    fwriteid = fopen(fileToWriteTo,'w');
    
    % copy header (all lines that start with whitespace or a '#'
    while true
        if feof(freadid)
            break;
        else
%             line=fgetl(freadid);
%             if(isempty(line) || line(1)=='#')
%                 fprintf(fwriteid,'%s',strcat(line,'\n'));
            line=fgets(freadid);
            if(isspace(line(1)) || line(1)=='#')
                fprintf(fwriteid,'%s',line);
            else
                break;
            end
        end   
    end
    
    % copy every nth line
    while true
        for i=1:n-1
            if feof(freadid)
                break;
            else
                fgets(freadid);
            end
        end
        
        if feof(freadid)
            break;
        else
            fprintf(fwriteid,'%s',fgets(freadid));
        end
    end
    
    % close files
    fclose(freadid);
    fclose(fwriteid);
end