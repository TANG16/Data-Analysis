function keepEveryNthLine(fileToReadFrom,fileToWriteTo,n)
    freadid = fopen(fileToReadFrom);
    fwriteid = fopen(fileToWriteTo,'w');
    
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
    
    fclose(freadid);
    fclose(fwriteid);
end