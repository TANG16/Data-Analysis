function output = removeInfinities( fileToReadFrom,fileToWriteTo )
%REMOVEINFINITIES Removes infinities from file
%   fileToWriteTo is fileToReadFrom with all infinities removed.

    freadid = fopen(fileToReadFrom);
    fwriteid = fopen(fileToWriteTo,'w');
    
    while true
        if feof(freadid)
            break;
        else
            line=fgets(freadid);
            if(isempty(regexp(line,'.*Infinity.*')))
                fprintf(fwriteid,'%s',line);
            end

        end
    end

    fclose('all');
    output=true;
end

