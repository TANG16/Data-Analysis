function breakupFile(file,MBperFile,unixcmdspath)
% BREAKUPFILE breaks up a data file into multiple files
%
% Breaks up file 'file' into multiple files, each of size MBperFile, (each
% with the original header).  This program uses unix commands for 
% speed, and unixcmdspath specifies the location of the commands
% (defaults to unixcmdspath).


if(nargin==2)
    unixcmdspath='C:\cygwin\bin';
end

bytesPerFile=MBperFile*1000000;
[filepath,filename,fileext]=fileparts(file);

header_file = [file '_header'];
data_file = [file '_data'];

% add unixcmdspath to PATH variable if it is not there
path= getenv('PATH');
if(isempty(strfind(path,unixcmdspath)))
    path = [unixcmdspath ';' path];
    setenv('PATH',path);
end

% find line where data begins, using grep
[~,grep_output]=unix(['grep -n -x ''#begin-data'' ' file]);
n_line_beg_data_cell=regexp(grep_output,'(\d+):#begin-data','tokens');
n_line_beg_data_str=n_line_beg_data_cell{1}{1};

% write header to a header_file, using head
unix(['head -' n_line_beg_data_str ' ' file ' > ' header_file]);

% write data to a data_file, using tail
unix(['tail -n +' num2str(str2double(n_line_beg_data_str)+1) ' ' file ' | head -n -1 > ' data_file]);

% find total number of lines in data_file, using wc
[~,nLinesTotWcOutput]=unix(['wc -l ' data_file]);
nLinesTotCell=regexp(nLinesTotWcOutput,['(\d+) ' data_file],'tokens');
nLinesTotNum=str2double(nLinesTotCell{1}{1});

% find total number of bytes in data_file, using wc
[~,nBytesTotWcOutput]=unix(['wc -c ' data_file]);
nBytesTotCell=regexp(nBytesTotWcOutput,['(\d+) ' data_file],'tokens');
nBytesTotNum=str2double(nBytesTotCell{1}{1});

% find number of lines per file, using simple math
linesPerFileNum=floor((nLinesTotNum/nBytesTotNum) * bytesPerFile);
linesPerFileStr=num2str(linesPerFileNum);

% this loop creates the result files
i=1;
i_n_lines_data_file_tail=nLinesTotNum;
while(i_n_lines_data_file_tail > 0)
    iStr=num2str(i);
    i_data_file_tail=[data_file '_tail_' iStr];
    i_no_end_data_file=[file '_no_end_data_' iStr];
    i_file=fullfile(filepath,[[filename '_' iStr] fileext]);
    
    % commented out code didn't work because standard output didn't have 
    % enough memory
    % unix(['tail -' num2str(nLinesTotNum-(i-1)*linesPerFileNum) ' ' data_file
    % ' | head -' linesPerFileStr ' | cat ' header_file ' - > ' i_no_end_data_file])
    
    % put all data to put in ith file, and all data after that, in
    % i_data_file_tail, using tail and redirection
    unix(['tail -' num2str(nLinesTotNum-(i-1)*linesPerFileNum) ' ' data_file ' > ' i_data_file_tail]);
    
    % get the data to put in ith file and add header from header_file, and
    % put in i_no_end_data_file, using head, cat, and redirection
    unix(['head -' linesPerFileStr ' ' i_data_file_tail ' | cat ' header_file ' - > ' i_no_end_data_file]);
    
    % add '#end-data' to i_no_end_data_file and put in i_file, using echo,
    % cat, and redirection
    unix(['echo #end-data | cat ' i_no_end_data_file ' - > ' i_file]);
    
    % update loop variables, delete files I don't need anymore
    i_n_lines_data_file_tail=nLinesTotNum-i*linesPerFileNum;
    delete(i_data_file_tail,i_no_end_data_file);
    i=i+1;
end

% delete files I don't need
delete(header_file,data_file);

end